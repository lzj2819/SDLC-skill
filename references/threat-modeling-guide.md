# Threat Modeling Guide

Reference document for `devforge-threat-modeling` skill.

## STRIDE Categories

| Category | Definition | Example Threat | Typical Mitigation |
|----------|-----------|----------------|-------------------|
| **S**poofing | Impersonating someone or something | Attacker fakes JWT token | MFA, token binding |
| **T**ampering | Modifying data or code | Request payload modified in transit | Digital signatures, TLS |
| **R**epudiation | Denying an action | User denies placing order | Audit logging, non-repudiation |
| **I**nformation Disclosure | Exposing data to unauthorized parties | Database dump exposed | Encryption, access control |
| **D**oS | Denying service to users | API flooded with requests | Rate limiting, DDoS protection |
| **E**levation of Privilege | Gaining unauthorized capabilities | Regular user becomes admin | RBAC, privilege separation |

## Risk Rating Matrix

| Likelihood \ Impact | Low | Medium | High |
|--------------------|-----|--------|------|
| **Likely** | Medium | High | Critical |
| **Possible** | Low | Medium | High |
| **Unlikely** | Low | Low | Medium |

## Output Template

Each threat in THREAT_MODEL_REPORT.md should contain:
- Threat ID (format: T-{module}-{stride}-{NNN})
- STRIDE category
- Target module and interface
- Description of attack scenario
- Risk rating (Critical/High/Medium/Low)
- Mitigation strategy
- Verification method (test case or control)
