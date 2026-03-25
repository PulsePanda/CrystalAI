---
name: crystal:docs
description: This skill should be used when the user types "/docs", "update the docs", "update documentation", "document what we did", or wants to capture session learnings into the right permanent files. Scans session context and updates playbooks, project files, skill files, memory, and correction logs as appropriate.
version: 1.0.0
allowed-tools: Read, Write, Edit
---

# /docs - Update Documentation

Update relevant documentation based on recent work in this session.

## Usage

```
/docs           # Update all relevant docs from this session
/docs email     # Update email-related docs specifically
/docs [topic]   # Update docs for a specific topic/project
```

## What This Does

Review the current session and update:

1. **Playbook files** - Add new rules, patterns, sender rules learned
2. **Project files** - Update current state, decisions made, learnings
3. **Skill files** - Document new actions, workflows, or refinements
4. **Memory files** - Update MEMORY.md if significant patterns learned

## Workflow

1. **Scan session context** - What was worked on? What decisions were made?
2. **Identify docs to update:**
   - If email triage → `.claude/skills/process-email/playbook.md`, `Projects/email-triage.md`, `.claude/skills/email/SKILL.md`
   - If skill work → relevant skill's `SKILL.md`
   - If project work → `Projects/[project].md`
   - If workflow patterns → `~/.claude/projects/.../memory/MEMORY.md`
   - If behavioral rules changed → `state/behavioral/` domain files
   - If Austin corrected Claude → `state/operational/corrections.md`
   - If Austin's preferences/style observed → `state/behavioral/austin-preferences.md`
   - If resume/session flow changed → `.claude/skills/resume/SKILL.md`
3. **Read current state** of each doc
4. **Update with new info:**
   - New rules/patterns learned
   - Current state changes
   - Key decisions documented
   - Timestamps updated
5. **Report what was updated**

## What to Capture

- **New patterns** - Sender rules, subject patterns, action types
- **Decisions** - Why we do X instead of Y
- **Workflow refinements** - Better ways to handle things
- **Current state** - What's done, in progress, next
- **Learnings** - Things that didn't work, things that did

## Output

Brief summary of what was updated:

```
Updated:
- playbook.md: Added 3 sender rules
- email-triage.md: Updated current state, added learnings
- SKILL.md: Added new action type
```
