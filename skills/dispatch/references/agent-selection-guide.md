# Agent Selection Guide

How to match task steps to the right agents from the catalog.

## The Catalog

~169 agents at `~/.claude/agents/`, organized by category:

| Category | Domain | Path |
|----------|--------|------|
| engineering/ | Build, code, infrastructure, DevOps, security, data | `~/.claude/agents/engineering/` |
| design/ | Visual, UX, brand, accessibility | `~/.claude/agents/design/` |
| testing/ | QA, validation, benchmarking, performance | `~/.claude/agents/testing/` |
| specialized/ | Domain experts (MCP, legal, compliance, training, docs) | `~/.claude/agents/specialized/` |
| game-development/ | Unity, Unreal, Godot, Blender, game design | `~/.claude/agents/game-development/` |
| marketing/ | Content, social, SEO, growth | `~/.claude/agents/marketing/` |
| project-management/ | PM, studio ops, sprint planning | `~/.claude/agents/project-management/` |
| sales/ | Deals, proposals, pipelines, coaching | `~/.claude/agents/sales/` |
| strategy/ | Multi-phase project playbooks | `~/.claude/agents/strategy/` |
| spatial-computing/ | VR/AR/XR, visionOS | `~/.claude/agents/spatial-computing/` |

## Quick-Match Table

Covers ~80% of tasks. Use this before scanning the full catalog.

| Step Type | Agent (subagent_type) |
|-----------|----------------------|
| System/software architecture | Software Architect |
| Backend / API / data pipeline | Backend Architect |
| Frontend / UI / web | Frontend Developer |
| Mobile app | Mobile App Builder |
| Infrastructure / DevOps / CI/CD | DevOps Automator |
| Database schema / queries | Database Optimizer |
| Visual / UI design | UI Designer |
| UX flows / information architecture | UX Architect |
| Documentation / README / guides | Technical Writer |
| Security review / hardening | Security Engineer |
| Curriculum / training / course | Corporate Training Designer |
| Fast prototype / MVP | Rapid Prototyper |
| Code review | Code Reviewer |
| API testing | API Tester |
| Performance testing | Performance Benchmarker |
| Accessibility audit | Accessibility Auditor |

## For Non-Build Tasks

Many dispatch tasks aren't "builds" — they're operational work. For those, the executor often doesn't need a specialized agent at all. It just needs to invoke the right skills:

| Task Type | Primary Mechanism |
|-----------|------------------|
| Email drafting | `/write` skill |
| Meeting scheduling | `/calendar-booking` skill |
| Contact lookup | Entity files in `state/entities/` |
| Todoist task management | `/todoist` skill |
| Research | `/deep-research` skill or web search tools |
| Content creation | `/content-build` skill |
| Google Workspace admin | `/umb:gam` skill |

When the task is operational, the executor IS the agent — you don't need to match it to a catalog agent. Just use Opus with access to the relevant skills.

## Full Catalog Scan

For anything not in quick-match:

1. Narrow to the relevant category directory
2. Read first 10 lines of each `.md` file for `name` and `description` frontmatter
3. Match the step description against agent descriptions
4. Select the best fit

## Team Composition

| Size | When |
|------|------|
| **Solo** (1 executor) | Single-domain task, operational work |
| **Duo** (2 executors) | Two distinct domains (e.g., backend + frontend) |
| **Squad** (3-5 executors) | Complex multi-domain (full app, game prototype) |

**Cap: 5 executors.** If decomposition yields 6+, combine related steps under one executor or split into sequential phases.
