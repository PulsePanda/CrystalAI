# Skills Quick Reference

All built-in skills that ship with CrystalAI. Type the slash command or any of the trigger phrases to activate a skill.

---

## Daily Workflow

| Skill | Trigger | What It Does | Example |
|-------|---------|--------------|---------|
| `/resume` | "good morning", "where were we", "catch me up" | Loads your last session context, today's calendar, tasks, and active projects. Start every session here. | "Good morning" |
| `/compress` | "save session", "I'm done", "goodnight", "wrap up" | Saves a searchable session log, extracts tasks, updates your daily note, and runs a hygiene pass. End every session here. | "Let's wrap up" |
| `/weekly` | "weekly review", "summarize this week", "Friday wrap-up" | Synthesizes the week's sessions into a digest, consolidates state, checks project hygiene, and surfaces upcoming commitments. | "Run the weekly review" |

## Writing & Communication

| Skill | Trigger | What It Does | Example |
|-------|---------|--------------|---------|
| `/write` | "draft", "compose", "reply to", "follow up with", "let them know" | Drafts emails, messages, or any content in your personal writing style. Learns from every correction you make. | "Draft an email to the client about the timeline change" |
| `/teach` | "learn my style", "here's how I write", "analyze my writing" | Analyzes writing samples you provide, extracts your voice patterns, and saves them so `/write` sounds like you. | "Here are three emails I sent last week -- learn my style" |

## Notes & Capture

| Skill | Trigger | What It Does | Example |
|-------|---------|--------------|---------|
| `/note` | "quick note", "jot this down", "new note" | Creates a timestamped capture in your inbox and opens it in your notes app. | "/note" |
| `/meeting` | "start a meeting note", "meeting with [person]", "about to hop on a call" | Creates a pre-filled meeting note with people, topic, and context from previous meetings, then opens it for live note-taking. | "Meeting with Kim about Q2 roadmap" |
| `/process-inbox` | "process my inbox", "clean up inbox", "triage inbox" | Transforms rough captures from your inbox into structured notes, routes meeting notes to the right folder, and creates tasks. | "What's in my inbox to process?" |

## Research & Analysis

| Skill | Trigger | What It Does | Example |
|-------|---------|--------------|---------|
| `/deep-research` | "deep research", "comprehensive analysis", "research report", "compare X vs Y" | Conducts multi-source research with citation tracking and verification. Produces a professional report with executive summary, findings, and recommendations. | "Deep research on the current state of local LLM deployment" |
| `/grill-me` | "grill me", "stress-test my plan", "poke holes in my idea", "challenge my thinking" | Interviews you relentlessly about a plan or design, one question at a time, until every branch of the decision tree is resolved. | "Grill me on whether this pricing model makes sense" |

## Project Management

| Skill | Trigger | What It Does | Example |
|-------|---------|--------------|---------|
| `/project` | "create a project", "this should be a project", "let's track this" | Creates a new project file (or folder with subdirectories) in your vault and opens it. | "Create a project for the website redesign" |
| `/project-load` | "load project X", "pull up X", "where are we on X", "file this in project X" | Loads all context for an existing project, lists all projects, or files documents into a project's folder structure. | "Pull up the CrystalAI project" |

## Scheduling

| Skill | Trigger | What It Does | Example |
|-------|---------|--------------|---------|
| `/calendar-booking` | "book time", "schedule a meeting", "find a time", "when am I free" | Checks your real calendar availability, selects the best slots, and either creates an event or drafts a scheduling email. | "Set up a call with the vendor next week" |

## Session Management

| Skill | Trigger | What It Does | Example |
|-------|---------|--------------|---------|
| `/docs` | "update the docs", "persist this", "save what we learned" | Mid-session documentation capture. Scans the current session and updates project files, skill files, memory, and behavioral rules without ending the session. | "Document what we did" |
| `/feedback` | "stop doing X", "from now on", "that's wrong", "don't do that" | Permanent correction handler. Logs corrections, routes them to the right files, and ensures you never have to repeat yourself. Fires automatically on corrections. | "No emojis, ever" |

## System / Internal

| Skill | Trigger | What It Does | Example |
|-------|---------|--------------|---------|
| `/onboard` | "set up CrystalAI", first run after install | First-run setup wizard. Detects your environment, interviews you about preferences, generates config files, validates integrations, and guides you through creating your first skill. | "/onboard" |
| `/auto-fix` | (internal -- triggered automatically on errors) | Automatic error recovery. Diagnoses failures, applies known fixes, retries the operation, and documents new errors. Other skills call this instead of surfacing raw errors. | (not invoked directly) |

---

## Tips

- **You don't need to memorize trigger phrases.** Talk naturally -- "I need to schedule something with Alex" activates `/calendar-booking` without you typing the slash command.
- **Corrections are permanent.** If a skill does something wrong, say so. `/feedback` fires and it never happens again.
- **Skills compose.** `/compress` calls `/docs` automatically. `/calendar-booking` can call `/write` to draft the scheduling email. You don't need to chain them manually.
