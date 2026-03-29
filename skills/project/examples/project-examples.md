# /project Skill Examples

## Example 1: Simple Single-File Project

```
User: "Let's start a project for the morning briefing redesign"

Claude: Creates Projects/morning-briefing-redesign.md with:
- status: active (already working on it)
- tags: [project, heart, automation]
- Overview inferred from conversation context
- Opens in Obsidian

Output:
  Created: Projects/morning-briefing-redesign.md
  Status: active
  Opened in Obsidian.
```

## Example 2: Folder Project for Sales Prospect

```
User: "Create a project for Oak Hill Montessori"
(Context: user is doing prospect research for a school)

Claude: Infers folder format (school account = accumulates reference material)
Creates Projects/oak-hill-montessori/ with:
- _project.md (tracker)
- reference/
- deliverables/
- notes/
- status: active
- tags: [work, umbrella, sales, prospect]

Output:
  Created: Projects/oak-hill-montessori/
    _project.md (tracker)
    reference/
    deliverables/
    notes/
  Status: active
  Opened in Obsidian.

  Use /project-load oak-hill-montessori to load project context in future sessions.
```

## Example 3: Project Already Exists

```
User: "Create a project for Sejong Academy"

Claude: Finds Projects/sejong-academy/ already exists.
Asks: "A project already exists at Projects/sejong-academy/. Open existing, choose a different name, or overwrite?"

User: "Open existing"

Claude: Opens in Obsidian.
```

## Example 4: Explicit Folder Flag

```
User: "/project umbrella-website-rebuild --folder"

Claude: Asks for status and description.
Creates folder project with all subdirectories.
```

## Example 5: Organic Trigger Mid-Conversation

```
User: "We need to start tracking this insurance switch — there's a lot of moving parts"

Claude: Recognizes this as a project creation request.
Asks: "Want me to create a project for this? I'd suggest 'insurance-switch-state-farm' as the name."
Proceeds with creation flow.
```

## Example 6: With Waiting On Context

```
User: "Start a project for the Raptor implementation. We're waiting on Kyle for the updated quote."

Claude: Creates project and includes Waiting On table:
| Person | For What | Since | Follow-up By | Things3 Task |
|--------|----------|-------|--------------|--------------|
| Kyle | Updated Raptor quote | 2026-03-29 | 2026-04-06 | no |
```

## Format Decision Heuristics

| Context | Default Format |
|---------|---------------|
| Sales prospect / school account | Folder |
| Client engagement / bid | Folder |
| Multi-phase initiative | Folder |
| Skill build / dev task | Single-file |
| One-off planning doc | Single-file |
| Simple initiative tracker | Single-file |
| User says "lots of docs" or "reference material" | Folder |
| Unclear | Ask the user |
