# ASCN Skills

Multi-skill repository for [ascn.ai](https://ascn.ai)

## Goals

- Keep each skill isolated and versioned.
- Make skills easy to discover, validate, and package.
- Keep normative behavior contract-first and testable.

## Repository Layout

- `skills/`: all installable skills (one directory per skill)
- `template/`: starter scaffold for new skills
- `spec/`: repository and skill authoring rules
- `.claude-plugin/`: plugin metadata and skill index for tooling
- `skills/index.yaml`: human-readable skill catalog index
- `.github/`: ownership and repo automation metadata

Example tree:

```text
.
├── .claude-plugin/
├── skills/
│   ├── ascn-operator/
│   └── ascn-integrations/
├── spec/
└── template/
    └── skill-template/
```

## Skill Catalog

Current skills:

- `ascn-operator`: deterministic workflow lifecycle and tool export operator for ASCN workspace MCP control tools.
- `ascn-integrations`: deterministic guide for designing missing capability and packaging it into user-visible plugins.

## Working With Skills

1. Copy `template/skill-template` into `skills/<new-skill-id>`.
2. Fill `SKILL.md`, `contracts/`, and `agents/openai.yaml`.
3. Add scenario files under `contracts/scenarios/`.
4. Register the skill in `.claude-plugin/skills.json`.
5. Register the skill in `skills/index.yaml`.
6. Update this README catalog.
7. Run `./scripts/validate-skills.sh`.

## Compatibility

- Skill folder convention: `skills/<skill-id>/`
- Each skill must include: `SKILL.md`, `README.md`, `VERSION`, `CHANGELOG.md`, `contracts/`, `references/`, `agents/`
- Skill docs should use RFC2119 keywords for normative behavior.
- Validation gate: `./scripts/validate-skills.sh`
