# Skill Configs

How users customize core skill behavior without editing skill files.

---

## The Problem

Core skills ship with CrystalAI and get overwritten on update. If you edit a core skill directly, your changes disappear next time you pull.

## The Solution

Skill configs are YAML files that live in your personal layer. Core skills read them at startup and adjust their behavior accordingly. Skill logic updates; your customizations persist.

---

## Where Configs Live

```
~/.claude/skill-configs/
  resume.yaml
  compress.yaml
  process-email.yaml
  ...
```

Each file is named after the skill it configures: `<skill-name>.yaml`.

These files are personal layer -- CrystalAI updates never touch them.

---

## How It Works

1. A core skill starts executing.
2. It checks for `~/.claude/skill-configs/<skill-name>.yaml`.
3. If the file exists, it reads the config and applies the settings.
4. If the file doesn't exist, it uses built-in defaults.

Zero config by default. Every core skill works out of the box without a config file.

---

## Standard Fields

Every skill config supports these fields. Skill authors don't need to implement them -- the config loading convention handles them automatically.

### `post_steps`

Array of skills to trigger after the main skill completes. Each entry has:

| Field | Required | Purpose |
|-------|----------|---------|
| `skill` | Yes | Name of the skill to invoke (e.g., `jobs`, `docs`) |
| `description` | No | Why this step runs -- helps with debugging and readability |

```yaml
post_steps:
  - skill: jobs
    description: "Check job board status after loading session context"
  - skill: docs
    description: "Update documentation"
```

### `pre_steps`

Array of skills to trigger before the main skill runs. Same format as `post_steps`. Less common, but available when you need setup work before a skill executes.

```yaml
pre_steps:
  - skill: calendar-sync
    description: "Sync calendar data before resume loads it"
```

---

## Skill-Specific Fields

Beyond the standard fields, each skill defines its own config options. These are documented in the example configs (see `docs/skill-configs-examples/`) and in the skill's own `SKILL.md`.

Examples of skill-specific fields:

- `/resume`: `calendars`, `lookahead_days`
- `/compress`: `transcript_path`, `todoist_reconcile`
- `/process-email`: `accounts`, `training_mode`

---

## Creating a Config

1. Find the example config in `docs/skill-configs-examples/`.
2. Copy it to `~/.claude/skill-configs/`:
   ```bash
   cp docs/skill-configs-examples/resume.yaml ~/.claude/skill-configs/resume.yaml
   ```
3. Edit to taste.

Or create one from scratch -- just name it `<skill-name>.yaml` and add the fields you want to override.

---

## Tips

- **You don't need a config file for every skill.** Only create one when you want to change defaults.
- **Partial configs are fine.** Only include the fields you want to override. Missing fields fall back to the skill's built-in defaults.
- **`post_steps` is the most common customization.** It lets you chain skills into personal workflows without editing any skill code.
- **Config files are plain YAML.** No special syntax, no templating -- just key-value pairs and arrays.
