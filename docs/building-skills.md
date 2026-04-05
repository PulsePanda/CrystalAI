# Building Skills

How to create your own skills for CrystalAI.

---

## What Is a Skill?

A skill is a `SKILL.md` file inside a directory under `~/.claude/skills/`. When you type a trigger phrase (like `/resume` or "draft an email"), Claude matches it to a skill's description and follows the instructions in the file.

Skills are written in plain English. You don't need to code.

---

## File Structure

```
~/.claude/skills/
  my-skill/
    SKILL.md          # Required -- the skill definition
    references/       # Optional -- supporting docs the skill reads at runtime
    templates/        # Optional -- output templates
    scripts/          # Optional -- helper scripts
```

The only required file is `SKILL.md`.

---

## SKILL.md Format

Every SKILL.md has two parts: YAML frontmatter and a markdown body.

### Frontmatter

```yaml
---
name: my-skill
description: "One or two sentences describing WHEN this skill should trigger. Be specific about trigger phrases and what it should NOT trigger on."
version: 1.0.0
allowed-tools: Read, Write, Edit, Bash
---
```

| Field | Required | Purpose |
|-------|----------|---------|
| `name` | Yes | The slash command name (lowercase, hyphenated) |
| `description` | Yes | Tells Claude when to activate this skill. This is the most important field -- see below. |
| `version` | No | Version tracking for your own reference |
| `allowed-tools` | No | Which Claude Code tools the skill can use (e.g., Read, Write, Edit, Bash, Grep, Glob) |

### Body

The markdown body contains the instructions Claude follows when the skill triggers. Write it like you're explaining a procedure to a smart coworker: clear steps, expected inputs, expected outputs, and what to do when things go wrong.

---

## Writing a Good Description

The `description` field is how Claude decides whether to activate your skill. A vague description means the skill fires when it shouldn't (or doesn't fire when it should).

**Include:**
- What the skill does in one sentence
- Specific trigger phrases: "Trigger on: 'X', 'Y', 'Z'"
- What it should NOT trigger on: "Do NOT trigger for: [similar but different tasks]"

**Example of a weak description:**
```
description: Helps with standups
```

**Example of a strong description:**
```
description: "Generate a daily standup summary from yesterday's session logs and today's tasks. Trigger on: '/standup', 'standup', 'what did I do yesterday', 'standup update', 'daily update'. Do NOT trigger for: weekly reviews (use weekly), or general task listing (use resume)."
```

The `DO NOT trigger` section is how you prevent conflicts with similar skills.

---

## Minimal Example: Standup Skill

```markdown
---
name: standup
description: "Generate a daily standup summary from yesterday's session logs and today's tasks. Trigger on: '/standup', 'standup', 'what did I do yesterday', 'daily update'. Do NOT trigger for: weekly reviews (use weekly), or session start (use resume)."
version: 1.0.0
allowed-tools: Read, Grep, Glob
---

# Daily Standup

Generate a quick standup update: what I did yesterday, what I'm doing today, and any blockers.

## Steps

### Step 1: Yesterday's Work

Read the most recent session log from `${STATE_PATH}/sessions/`. Extract the key topics and outcomes.

If no session log exists for yesterday, say so -- don't make things up.

### Step 2: Today's Plan

If a task manager is configured, pull today's tasks. If not, check active projects for next steps.

### Step 3: Output

Present in standup format:

**Yesterday:** [1-3 bullet points from session log]
**Today:** [1-3 bullet points from tasks/projects]
**Blockers:** [any blockers, or "none"]

Keep it under 10 lines total.
```

Save this as `~/.claude/skills/standup/SKILL.md` and it's ready to use.

---

## Testing

Type the trigger phrase in a Claude Code session:

```
/standup
```

Or use natural language:

```
What did I do yesterday?
```

If it activates the wrong skill (or doesn't activate at all), adjust the `description` field -- add more trigger phrases or sharpen the `DO NOT trigger` list.

---

## Reference Files

For skills that need supporting data (templates, rules, lookup tables), put them in a `references/` subdirectory. Your skill instructions can reference them:

```markdown
Read `references/my-template.md` and use it as the output format.
```

Claude reads these files at runtime when the skill tells it to.

---

## Common Patterns

**Loading user config:** Reference `${CONFIG_PATH}` for user settings (task manager, calendar, notes app). Check before assuming an integration exists.

**State paths:** Use `${STATE_PATH}` to reference the CrystalAI state directory. Skills should read from and write to state -- not hardcode paths.

**Error handling:** Include a section on what to do when things fail. At minimum: "If [operation] fails, report the error and continue with the remaining steps."

**Composing with other skills:** Skills can invoke other skills. For example, `/compress` invokes `/docs` at the end. Reference them by name: "Invoke the `/docs` skill to update documentation."

---

## Making a Skill Config-Aware

If your skill ships as part of CrystalAI core, it gets overwritten on update. Users customize its behavior through a config file in `~/.claude/skill-configs/`. Here's how to wire that up.

### 1. Check for a Config File

At the start of your skill instructions, add a step that reads the config:

```markdown
### Step 0: Load Config

Read `~/.claude/skill-configs/<skill-name>.yaml` if it exists. If the file is missing, use these defaults:

- `some_setting`: "default_value"
- `another_setting`: true
- `pre_steps`: []
- `post_steps`: []
```

List every config field and its default value. The skill must work identically whether or not the config file exists.

### 2. Process `pre_steps`

Before your skill's main logic, check if the config defines `pre_steps`. If it does, invoke each skill in order:

```markdown
### Step 1: Pre-Steps

If the config defines `pre_steps`, invoke each skill in order before continuing. Each entry has a `skill` name and an optional `description`.
```

### 3. Do Your Thing

The rest of your skill runs as normal, using config values wherever the user might want to customize behavior.

### 4. Process `post_steps`

After your skill's main logic completes, check for `post_steps` and invoke each one:

```markdown
### Step N: Post-Steps

If the config defines `post_steps`, invoke each skill in order. Each entry has a `skill` name and an optional `description`.
```

### 5. Document Your Config Fields

Create an example config in `docs/skill-configs-examples/<skill-name>.yaml` with every field, its default value, and a comment explaining what it does. Users copy this file to `~/.claude/skill-configs/` and edit it.

### Full Pattern

```markdown
### Step 0: Load Config
Read `~/.claude/skill-configs/my-skill.yaml` if it exists. Defaults:
- `format`: "markdown"
- `pre_steps`: []
- `post_steps`: []

### Step 1: Pre-Steps
If config defines `pre_steps`, invoke each skill in order.

### Step 2: Main Logic
... your skill's actual work, using config values ...

### Step 3: Post-Steps
If config defines `post_steps`, invoke each skill in order.
```

See `docs/skill-configs.md` for the full system design and `docs/skill-configs-examples/` for real examples.
