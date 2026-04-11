# CLAUDE.md Template for Project Handoff

This is the fillable skeleton for the AI operating manual that gets written into the staged project copy. It's not a form — every section has inline guidance on *what makes a good fill*. Read the guidance, then write in the voice of someone briefing a smart coworker who knows nothing about this project but needs to be productive in 15 minutes.

**Before you start filling:** read the whole template once so you know what you're aiming for. Then inspect the source project and decide which sections apply — it's better to delete a section than to fill it with "N/A" or generic filler.

**Delete these author instructions from the final output.** The recipient should see only the filled-in manual, not this meta commentary.

---

## Template begins below this line

```markdown
# {{Project Name}}

> **This file is an operating manual for AI coding assistants (Claude Code, Cursor, etc.). Read it fully before making any changes to this repo.** Claude Code loads this automatically on session start.

---

## What this project is

<!--
AUTHOR GUIDANCE: Write 1-3 paragraphs that answer:
- What is this product/project?
- Who is it for?
- What's the brand voice/tone if applicable?
- What's intentional that an outside reader might try to "fix"?

Include any "this is a feature, not a bug" notes that would prevent an AI from softening a deliberate design choice. Mark deliberate weirdness explicitly — the next AI will respect it if told, and override it if not told.

BAD: "A website for a handyman business."
GOOD: "A marketing website for Alibi Professional Services, a yard work and cleanup business in central Minnesota. The brand voice is darkly humorous mafia-themed — the company name is the joke. The visual identity is intentionally aggressive: black + crime-scene-yellow, condensed display type, case-file formatting. This tone is a feature, not a bug. Do not soften it without being told to."
-->

{{Project brief here.}}

---

## Tech stack

<!--
AUTHOR GUIDANCE: List the framework, styling approach, language(s), runtime, and any dependencies that matter. Note explicit "we do NOT use X" choices that would save the next AI from suggesting them.

Infer from package.json / pyproject.toml / Cargo.toml / go.mod. Don't list every transitive dep — only top-level decisions.
-->

- **Framework:** {{e.g., Astro 5, Next.js 14, Django 5, FastAPI, Rails 7}}
- **Language:** {{e.g., TypeScript, Python 3.11, Rust 1.75}}
- **Styling:** {{e.g., "plain CSS, no framework, all styles in one global block" / "Tailwind 3" / "N/A — backend service"}}
- **Frontend framework:** {{e.g., React, Vue, Svelte, "none — SSR only"}}
- **Database:** {{e.g., Postgres, SQLite, "none — fully static"}}
- **Dependencies:** {{list top-level runtime deps. Note "don't add more without a reason" if the intent is to stay minimal.}}

---

## Getting started

```bash
{{install command}}       # e.g., npm install / poetry install / cargo build
{{dev command}}           # e.g., npm run dev / python manage.py runserver
{{build command}}         # e.g., npm run build / cargo build --release
{{test command}}          # if applicable
```

{{Prerequisites: Node version, Python version, system packages, database setup, env vars. Anything the recipient needs installed before the install command will work.}}

---

## Project structure

```
{{tree of the important directories and files — not a full find output, just the landmarks that matter}}
```

<!--
AUTHOR GUIDANCE: Show only the load-bearing paths. For each, a one-line comment explaining what lives there. Skip config files unless they're non-obvious. Skip the entire node_modules / dist / build output.

Length target: 15-40 lines. If it's longer than 40 lines, you're listing too much.
-->

---

## Design system — do not invent new tokens

<!--
AUTHOR GUIDANCE: Include this section ONLY if the project has a distinctive visual identity. For backend services, CLIs, libraries, or other non-visual projects, DELETE this section entirely.

For visual projects: list color tokens (with hex codes), typography (with font names), spacing conventions, layout constants. Anything that would let the next AI make a consistent change without reinventing.

Format colors as a table. Format fonts as a short list with usage notes.
-->

### Colors

| Token | Hex | Usage |
|---|---|---|
| `{{--token-name}}` | `{{#HEX}}` | {{what it's for}} |

### Typography

- **{{Display font}}** — {{usage: headlines, all-caps, etc.}}
- **{{Body font}}** — {{usage}}
- **{{Mono font}}** — {{usage if applicable}}

### Layout conventions

- {{max content width, section padding, breakpoint strategy, card style, any other repeating visual pattern}}

---

## Voice / copy rules

<!--
AUTHOR GUIDANCE: Include this section ONLY if the project has a distinctive brand voice that a writer could get wrong. For utilities, libraries, internal tools: DELETE this section.

For branded projects: give 3 examples of copy that WORKS and 3 examples of copy that DOESN'T. This is the single highest-leverage thing you can do to prevent AI-generated copy from going generic.
-->

The voice is {{describe in one phrase: "dry understatement", "earnest and educational", "enthusiastic but not cheesy", etc.}}.

Examples that work:

- *"{{example 1}}"*
- *"{{example 2}}"*
- *"{{example 3}}"*

Examples that would NOT fit (do not write copy like this):

- "{{counter-example 1}}" ({{why it's wrong}})
- "{{counter-example 2}}" ({{why it's wrong}})
- "{{counter-example 3}}" ({{why it's wrong}})

When writing new copy, match the rhythm of the existing pages: {{describe key rules — sentence length, tone, things to avoid like emoji or exclamation points}}.

---

## Current state

### Done

<!--
AUTHOR GUIDANCE: Checkbox list of what's complete. Keep it factual, not promotional. This is a working document, not a marketing brochure.
-->

- [x] {{thing 1}}
- [x] {{thing 2}}
- [x] {{thing 3}}

### Pending — explicitly not done yet

<!--
AUTHOR GUIDANCE: Checkbox list of what's deliberately unfinished. For each pending item, explain WHY it's not done — "blocked on X", "waiting for Y", "placeholder until Z arrives". This prevents the next AI from treating a placeholder as a bug to fix.
-->

- [ ] **{{item 1}}** — {{why it's pending}}
- [ ] **{{item 2}}** — {{why it's pending}}

---

## Hard rules — don't break these

<!--
AUTHOR GUIDANCE: Numbered list of "don't do X" rules with explanations. 5-8 rules is the sweet spot. Each rule should have a "why" — the next AI will respect rules it understands, and override rules that sound arbitrary.

Common candidates:
- Don't add CSS frameworks / preprocessors if the project uses plain CSS
- Don't install X or Y dependency without checking first
- Don't convert the project to SSR / SPA / whatever the opposite is
- Don't edit the preserved baseline file
- Don't rename load-bearing files
- Don't soften the brand voice
- Don't remove placeholders that look like bugs
-->

1. **{{rule 1}}** — {{reason}}
2. **{{rule 2}}** — {{reason}}
3. **{{rule 3}}** — {{reason}}

---

## How to make common changes

<!--
AUTHOR GUIDANCE: Cheat sheet for the 4-6 changes the next developer is most likely to make. For each, name the file(s) and the key section to edit. This saves them a 10-minute hunt.
-->

### {{Common change 1}}

{{file path and what to edit}}

### {{Common change 2}}

{{file path and what to edit}}

### {{Common change 3}}

{{file path and what to edit}}

---

## Commands reference

```bash
# Development
{{command}}                 # {{what it does}}
{{command}}                 # {{what it does}}

# Building
{{command}}                 # {{what it does}}

# Testing
{{command}}                 # {{what it does}}

# Deployment
{{command}}                 # {{what it does}}
```

---

## Deployment

<!--
AUTHOR GUIDANCE: Include if the project is deployed anywhere (or will be). Skip if it's a library / internal tool / not-yet-deployed.

List: where it deploys, build command, output directory, any pre-deploy checklist (env vars, DNS, webhooks to activate, etc.).
-->

This project builds to `{{output directory}}` and is designed to deploy to {{target platform(s)}}.

**Before deploying to production:**

1. {{pre-deploy step 1}}
2. {{pre-deploy step 2}}
3. {{pre-deploy step 3}}

---

## Why this file exists

This file exists so that any AI coding assistant picking up this repo can:

1. Understand the project, its voice, and its constraints without re-reading the whole codebase
2. Avoid the design-system mistakes that would require re-litigation
3. Know what's done, what's pending, and what's intentionally undone
4. Not break the load-bearing pieces by changing the wrong file

If you're an AI agent reading this: the human handing you this repo has already been through several rounds of iteration and has settled on the current setup deliberately. Treat the existing design system, tech stack, voice, and hard rules as given. Ask before adding new colors, fonts, dependencies, or soft-voice copy.
```

---

## Template ends above this line

Notes on filling the template:

- **Length target:** 200-500 lines of filled-in output is healthy. Under 150 suggests you didn't dig deep enough. Over 700 suggests you're dumping instead of briefing.
- **Tone:** direct, factual, slightly caffeinated. Not marketing copy. Not documentation-voice either — write like you're talking to a smart colleague who's onboarding.
- **Avoid generic statements.** "This project uses best practices" is content-free. "We use plain CSS in a single global block because the designer hates maintaining multiple stylesheets" is actual context.
- **When in doubt, include the why.** A rule with a reason is followed. A rule without one gets ignored.
