# Contributing

## Scope

This repository hosts multiple skills. Treat each folder under `skills/` as an API-like unit.

## Required Before Merge

1. Keep changes scoped to the affected skill(s).
2. For behavior/contract changes, update the skill's `VERSION` and `CHANGELOG.md`.
3. Keep skill documents internally consistent (`SKILL.md`, `contracts/`, `references/`, `agents/`).
4. Add or update at least one scenario in `contracts/scenarios/` for behavior changes.
5. If you add a skill, register it in `.claude-plugin/skills.json`, `skills/index.yaml`, and root `README.md`.
6. Run `./scripts/validate-skills.sh` and ensure it passes.

## Authoring Rules

- Use deterministic call order for mutation-capable skills.
- Use explicit error mapping and recovery behavior.
- Prefer contract-encoded requirements over prose-only requirements.
- Keep user decision templates synchronized with contracts and agent profile docs.

## Review Checklist

- Does this change alter required inputs?
- Does this change alter execution order?
- Does this change alter output contract fields?
- Are scenario files still valid and representative?
- Did skill indexes/catalog entries get updated?
