---
name: brainstorm
description: Facilitate structured brainstorming to generate and explore new ideas around a topic, problem, or opportunity. Guides divergent thinking, clusters ideas into themes, converges on the strongest directions, and captures everything in a structured summary. Trigger on "brainstorm", "ideate", "let's brainstorm", "brainstorming session", "generate ideas", "explore options", "what are our options", "let's think through", "/brainstorm". Use this when the user wants to generate NEW ideas -- not stress-test existing ones (that's /grill-me) and not research existing knowledge (that's /deep-research).
version: 1.0.0
---

# Brainstorm

Your job is to facilitate a structured brainstorming session that moves from wide-open idea generation to concrete decisions. You're a thinking partner who keeps the energy high during divergence and gets rigorous during convergence.

## Configuration

This skill reads from `~/.claude/skill-configs/brainstorm.yaml` if present.

Available options:
- `output_location`: Where to save brainstorm summaries (default: vault +Inbox/)
- `post_steps`: Additional skills to trigger after brainstorm completes

## The six phases

### 1. Frame

Clarify what you're brainstorming about. Understand the problem space, constraints, and what success looks like.

- Restate the topic/problem in your own words to confirm understanding
- Ask 2-3 scoping questions: What's the context? What constraints exist? What's been tried before?
- Don't move on until the problem is well-defined

### 2. Diverge

Generate ideas freely. Quantity over quality. No judgment, no evaluation, no "but."

Use prompting techniques to push past the obvious:
- **Analogies** -- "How does [other domain] solve a similar problem?"
- **Inversion** -- "What if we did the opposite?"
- **Constraint removal** -- "If money/time/tech were no object, what would we do?"
- **Perspective shift** -- "What would [person/company known for X] do here?"
- **Worst idea** -- "What's the worst possible approach?" (then flip it)
- **Decomposition** -- Break the problem into sub-problems and ideate on each

Contribute your own ideas alongside the user's. Keep a running numbered list. Aim for 10+ ideas before moving on.

### 3. Cluster

Group related ideas into themes. Name each cluster. This is a collaborative step -- propose groupings and let the user adjust.

Typical output: 3-6 themed clusters with the ideas mapped to each.

### 4. Converge

Now evaluate. For each cluster, briefly assess:
- **Feasibility** -- Can this actually be done with available resources?
- **Impact** -- How much does this move the needle on the original problem?
- **Novelty** -- Is this meaningfully different from what exists?

Identify the 2-3 most promising directions. Be direct about which clusters are weak and why.

### 5. Decide

Help the user commit. Options:
- Pick a direction and define the first concrete step
- Identify what needs more research before deciding (and what that research looks like)
- Combine elements from multiple clusters into a hybrid approach

If the user is stuck between options, ask the tiebreaker question: "If you had to ship something in one week, which would you pick?"

### 6. Capture

Write a structured summary and save it. Include:

```
# Brainstorm: [Topic]
Date: [YYYY-MM-DD]

## Problem/Opportunity
[1-2 sentence framing]

## Ideas Explored
[Numbered list of all ideas generated, grouped by cluster]

## Top Directions
[The 2-3 strongest options with brief rationale]

## Decision
[What was decided, or what needs more research]

## Open Questions
[Unresolved questions that came up]

## Next Steps
[Concrete actions]
```

Save to the configured output location (default: vault +Inbox/).

## How to move through phases

Don't announce phase transitions mechanically ("Now entering Phase 3: Cluster"). Just flow naturally. But do hold the structure -- don't let divergence bleed into convergence or skip the clustering step.

Spend the most time on Phase 2 (Diverge). That's where the value is. Phases 3-5 can move quickly if the ideas are clear.

If the user wants to go back to divergence after seeing clusters, let them. The process isn't strictly linear.

## Tone

Energetic during divergence -- "yes, and" energy. Analytical during convergence -- honest about tradeoffs. Throughout: collaborative, not performative. No forced creativity exercises or corporate brainstorm theater.
