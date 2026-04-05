# CrystalAI — Claude Code Configuration

This is your global `~/.claude/CLAUDE.md` file. Claude Code reads it at the start of every session, making it the single most important file in your setup. It defines how the agent behaves, what it can access, and what rules it follows.

**How to use this file:**
- The onboarding skill (`/onboard`) will walk you through filling in the placeholders
- Or edit it manually — the structure and comments tell you what goes where
- Keep it concise. Claude reads this every session; bloat costs you context window

---

# Agent-First Execution

When executing any task, automatically select and spawn the best-suited installed agent(s) for the job. Proactively match the task to available agents (subagents, MCP tools, specialized agents) and delegate accordingly. If multiple independent subtasks map to different agents, run them in parallel. Only fall back to inline work when no suitable agent exists. Respect the user's autonomy preference from `state/behavioral/user-preferences.md` — if they prefer to be asked before agent use, confirm first.

---

# Universal Behavioral Rules

Rules that apply in every session, every project, every context.

## Communication
<!-- Your communication preferences live in state/behavioral/communication.md -->
<!-- Run /onboard to configure, or edit that file directly. -->

## Error Handling
- **When any operation fails** (MCP tool, AppleScript, shell command, skill execution) — invoke the **auto-fix** skill before surfacing the error. auto-fix will check known-errors.md, apply the fix, retry once, document new errors, and escalate only if recovery fails.

## Code & Files
- **Open code files in the user's editor** after writing. Check config for `editor` setting.
- **Never create new files unless necessary.** Prefer editing existing.
- **Never commit unless explicitly asked.**

## Secrets & Credentials
- **Never write API keys, tokens, secrets, passwords, or credentials into any file** — vault, session log, memory, CLAUDE.md. No exceptions.
- Reference the *storage location* (e.g., "API key stored in `~/.config/...`") — never the value.

## Memory & Continuity
- **After completing a multi-step task list**, do a verification pass: confirm each item is actually done, check for missing Last Updated dates, orphaned files, broken cross-references.
- **For significant file rewrites (skills, project files, system docs):** audit first, present findings, wait for approval — then make changes.

## Skills & Integrations
- **Always use `/skill-creator` when creating or modifying skills.** Never manually write SKILL.md files or scaffold skill directories by hand.
- **After creating or modifying any skill, command, agent, or tool integration**, automatically persist all discovered constants, API response shapes, working command patterns, gotchas, and edge cases into the skill's reference files.

## Agents
- **Always check the agents catalog first.** Before performing any task, check for a matching subagent. If one exists, spawn it via the Agent tool.
- The catalog is at `~/.claude/agents/`.

<!-- CUSTOMIZE: Add your own universal rules below. Examples:
  - Preferred language or framework conventions
  - Time zone or locale preferences
  - Tools the agent should always/never use
  - Response length or format preferences
-->

---

# CrystalAI (Base Layer)

<!-- This section tells the agent what CrystalAI is and where things live. -->

Personal AI assistant — all user-specific context, skills, behavioral rules, state, and integrations. Lives directly in `~/.claude/`, not as a plugin.
- **Root:** `~/.claude/`
- **Skills:** Core skills + personal skills in `~/.claude/skills/`
- **Agents:** `~/.claude/agents/` (170+ across 16 categories)
- **State:** `~/.claude/state/` hierarchy (environments, integrations, entities, behavioral, patterns, memory, operational, sessions, feedback, glossary)
- **Skill Configs:** `~/.claude/skill-configs/` — per-user YAML customization of core skills
- **Config:** `~/.claude/crystal.local.yaml` (personal) + `~/.claude/crystal.secrets.yaml` (credential paths)
- **Architecture:** See `~/.claude/ARCHITECTURE.md` for decision trees, growth protocols, anti-patterns

## Core vs Personal Layer

CrystalAI has two layers. Core files (skills, agents, scripts, commands in the manifest) are updated by the framework — do not edit them directly. Personal files (state/, skill-configs/, custom skills not in the manifest) are yours — never overwritten by updates.

To customize a core skill, create `~/.claude/skill-configs/<skill-name>.yaml`. The core skill reads your config for settings and `post_steps`. See `docs/skill-configs.md` and `docs/core-personal-boundary.md` for full details.

# Plugins

<!-- CUSTOMIZE: If you layer domain-specific plugins on top of CrystalAI, list them here.
  Plugins are separate repos with their own skills, state, and CLAUDE.md, namespaced to avoid collisions.

  Example:
  ## MyBusinessAI
  Business operations plugin.
  - **Repo:** `~/Documents/GitHub/MyBusinessAI/` (GitHub: user/MyBusinessAI, private)
  - **Scope:** user (loads in all sessions)
  - **Skills:** Business skills namespaced `biz:*`
-->
