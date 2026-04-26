#!/usr/bin/env python3
"""
XML Architecture Synchronization Script

Usage:
    python xml-sync.py --verify-only [ARCH_DIR]   # Check consistency without modifying
    python xml-sync.py --sync [ARCH_DIR]          # Propagate changes and update refs

Resolves cross-references across System/Module/Component XML layers and reports inconsistencies.
"""

import argparse
import os
import sys
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import List, Dict, Set, Tuple


class XMLSync:
    def __init__(self, arch_dir: str):
        self.arch_dir = Path(arch_dir)
        self.system_xml = self.arch_dir / "system" / "architecture.xml"
        self.modules_dir = self.arch_dir / "modules"
        self.issues: List[Tuple[str, str]] = []  # (severity, message)
        self.modules: Dict[str, ET.Element] = {}
        self.module_files: Dict[str, Path] = {}

    def log_issue(self, severity: str, message: str):
        self.issues.append((severity, message))
        print(f"  [{severity}] {message}")

    def load_system_xml(self) -> bool:
        if not self.system_xml.exists():
            self.log_issue("ERROR", f"System architecture XML not found: {self.system_xml}")
            return False
        try:
            self.system_tree = ET.parse(self.system_xml)
            self.system_root = self.system_tree.getroot()
            for module in self.system_root.iter("Module"):
                mid = module.get("id")
                if mid:
                    self.modules[mid] = module
            return True
        except ET.ParseError as e:
            self.log_issue("ERROR", f"Failed to parse system XML: {e}")
            return False

    def check_module_detail_refs(self):
        """Verify ModuleDetail ref attributes point to existing files."""
        print("[Check] ModuleDetail references...")
        base_dir = self.system_xml.parent
        for mid, module in self.modules.items():
            detail = module.find("ModuleDetail")
            if detail is not None:
                ref = detail.get("ref")
                if ref:
                    resolved = base_dir / ref
                    if not resolved.exists():
                        self.log_issue("ERROR", f"Module '{mid}': ModuleDetail ref missing -> {resolved}")
                    else:
                        self.module_files[mid] = resolved
                        print(f"  [PASS] Module '{mid}': ModuleDetail ref exists -> {resolved}")
                else:
                    self.log_issue("WARN", f"Module '{mid}': ModuleDetail without ref attribute")

    def check_coupling_targets(self):
        """Verify Coupling/DependsOn targets exist as Module ids."""
        print("[Check] Coupling target consistency...")
        module_ids = set(self.modules.keys())
        for mid, module in self.modules.items():
            coupling = module.find("Coupling")
            if coupling is not None:
                for dep in coupling.iter("DependsOn"):
                    target = dep.get("module")
                    if target and target not in module_ids:
                        self.log_issue("ERROR", f"Module '{mid}': Coupling target '{target}' not found in system modules")
                    elif target:
                        print(f"  [PASS] Module '{mid}': Coupling target '{target}' valid")

    def check_state_model_completeness(self):
        """Verify State entries have required attributes."""
        print("[Check] StateModel attribute completeness...")
        required = {"id", "location", "owner", "lifecycle"}
        for xml_file in self.arch_dir.rglob("*.xml"):
            try:
                tree = ET.parse(xml_file)
                root = tree.getroot()
                for state in root.iter("State"):
                    missing = required - set(state.attrib.keys())
                    if missing:
                        rel = xml_file.relative_to(self.arch_dir)
                        self.log_issue("ERROR", f"{rel}: State '{state.get('id', 'UNKNOWN')}' missing attributes: {missing}")
                    else:
                        rel = xml_file.relative_to(self.arch_dir)
                        print(f"  [PASS] {rel}: State '{state.get('id')}' attributes complete")
            except ET.ParseError:
                continue

    def check_module_constraints(self):
        """Verify Module-level XML Constraints match system-level Interfaces."""
        print("[Check] Module constraints vs System interfaces...")
        for mid, module in self.modules.items():
            sys_interface = module.find("Interface")
            if mid not in self.module_files:
                continue
            module_path = self.module_files[mid]
            try:
                m_tree = ET.parse(module_path)
                m_root = m_tree.getroot()
                constraints = m_root.find("Constraints")
                if constraints is None:
                    self.log_issue("WARN", f"Module '{mid}': No Constraints section found")
                    continue
                # Check Input/Output schema consistency
                sys_inputs = {inp.get("schema") for inp in sys_interface.iter("Input") if inp.get("schema")}
                sys_outputs = {out.get("schema") for out in sys_interface.iter("Output") if out.get("schema")}
                mod_inputs = {inp.get("schema") for inp in constraints.iter("Input") if inp.get("schema")}
                mod_outputs = {out.get("schema") for out in constraints.iter("Output") if out.get("schema")}
                missing_in = sys_inputs - mod_inputs
                missing_out = sys_outputs - mod_outputs
                if missing_in:
                    self.log_issue("ERROR", f"Module '{mid}': Constraints missing required input schemas: {missing_in}")
                if missing_out:
                    self.log_issue("ERROR", f"Module '{mid}': Constraints missing required output schemas: {missing_out}")
                if not missing_in and not missing_out:
                    print(f"  [PASS] Module '{mid}': Constraints match system interface")
            except ET.ParseError as e:
                self.log_issue("ERROR", f"Module '{mid}': Failed to parse module XML: {e}")

    def propagate_system_changes(self):
        """Propagate system-level interface changes to module constraints."""
        print("[Sync] Propagating system changes to module constraints...")
        for mid, module in self.modules.items():
            sys_interface = module.find("Interface")
            if mid not in self.module_files or sys_interface is None:
                continue
            module_path = self.module_files[mid]
            try:
                m_tree = ET.parse(module_path)
                m_root = m_tree.getroot()
                constraints = m_root.find("Constraints")
                if constraints is None:
                    constraints = ET.SubElement(m_root, "Constraints")
                # Sync Input constraints
                for sys_inp in sys_interface.iter("Input"):
                    schema = sys_inp.get("schema")
                    if schema and not any(inp.get("schema") == schema for inp in constraints.iter("Input")):
                        new_inp = ET.SubElement(constraints, "Input")
                        new_inp.set("schema", schema)
                        new_inp.set("must", "true")
                        print(f"  [SYNC] Module '{mid}': Added input constraint '{schema}'")
                # Sync Output constraints
                for sys_out in sys_interface.iter("Output"):
                    schema = sys_out.get("schema")
                    if schema and not any(out.get("schema") == schema for out in constraints.iter("Output")):
                        new_out = ET.SubElement(constraints, "Output")
                        new_out.set("schema", schema)
                        new_out.set("must", "true")
                        print(f"  [SYNC] Module '{mid}': Added output constraint '{schema}'")
                # Write back
                self._indent_xml(m_root)
                m_tree.write(module_path, encoding="utf-8", xml_declaration=True)
            except Exception as e:
                self.log_issue("ERROR", f"Module '{mid}': Sync failed: {e}")

    def _indent_xml(self, elem, level=0):
        """Add pretty-print indentation to XML."""
        i = "\n" + level * "  "
        if len(elem):
            if not elem.text or not elem.text.strip():
                elem.text = i + "  "
            if not elem.tail or not elem.tail.strip():
                elem.tail = i
            for child in elem:
                self._indent_xml(child, level + 1)
            if not elem.tail or not elem.tail.strip():
                elem.tail = i
        else:
            if level and (not elem.tail or not elem.tail.strip()):
                elem.tail = i

    def verify(self):
        """Run all verification checks without modifying files."""
        print("=== XML Sync: Verify Mode ===\n")
        if not self.load_system_xml():
            return False
        self.check_module_detail_refs()
        self.check_coupling_targets()
        self.check_state_model_completeness()
        self.check_module_constraints()
        self._report()
        return not any(sev == "ERROR" for sev, _ in self.issues)

    def sync(self):
        """Run verification and propagate changes."""
        print("=== XML Sync: Sync Mode ===\n")
        if not self.load_system_xml():
            return False
        self.check_module_detail_refs()
        self.check_coupling_targets()
        self.check_state_model_completeness()
        self.check_module_constraints()
        self.propagate_system_changes()
        self._report()
        return not any(sev == "ERROR" for sev, _ in self.issues)

    def _report(self):
        print("\n=== Summary ===")
        errors = sum(1 for sev, _ in self.issues if sev == "ERROR")
        warns = sum(1 for sev, _ in self.issues if sev == "WARN")
        print(f"Errors: {errors}, Warnings: {warns}")
        if errors > 0:
            print("RESULT: FAILED")
            sys.exit(1)
        else:
            print("RESULT: PASSED")


def main():
    parser = argparse.ArgumentParser(description="XML Architecture Synchronization")
    parser.add_argument("arch_dir", nargs="?", default="docs/architecture", help="Architecture directory path")
    parser.add_argument("--verify-only", action="store_true", help="Only verify, do not modify files")
    parser.add_argument("--sync", action="store_true", help="Verify and propagate changes")
    args = parser.parse_args()

    sync = XMLSync(args.arch_dir)
    if args.sync:
        success = sync.sync()
    else:
        success = sync.verify()

    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
