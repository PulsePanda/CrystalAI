---
name: core-skill-creator
description: Trigger on "create a core skill", "new core skill", "build a core skill", "/core-skill-creator", or when the user explicitly says a skill should be part of the core framework. Wraps skill-creator with a mandatory design grilling phase to ensure core skills meet quality standards. Do NOT trigger for personal skills — those go straight to /skill-creator.
version: 1.0.0
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Agent, AskUserQuestion
---

# Core Skill Creator

Wrapper around /skill-creator that enforces a design grilling phase before building. Core skills ship to all CrystalAI customers and get overwritten on update — they need higher quality standards than personal skills.

## Configuration

This skill reads from `~/.claude/skill-configs/core-skill-creator.yaml` if present. Available options:
- `grill_depth`: How thorough the design grilling should be — "quick" (5 questions), "standard" (10 questions), "deep" (until all branches resolved). Default: standard.
- `auto_verify`: Whether to automatically run the post-build verification. Default: true.
- `post_steps`: Additional skills to run after creation.

## Execution

### Phase 1: Design Grilling

Run a focused /grill-me style interview on the skill design. Work through these branches one question at a time, depth-first, until each is resolved:

1. **Scope** — What does this skill do? What does it explicitly NOT do?
2. **Trigger** — What description and trigger phrases activate it? Is there ambiguity with existing skills?
3. **Input/Output contract** — What does the skill receive? What does it produce? What format?
4. **Overlap** — What existing skills does it overlap with? How is the boundary drawn?
5. **Configuration** — What should be user-configurable via skill-configs? What are sensible defaults?
6. **Edge cases** — What happens with bad input? Missing context? Partial failures?
7. **Core vs. personal** — Is this actually a core skill (useful to all customers) or should it be personal?
8. **Convention compliance** — Does the design use `${VAULT_PATH}` and `${STATE_PATH}` instead of hardcoded paths? Does it have a Configuration section referencing skill-configs?

Follow the /grill-me pattern: one question per turn, depth-first, push back on vague answers. Adjust question count based on `grill_depth` config.

Do not proceed to Phase 2 until all branches are resolved.

### Phase 2: Design Document

Capture the grilling results into a brief design spec:

```
## Design Spec: [skill-name]

**Scope:** [1-2 sentences]
**Triggers:** [trigger phrases]
**Input:** [what it receives]
**Output:** [what it produces]
**Config options:** [list]
**Overlap notes:** [how it relates to existing skills]
**Edge cases addressed:** [list]
**Key decisions:** [from the grilling]
```

Present this to the user for approval before building.

### Phase 3: Build

Invoke `/skill-creator` (the plugin skill `skill-creator:skill-creator`) with the validated design spec as context. Pass the full design document so skill-creator has everything it needs.

### Phase 4: Verify

If `auto_verify` is enabled, check the generated SKILL.md against core skill conventions:

- [ ] Has a `## Configuration` section referencing `~/.claude/skill-configs/[skill-name].yaml`
- [ ] Uses `${VAULT_PATH}` and `${STATE_PATH}` — no hardcoded paths
- [ ] Description has proper trigger phrases
- [ ] No Austin-specific or personal references (names, personal paths, personal integrations)
- [ ] Has proper frontmatter (name, description, version)
- [ ] Allowed-tools list is minimal and appropriate

Report any violations and fix them before finishing. If violations require design changes, flag them to the user rather than silently fixing.
