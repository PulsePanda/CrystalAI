# Vault Templates and Structure

This directory contains vault templates and structural scaffolding for CrystalAI's Obsidian integration. When users run `/onboarding`, these files are copied into their configured vault path.

## Structure

```
vault/
├── Areas/
│   └── People/          Person files — one per person
├── _Templates/
│   └── person.md        Person file template
└── README.md
```

## Areas/People/

Person files are first-class vault objects. Each person you interact with regularly gets a markdown file that accumulates context over time. Files are created and updated by `/meeting`, `/process-inbox`, `/compress`, and the people-profiler agent.

See [docs/people-integration.md](../docs/people-integration.md) for full documentation.
