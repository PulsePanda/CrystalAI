# Feasibility Assessment Guide

How the Planner determines whether a task can be accomplished with available capabilities.

## The Principle

Feasibility is not a vibes check. It's a concrete mapping: every step in the plan must map to at least one available capability. If a step can't be mapped, the task is partially or fully infeasible.

## Available Capabilities

### 1. Tools (built into the session)
- File operations (read, write, edit, glob, grep)
- Bash commands
- Web fetch/search
- Task management
- Agent spawning

### 2. Skills (`~/.claude/skills/`)
Read skill SKILL.md frontmatter for name and description. Skills carry the user's preferences and integration configs — they're more capable than raw tool use for their domains.

### 3. Agents (`~/.claude/agents/`)
~169 specialized agents across engineering, design, testing, specialized, game-dev, marketing, PM, sales, strategy, spatial-computing. Each has a specific competency described in its file.

### 4. MCP Servers (registered in the session)
Check available MCP servers for external integrations — Todoist, calendar, email, Proxmox, UniFi, n8n, etc.

## The Assessment Process

For each step in the plan:

1. **Identify the capability needed** — What tool, skill, agent, or MCP server can do this?
2. **Verify it exists** — Don't assume. Check the actual catalog/directory/server list.
3. **Check for gaps** — If no single capability covers the step, can a combination work?

## Avoiding Under-estimation

AI tends to say "I can't do that" when it actually can through a combination of tools. Before marking a step infeasible:

- Can multiple tools chain together to accomplish it? (e.g., web search → parse results → write file)
- Can an agent handle it even if you wouldn't know how from the description alone?
- Can an MCP server provide access you didn't initially consider?
- Can a skill handle a sub-task that you thought required manual work?

The question is not "do I have a dedicated tool for this?" but "can the available tools, combined creatively, accomplish this?"

## Feasibility Ratings

### FULLY FEASIBLE
Every step maps to one or more concrete capabilities. No gaps.

### PARTIALLY FEASIBLE
Most steps are covered, but some require capabilities that don't exist. Document which steps are blocked and what's missing. The orchestrator will decide whether to proceed with what's possible or escalate.

### NOT FEASIBLE
The core goal cannot be accomplished with available capabilities. The missing capabilities are fundamental, not peripheral. Examples:
- Task requires physical presence
- Task requires access to a system with no integration
- Task requires human judgment that can't be automated
