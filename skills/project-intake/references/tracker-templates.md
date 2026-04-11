# Tracker file templates

Scaffolding content for each `project_tracker_convention` value. The skill fills placeholders and writes the result to the location specified in SKILL.md step 8. Keep the tracker minimal — it's a lightweight pointer, not a duplicate of the briefing. The real project context lives in `HANDOFF.md` and the user will read it there.

## Placeholders

| Placeholder | Value |
|---|---|
| `{{NAME}}` | Project name (directory basename) |
| `{{CREATED}}` | Today's date, `YYYY-MM-DD` |
| `{{DESCRIPTION}}` | One sentence pulled from the briefing. First sentence of `HANDOFF.md` or `README.md` if available; fall back to `"Intaken from handoff on {{CREATED}}"`. |
| `{{SOURCE}}` | `"handoff zip"`, `"URL"`, or `"folder copy"` |

## `_project_md_inside` → `<projects_path>/<name>/_project.md`

```markdown
---
name: {{NAME}}
status: active
created: {{CREATED}}
source: {{SOURCE}}
---

# {{NAME}}

{{DESCRIPTION}}

See `HANDOFF.md` for full project context from the sender.

## Status

Active — intaken on {{CREATED}}.

## Notes

_Add your own notes here as you work on the project._
```

## `sibling_md` → `<projects_path>/<name>.md`

Same content as `_project_md_inside`. The only difference is the file location — beside the project folder rather than inside it. Users who prefer flat metadata can scan their projects directory and see every tracker at a glance.

Remember: this file is written AFTER the move in Step 10, not before. Creating it inside staging and then trying to move it would place it inside the project folder, not beside it.

## `yaml_front` → `<projects_path>/<name>/.project.yaml`

```yaml
name: {{NAME}}
status: active
created: {{CREATED}}
source: {{SOURCE}}
description: "{{DESCRIPTION}}"
handoff_brief: "HANDOFF.md"
```

Pure YAML, no markdown. For users who prefer machine-readable metadata sidecars.

## `none`

No tracker file. Skip Step 8 entirely. The project still lands correctly, `HANDOFF.md` still gets preserved, git still gets initialized — just no tracker.

## Guidance on `{{DESCRIPTION}}`

- One sentence, not a paragraph. If the source opens with a multi-sentence intro, take the first one only.
- Don't include pending work, hard rules, deadlines, or env var instructions in the tracker. Those belong in `HANDOFF.md` — duplicating them here will rot when the user updates one copy and not the other.
- If `HANDOFF.md` exists but its opening line is something like `# Project Name` (a heading, not a sentence), skip the heading and take the next prose line.
- If nothing suitable can be extracted, use `"Intaken from handoff on {{CREATED}}"` verbatim.

## Collision with sender-provided trackers

If the incoming project already has `_project.md`, `.project.yaml`, or a sibling `<name>.md` that came with the handoff (rare — `/project-handoff` normally strips these), do NOT overwrite. Leave the sender's file in place, skip tracker creation for this invocation, and warn the user. They can decide whether to keep the sender's version, replace it, or merge by hand.
