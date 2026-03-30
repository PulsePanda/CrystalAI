---
name: docs
description: This skill should be used when the user types "/docs", "update the docs", "update documentation", "document what we did", or wants to capture session learnings into the right permanent files. Scans session context and updates project files, skill files, memory, and behavioral rules as appropriate.
version: 1.0.0
allowed-tools: Read, Write, Edit
---

# /docs - Update Documentation

Update relevant documentation based on recent work in this session.

## Usage

```
/docs           # Update all relevant docs from this session
/docs [topic]   # Update docs for a specific topic/project
```

## What This Does

Review the current session and update:

1. **Project files** - Update current state, decisions made, learnings
2. **Skill files** - Document new actions, workflows, or refinements
3. **Memory files** - Update MEMORY.md if significant patterns learned
4. **Behavioral rules** - Update preferences or corrections if new ones established

## Workflow

1. **Scan session context** - What was worked on? What decisions were made?
2. **Identify docs to update:**
   - If project work → `${VAULT_PATH}/Projects/[project].md` or `[project]/_project.md`
   - If skill work → relevant skill's `SKILL.md`
   - If workflow patterns → project MEMORY.md
   - If behavioral rules changed → `${STATE_PATH}/behavioral/` files
   - If the user corrected the assistant → `${STATE_PATH}/operational/corrections.md`
   - If preferences/style observed → `${STATE_PATH}/behavioral/user-preferences.md`
3. **Read current state** of each doc
4. **Update with new info:**
   - New rules/patterns learned
   - Current state changes
   - Key decisions documented
   - Timestamps updated
5. **Report what was updated**

## What to Capture

- **New patterns** - Workflow patterns, action types, integration details
- **Decisions** - Why we do X instead of Y
- **Workflow refinements** - Better ways to handle things
- **Current state** - What's done, in progress, next
- **Learnings** - Things that didn't work, things that did

## Output

Brief summary of what was updated:

```
Updated:
- project-name.md: Updated current state, added learnings
- SKILL.md: Added new action type
- corrections.md: Logged 1 correction
```
