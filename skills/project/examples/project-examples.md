# /project Skill Examples

## Example 1: Simple Single-File Project

```
User: "Let's start a project for the morning briefing redesign"

Claude: Creates Projects/morning-briefing-redesign.md with:
- status: active (already working on it)
- tags: [project, automation]
- Overview inferred from conversation context
- Opens in Obsidian

Output:
  Created: Projects/morning-briefing-redesign.md
  Status: active
  Opened in Obsidian.
```

## Example 2: Folder Project for Client Engagement

```
User: "Create a project for Acme Corp"
(Context: user is doing client research)

Claude: Infers folder format (client = accumulates reference material)
Creates Projects/acme-corp/ with:
- _project.md (tracker)
- reference/
- deliverables/
- notes/
- status: active
- tags: [work, client]

Output:
  Created: Projects/acme-corp/
    _project.md (tracker)
    reference/
    deliverables/
    notes/
  Status: active
  Opened in Obsidian.

  Use /project-load acme-corp to load project context in future sessions.
```

## Example 3: Project Already Exists

```
User: "Create a project for Acme Corp"

Claude: Finds Projects/acme-corp/ already exists.
Asks: "A project already exists at Projects/acme-corp/. Open existing, choose a different name, or overwrite?"

User: "Open existing"

Claude: Opens in Obsidian.
```

## Example 4: Explicit Folder Flag

```
User: "/project website-rebuild --folder"

Claude: Asks for status and description.
Creates folder project with all subdirectories.
```

## Example 5: Organic Trigger Mid-Conversation

```
User: "We need to start tracking this — there's a lot of moving parts"

Claude: Recognizes this as a project creation request.
Asks: "Want me to create a project for this? I'd suggest 'insurance-switch' as the name."
Proceeds with creation flow.
```

## Example 6: With Waiting On Context

```
User: "Start a project for the vendor evaluation. We're waiting on Kyle for the updated quote."

Claude: Creates project and includes Waiting On table:
| Person | For What | Since | Follow-up By | Task Created |
|--------|----------|-------|--------------|--------------|
| Kyle | Updated quote | 2026-03-29 | 2026-04-06 | no |
```

## Format Decision Heuristics

| Context | Default Format |
|---------|---------------|
| Client engagement / bid | Folder |
| Multi-phase initiative | Folder |
| Skill build / dev task | Single-file |
| One-off planning doc | Single-file |
| Simple initiative tracker | Single-file |
| User says "lots of docs" or "reference material" | Folder |
| Unclear | Ask the user |
