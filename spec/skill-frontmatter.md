# Skill Frontmatter Spec

Each `SKILL.md` MUST start with YAML frontmatter.

Required keys:

- `name`
- `version`
- `owner`
- `maturity`
- `description`

Recommended:

- Set `name` to the exact skill directory id (lowercase kebab-case).
- Keep `version` aligned with the skill's `VERSION` file.
- Use RFC2119 keywords for normative requirements in the skill body.
