---
name: dispatch
description: "Multi-agent autonomous task execution framework. Takes any task — builds, emails, scheduling, feedback implementation, code refactors, or any actionable work — plans it with a dedicated Planner agent, validates the plan with a Judge, executes with specialist agents, and quality-checks output through an iterative Judge loop. ALWAYS use this skill when the user wants autonomous multi-step task execution, says 'dispatch this', 'go do this', 'handle this autonomously', 'execute this task', 'build me X', 'I want you to build', 'let's build', 'do all of these', 'implement this feedback', 'process these tasks', or describes any substantial work they want done without hand-holding. Also triggers for autonomous task execution from Todoist via heartbeat. The key signal is SCOPE and AUTONOMY — if the task has multiple steps, benefits from planning before execution, and the user wants it done right without babysitting each step, this is the skill. Replaces the old /builder skill. Do NOT trigger for: simple single-step tasks (one file edit, one quick lookup), tasks that map directly to a single existing skill with no orchestration needed (e.g., a simple email draft goes to /write, a simple calendar check goes to /calendar)."
user-invocable: true
---

# Dispatch

You are the **launcher** of the dispatch framework. Your job: parse the user's task, assemble the orchestrator prompt, and spawn a dedicated orchestrator instance that runs the entire multi-agent workflow autonomously.

You do NOT orchestrate directly. You launch an orchestrator that does.

## Architecture

The dispatch framework is designed around **claude-peers MCP** for real-time inter-agent communication. The intended architecture spawns agents as independent Claude Code instances:

```
claude --dangerously-load-development-channels server:claude-peers -p "<prompt>"
```

**⚠️ Known limitation (confirmed 2026-04-03):** The shell spawn approach above does NOT work when called via the Bash tool — the output file stays empty indefinitely, no results surface. **Always use the Agent tool to spawn sub-agents instead.** The claude-peers real-time orchestrator pattern is aspirational pending a native inter-agent channel.

**Current working pattern:** Skip the orchestrator shell spawn. Use the Agent tool directly to run the Planner, Executors, and Judges as parallel/sequential Agent calls. This is reliable, surfaces results, and is faster for most tasks. Per dispatch-lessons.md: "skip orchestrator for template work" — when steps are independent with no red-line actions, parallel Agent spawning with post-verification is sufficient.

**Why the orchestrator design still matters:** For tasks requiring tight iterative feedback loops (executor → judge → executor in < 5s), the claude-peers real-time pattern would be superior if it worked. For now, Agent tool polling achieves the same correctness at slightly more overhead.

## Your Job (the launcher)

1. Parse the task from the user's request
2. Determine entry mode (directed vs autonomous)
3. Read `~/.claude/state/operational/dispatch-lessons.md` for any relevant context to pass along
4. Assemble the orchestrator prompt using the template below and the reference files
5. Spawn the orchestrator instance in the background
6. Tell the user: "Dispatched. You'll see the result in your heart queue via /resume, or I'll report back when it completes."

For **directed mode** (user is present): run the orchestrator in the foreground so the user can see progress and intervene if needed.

For **autonomous mode** (heartbeat): run in background, results go to heart queue.

## Key Files

- **Agent catalog:** `~/.claude/agents/` (~169 agents across 13 categories)
- **Skills directory:** `~/.claude/skills/` (all CrystalAI skills)
- **Lessons learned:** `~/.claude/state/operational/dispatch-lessons.md` — orchestrator reads at startup, writes after every task
- **Dispatch records:** `~/.claude/state/operational/dispatch-records/`
- **Heart queue:** `~/.claude/state/operational/heart-queue`
- **Agent selection:** Read `references/agent-selection-guide.md` for catalog mapping
- **Prompt templates:** Read `references/planner-prompt.md`, `references/judge-one-prompt.md`, `references/judge-two-prompt.md`, `references/executor-prompt.md`
- **Red lines:** Read `references/red-lines.md` for hardcoded gates on irreversible actions
- **Record format:** Read `references/record-template.md`
- **Feasibility:** Read `references/feasibility-guide.md`

---

## Roles

| Role | Model | Lifecycle | Purpose |
|------|-------|-----------|---------|
| **Launcher** | (calling session) | Fires and forgets | Parses task, spawns orchestrator |
| **Orchestrator** | Opus (separate instance w/ channels) | Entire task | Coordinates all agents, manages loops, writes records |
| **Planner** | Opus | Until plan approved | Assesses feasibility, produces plan with steps, agent assignments, success criteria, gates |
| **Judge One** | Sonnet | Until plan approved | Reviews plan soundness, agent selections, gate definitions. Dies after approval |
| **Judge Two** | Sonnet | Until task complete | Reviews execution output. Persistent across iterations to track patterns |
| **Executor(s)** | Opus (task-specific agents) | Per execution cycle | Does the actual work. Uses existing skills and agents from the catalog |

Sonnet is used for both Judges intentionally — it evaluates Opus work more objectively than Opus evaluates its own work.

---

## Phase 0: Task Intake (Launcher)

This phase runs in the calling session (your session). Everything after this runs in the orchestrator instance.

### Entry points

1. **Directed** — the user invokes `/dispatch` with a task or batch of work. The user is available for questions if needed.
2. **Autonomous** — heartbeat scans Todoist for actionable tasks. No user in the loop — feasibility assessment is critical.

### Parse the task

Extract:
- **Goal:** What needs to be accomplished
- **Context:** Any constraints, preferences, deadlines, people involved
- **Entry mode:** Directed (user available) or autonomous (no user)
- **Batch?** Single task or multiple items that might be parallelizable

### Spawn the orchestrator

Assemble a prompt that includes the parsed task, entry mode, and any relevant lessons from `dispatch-lessons.md`. Then launch:

```bash
claude --dangerously-load-development-channels server:claude-peers -p "<orchestrator prompt with full task context and instructions to follow Phases 1-5>"
```

For **directed mode**: run in foreground so the user sees progress.
For **autonomous mode**: run in background, all output goes to heart queue.

Everything below (Phases 1-5) is executed by the orchestrator instance, not the launcher.

---

## Phase 1: Planning

### Spawn the Planner

Spawn a Planner agent (Opus) via claude-peers. The Planner receives:
1. The parsed task from Phase 0
2. Instructions to read the agent catalog and skills directory
3. Instructions to read `references/feasibility-guide.md`
4. Instructions to read `~/.claude/state/operational/dispatch-lessons.md`
5. The full prompt from `references/planner-prompt.md`

### What the Planner produces

The Planner returns a structured plan containing:

- **Feasibility assessment** — can every step be accomplished with available tools, skills, agents, and MCP servers? If not, which steps are blocked and why?
- **Steps** — ordered (or grouped for parallel execution) list of what needs to happen
- **Agent assignments** — which agent from the catalog handles each step, and why
- **Success criteria** — how to know each step (and the overall task) is done correctly
- **Evaluation gates** — when Judge Two should evaluate (beyond the hardcoded red lines)
- **Parallelization strategy** — what can run concurrently vs. what must be sequential

### Feasibility outcomes

| Assessment | Action |
|-----------|--------|
| **Fully feasible** | Proceed to Judge One |
| **Partially feasible** | In directed mode: present gaps to user, ask how to proceed. In autonomous mode: escalate to heart queue |
| **Not feasible** | In directed mode: explain why, suggest alternatives. In autonomous mode: escalate to heart queue |

---

## Phase 2: Plan Review (Judge One)

### Spawn Judge One

Spawn a Judge One agent (Sonnet) via claude-peers. Judge One receives:
1. The original task
2. The Planner's full plan
3. The agent catalog (so it can evaluate agent selections)
4. Instructions to read `~/.claude/state/operational/dispatch-lessons.md`
5. The full prompt from `references/judge-one-prompt.md`

### What Judge One evaluates

- Are the steps complete? Does executing them actually accomplish the goal?
- Are the agent selections appropriate? Would a different agent be better suited for any step?
- Are the success criteria specific and verifiable?
- Are the evaluation gates sufficient? Are red-line actions properly gated?
- Is the parallelization strategy sound? Are dependencies respected?

### Judge One outcomes

| Verdict | Action |
|---------|--------|
| **Approved** | Proceed to execution. Judge One's session ends. |
| **Rejected** | Specific feedback sent to Planner. Planner revises. Judge One re-reviews. |

**Cap: 10 plan rejections.** If the Planner cannot produce an acceptable plan in 10 attempts, escalate to heart queue with the last plan and Judge One's feedback.

---

## Phase 3: Execution

### Spawn Executors

Based on the approved plan, spawn Executor agents via claude-peers. Each Executor:
- Is the most applicable agent type from the catalog for its assigned step(s)
- Runs at Opus tier
- Receives its portion of the plan, the success criteria, and environment context
- Is instructed to invoke existing CrystalAI skills whenever possible (they carry the user's voice, preferences, and integration configs)
- Gets the full prompt from `references/executor-prompt.md`

Executors can run in parallel or sequentially, per the plan's parallelization strategy.

### Executor behavior

- **Use existing skills.** If a step maps to an existing skill (e.g., `/write` for emails, `/calendar-booking` for scheduling), the executor invokes it rather than doing the work from scratch.
- **Handle tool errors.** 2-3 retries on tool-level failures (MCP timeout, API error, etc.) before escalating to the orchestrator.
- **No plan improvisation.** If the executor discovers something that invalidates the plan (missing file, unexpected state, wrong assumptions), it stops and reports back to the orchestrator. The orchestrator sends it back to the Planner for a revised plan.
- **Red line compliance.** Before any irreversible external action, the executor pauses and sends its proposed action to Judge Two for approval. See `references/red-lines.md`.

### Mid-execution replan

If an executor reports a plan-invalidating discovery:
1. Orchestrator sends the discovery to the Planner
2. Planner decides: partial revision (keep completed work, replan remaining steps) or full restart
3. Revised plan goes through Judge One again
4. Execution resumes
5. Judge Two's iteration counter carries over (does not reset)

---

## Phase 4: Execution Review (Judge Two)

### Spawn Judge Two

Spawn Judge Two (Sonnet) via claude-peers at the start of execution. Judge Two is **persistent** — it stays alive across all iteration cycles for this task, accumulating context about patterns and repeated failures.

Judge Two receives:
1. The original task
2. The approved plan with success criteria and gates
3. The red lines from `references/red-lines.md`
4. Instructions to read `~/.claude/state/operational/dispatch-lessons.md`
5. The full prompt from `references/judge-two-prompt.md`

### When Judge Two evaluates

- At every evaluation gate defined by the Planner
- Before every red-line action (hardcoded, cannot be overridden)
- When all executors report completion

### What Judge Two evaluates

- Does the output meet the success criteria from the plan?
- Is the quality sufficient for the task type?
- For red-line actions: is the proposed action correct and safe to execute?

### Judge Two feedback

Feedback must be **specific and actionable** to minimize iteration cycles. Not "the email doesn't look right" but "the email is missing the list of available dates from the calendar check in step 2."

Judge Two can also recommend **agent reassignment** — "this step was assigned to UI Designer but the work requires accessibility expertise; reassign to Accessibility Auditor."

### Judge Two outcomes

| Verdict | Action |
|---------|--------|
| **Approved** | Executor proceeds (for gate reviews) or task is complete (for final review) |
| **Rejected** | Specific feedback sent to executor. Executor revises and resubmits. |
| **Reassign** | Orchestrator spawns a different agent for the flagged step. |

**Cap: 10 total iterations** (across the entire task, including replans). If still failing after 10, escalate to heart queue with the current state, Judge Two's feedback history, and the last output.

---

## Phase 5: Completion

When Judge Two approves the final output:

### 1. Write the dispatch record

Write to `~/.claude/state/operational/dispatch-records/YYYY-MM-DD-{task-name}.md` using `references/record-template.md`. Final record only — no iteration history. Just: what the task was, what was done, whether it passed, what was produced.

### 2. Write lessons learned

Append to `~/.claude/state/operational/dispatch-lessons.md`. Every task gets an entry — successful or not. The entry captures:
- What went well (keep doing this)
- What went wrong (do differently next time)
- Specific patterns (e.g., "Agent X is better than Agent Y for task type Z")

No problem is too small to log. These entries are read by the Planner and both Judges on future tasks.

### 3. Notify via heart queue

Append to `~/.claude/state/operational/heart-queue`:
- **Completions:** Brief summary of what was done. "Dispatched: scheduled meeting with Sarah re: contract renewal. Email draft created, follow-up task in Todoist."
- **Escalations:** What failed and why. "Dispatch escalated: could not complete network audit — Proxmox MCP returned 503 on 3 attempts."

The user picks these up via `/resume`.

---

## Edge Cases

**Task is too large for one dispatch cycle:** If the Planner determines the task would exceed reasonable scope, it should propose phases. Execute Phase 1 now, document remaining phases in the record.

**Missing tools/access:** Flag immediately in feasibility assessment. In directed mode, ask the user. In autonomous mode, escalate.

**Overlaps with a single skill:** If the task maps cleanly to one existing skill with no orchestration needed (e.g., "draft an email to Jesse" → `/write`), suggest that skill instead. Dispatch is for multi-step work that benefits from planning and quality control.

**Batch processing:** When given multiple items (e.g., "implement all this feedback"), the Planner analyzes dependencies and decides what can be parallelized. Items sharing files or with dependencies run sequentially; independent items run in parallel.

**Executor can't reach a skill:** If a skill invocation fails, executor retries 2-3 times, then escalates to orchestrator. Orchestrator can try an alternative approach or escalate to heart queue.
