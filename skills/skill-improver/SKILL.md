---
name: crystal:skill-improver
description: Runs an iterative test-evaluate-change loop to improve any skill's reliability and output quality. Use this whenever the user wants to improve, fix, test, or optimize a skill — including phrases like 'make this skill better', 'this skill keeps failing', 'my skill isn't doing X right', 'test this skill', or '/skill-improver'. Spawns parallel subagents to run batches of tests, evaluates outputs against binary pass/fail criteria, makes targeted single changes, and keeps or reverts based on pass rate. Stops when the pass rate plateaus or the user says stop.
---

# Skill Improver

Runs a tight optimization loop on a skill: test → evaluate → change → retest → keep or revert. Repeat until the pass rate plateaus or you're told to stop.

## Step 1: Locate the skill

Vault skills live at:
`/Users/Austin/Library/Mobile Documents/iCloud~md~obsidian/Documents/VaultyBoi/.claude/skills/<skill-name>/SKILL.md`

Read the SKILL.md for the target skill before doing anything else. You need to understand what it's supposed to do and how it works.

## Step 2: Clarify criteria

The user must provide binary (yes/no), explicitly measurable criteria. Example:
- "Does the note contain the required frontmatter?" ✓ (binary, checkable)
- "Is the note good quality?" ✗ (subjective — ask the user to restate it)

If criteria aren't binary and measurable, stop and ask before proceeding.

## Step 3: Run a test batch (subagents)

Default batch size: 5. Use whatever the user specifies if provided.

Spawn all runs in parallel as subagents. Each subagent gets:
- The skill path
- A test prompt (either user-provided or a realistic prompt you construct that exercises the skill)
- Instructions to save outputs to: `/tmp/skill-improver/<skill-name>/cycle-<N>/run-<i>/`

This is important — parallel subagents cut wall time dramatically vs. sequential runs. Don't wait for one to finish before launching the next.

## Step 4: Evaluate and report

Once all runs complete, evaluate each output against every criterion. Present results as a table:

| Run | Criterion 1 | Criterion 2 | Criterion 3 | Pass Rate |
|-----|-------------|-------------|-------------|-----------|
| 1   | ✓           | ✗           | ✓           | 2/3       |
| ... |             |             |             |           |
| **Cycle total** | | | | **X/Y** |

## Step 5: Change something (cycles 2+)

On the first cycle, run the skill as-is (baseline). Starting cycle 2, make one targeted change before running.

Try changes in this order — start with the ones most likely to fix observable failures:

1. **Add or improve examples** — if outputs are going in the wrong direction, a concrete example often corrects it faster than more instructions
2. **Clarify ambiguous language** — find vague phrases ("appropriately", "if needed") and make them concrete
3. **Specify output format explicitly** — if the format is inconsistent, add an exact template
4. **Reorder sections** — put the most critical constraint first; Claude reads top-down and early context shapes behavior
5. **Add "don't do X" constraints** — when the skill does extra unwanted things, explicit prohibitions help
6. **Tighten language** — remove redundancy and filler that dilutes the important instructions
7. **Split complex steps** — if a step is doing too much, break it into sub-steps with clear checkpoints

Make only one change per cycle so you know what worked.

## Step 6: Keep or revert

- Pass rate improved → keep the change
- Pass rate same or lower → revert and try a different change

## Stopping criteria

Stop the loop when:
- Pass rate plateaus (no improvement across 3 consecutive cycles) — tell the user and summarize what was tried
- You've run 10 cycles — present a summary and ask if the user wants to continue
- The user stops the session

## Known limitation

Skills that produce actions rather than files (Things3 tasks, calendar events, AppleScript) are harder to evaluate programmatically. For these, the "output" to evaluate is whatever observable state change occurred — ask the user to define how to verify it before starting.
