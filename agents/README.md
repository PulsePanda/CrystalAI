# Agents

170+ specialized sub-agents that Claude Code can spawn for complex tasks. Each agent has its own system prompt and domain expertise.

## How to Use Them

Claude automatically selects agents when a task matches their specialty. You can also request one directly:

```
Use the code reviewer agent to review this PR.
Run the security engineer agent against this codebase.
Have the UX researcher evaluate this user flow.
```

## Categories

| Category | Count | Examples |
|----------|-------|---------|
| Engineering | 23 | Software Architect, Code Reviewer, Frontend Dev, Backend, DevOps, Security, Database |
| Marketing | 26 | Content Creator, SEO, Social Media, LinkedIn, TikTok, Instagram, Reddit |
| Specialized | 25 | AI Engineer, MCP Builder, Data Engineer, Blockchain, Embedded Firmware |
| Game Development | 20 | Unity, Unreal, Godot, Roblox, Narrative Design, Level Design, Game Audio |
| Strategy | 16 | Growth Hacker, Brand Guardian, Supply Chain, ZK Steward |
| Design | 8 | UI Designer, UX Researcher, UX Architect, Visual Storyteller |
| Testing | 8 | API Tester, Performance Benchmarker, Accessibility Auditor, Evidence Collector |
| Sales | 8 | Sales Engineer, Deal Strategist, Discovery Coach, Account Strategist |
| Paid Media | 7 | PPC Strategist, Paid Social, Programmatic, Ad Creative, Tracking |
| Spatial Computing | 6 | visionOS, WebXR, XR Interface, macOS Metal |
| Project Management | 6 | Senior PM, Jira Steward, Sprint Prioritizer, Studio Producer |
| Support | 6 | Support Responder, Infrastructure Maintainer, Legal Compliance |
| Product | 4 | Trend Researcher, Feedback Synthesizer, Experiment Tracker |

## How Agents Work

Each agent file is a markdown document with YAML frontmatter defining its name, description, and tools. The body is the system prompt. When Claude spawns an agent via the `subagent_type` parameter, it runs in its own context and returns results to the parent session.

## Adding Your Own

Create a markdown file in the appropriate category directory:

```markdown
---
name: My Custom Agent
description: One-sentence description of what this agent does.
---

You are a [role]. You specialize in [domain].

## Responsibilities
- ...

## Rules
- ...
```

Write the description so Claude can match it to user intent. Keep the system prompt focused — an agent that tries to do everything is worse than the base model.

## Attribution

Agent catalog based on [The Agency](https://github.com/msitarzewski/agency-agents) by Mike Sitarzewski, with additions and modifications.
