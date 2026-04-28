#!/usr/bin/env python3
"""
Package the DevForge Chain for distribution.

Usage:
    python package-plugin.py [--output OUTPUT_DIR] [--mode {plugin|skills|all}]

Modes:
    plugin  - Package the entire skill chain as a Claude Code plugin (default)
    skills  - Package each individual skill as a .skill file
    all     - Do both

Example:
    python package-plugin.py --mode all --output ./dist
"""

import argparse
import os
import sys
import zipfile
from pathlib import Path


def validate_skill_frontmatter(skill_dir: Path) -> tuple[bool, str]:
    """Validate that a skill directory has proper YAML frontmatter in SKILL.md."""
    skill_md = skill_dir / "SKILL.md"
    if not skill_md.exists():
        return False, f"Missing SKILL.md in {skill_dir.name}"

    content = skill_md.read_text(encoding="utf-8")
    lines = content.splitlines()

    if not lines or lines[0].strip() != "---":
        return False, f"Missing YAML frontmatter opening '---' in {skill_dir.name}"

    # Find closing ---
    try:
        closing_idx = lines[1:].index("---") + 1
    except ValueError:
        return False, f"Missing YAML frontmatter closing '---' in {skill_dir.name}"

    frontmatter = "\n".join(lines[1:closing_idx])

    if "name:" not in frontmatter:
        return False, f"Missing 'name' field in frontmatter of {skill_dir.name}"
    if "description:" not in frontmatter:
        return False, f"Missing 'description' field in frontmatter of {skill_dir.name}"

    return True, "OK"


def find_skills(base_dir: Path) -> list[Path]:
    """Find all skill directories under base_dir."""
    skills = []
    for item in base_dir.iterdir():
        if item.is_dir() and not item.name.startswith(".") and not item.name.startswith("__"):
            if item.name == "extensions":
                # Recurse into extensions
                for ext in item.iterdir():
                    if ext.is_dir() and (ext / "SKILL.md").exists():
                        skills.append(ext)
            elif (item / "SKILL.md").exists():
                skills.append(item)
    return skills


def package_individual_skill(skill_dir: Path, output_dir: Path) -> Path:
    """Package a single skill as a .skill file (ZIP format)."""
    skill_name = skill_dir.name
    output_path = output_dir / f"{skill_name}.skill"

    with zipfile.ZipFile(output_path, "w", zipfile.ZIP_DEFLATED) as zf:
        for file_path in skill_dir.rglob("*"):
            if file_path.is_file():
                # Skip excluded files/directories
                rel_parts = file_path.relative_to(skill_dir).parts
                if any(p.startswith("__") for p in rel_parts):
                    continue
                if any(p == "node_modules" for p in rel_parts):
                    continue
                if file_path.name == ".DS_Store":
                    continue
                if file_path.suffix == ".pyc":
                    continue

                arcname = f"{skill_name}/{file_path.relative_to(skill_dir)}"
                zf.write(file_path, arcname)

    return output_path


def package_plugin(base_dir: Path, output_dir: Path, version: str) -> Path:
    """Package the entire skill chain as a plugin ZIP."""
    output_path = output_dir / f"DevForge-chain-v{version}.zip"

    # Files/directories to include at root level
    include_items = [
        ".claude-plugin",
        "devforge-requirement-analysis",
        "devforge-architecture-design",
        "devforge-architecture-validation",
        "devforge-design-review",
        "devforge-project-scaffolding",
        "devforge-module-design",
        "devforge-iteration-planning",
        "context-compression",
        "extensions",
        "references",
        "scripts",
        "artifacts",
        "README.md",
        "devforge-design.md",
        "devforge-state.md",
        "devforge-plan.md",
    ]

    with zipfile.ZipFile(output_path, "w", zipfile.ZIP_DEFLATED) as zf:
        for item_name in include_items:
            item_path = base_dir / item_name
            if not item_path.exists():
                continue

            if item_path.is_file():
                zf.write(item_path, item_path.relative_to(base_dir))
            else:
                for file_path in item_path.rglob("*"):
                    if file_path.is_file():
                        rel_parts = file_path.relative_to(base_dir).parts
                        if any(p.startswith("__") for p in rel_parts):
                            continue
                        if any(p == "node_modules" for p in rel_parts):
                            continue
                        if file_path.name == ".DS_Store":
                            continue
                        if file_path.suffix == ".pyc":
                            continue
                        zf.write(file_path, file_path.relative_to(base_dir))

    return output_path


def main():
    parser = argparse.ArgumentParser(description="Package DevForge Chain for distribution")
    parser.add_argument("--output", "-o", default="./dist", help="Output directory (default: ./dist)")
    parser.add_argument("--mode", choices=["plugin", "skills", "all"], default="plugin",
                        help="Package mode: plugin=full plugin, skills=individual .skill files, all=both")
    args = parser.parse_args()

    # Determine base directory (script is in skill/scripts/, base is skill/)
    script_dir = Path(__file__).parent.resolve()
    base_dir = script_dir.parent.resolve()
    output_dir = Path(args.output).resolve()

    print(f"Base directory: {base_dir}")
    print(f"Output directory: {output_dir}")
    print()

    # Create output directory
    output_dir.mkdir(parents=True, exist_ok=True)

    # Validate all skills
    print("=" * 60)
    print("Validating skills...")
    print("=" * 60)
    skills = find_skills(base_dir)
    all_valid = True
    for skill in skills:
        valid, msg = validate_skill_frontmatter(skill)
        status = "PASS" if valid else "FAIL"
        print(f"  [{status}] {skill.name}: {msg}")
        if not valid:
            all_valid = False

    if not all_valid:
        print("\nValidation failed. Fix errors before packaging.")
        sys.exit(1)

    print(f"\nAll {len(skills)} skills validated successfully.")
    print()

    # Read version from plugin.json
    plugin_json = base_dir / ".claude-plugin" / "plugin.json"
    version = "1.1.0"
    if plugin_json.exists():
        import json
        with open(plugin_json, "r", encoding="utf-8") as f:
            version = json.load(f).get("version", "1.1.0")

    results = []

    # Package individual skills
    if args.mode in ("skills", "all"):
        print("=" * 60)
        print("Packaging individual skills...")
        print("=" * 60)
        skills_output = output_dir / "skills"
        skills_output.mkdir(exist_ok=True)
        for skill in skills:
            out_path = package_individual_skill(skill, skills_output)
            size = out_path.stat().st_size
            print(f"  {skill.name}.skill ({size:,} bytes)")
            results.append(out_path)
        print()

    # Package full plugin
    if args.mode in ("plugin", "all"):
        print("=" * 60)
        print("Packaging full plugin...")
        print("=" * 60)
        out_path = package_plugin(base_dir, output_dir, version)
        size = out_path.stat().st_size
        print(f"  {out_path.name} ({size:,} bytes)")
        results.append(out_path)
        print()

    # Summary
    print("=" * 60)
    print("Packaging complete!")
    print("=" * 60)
    for r in results:
        print(f"  {r}")
    print()
    print("Installation instructions:")
    print("  1. For personal use: Copy skill directories to ~/.claude/skills/")
    print("  2. For distribution: Share the .zip or upload to a plugin marketplace")
    print("  3. For individual skills: Install .skill files via Claude Code")


if __name__ == "__main__":
    main()
