---
name: crystal:auto-fix
description: Internal tool skill — automatic error recovery. Called whenever a tool call, MCP operation, AppleScript, or skill execution fails. Diagnoses the error, applies the known fix if one exists, retries the operation, and documents new errors to known-errors.md. Covers Things3 MCP failures, AppleScript errors, Claude Code tool errors, and shell/code execution failures. Other skills should call this instead of surfacing errors directly to the user.
version: 1.0.0
allowed-tools: Read, Write, Edit, Bash, Grep
---

# Auto-Fix Skill

When any operation fails, run this skill before surfacing the error to the user. The goal: fix it silently, retry, and only escalate if recovery is impossible.

---

## Step 1: Consult known-errors.md

Before doing anything else, read the error log:

```
state/operational/known-errors.md
```

Search for the error message, error code, or operation type. If a match is found:
- Apply the documented fix immediately
- Retry the original operation
- If retry succeeds → proceed silently (do not mention the error to the user)
- If retry fails → escalate (Step 4)

---

## Step 2: Diagnose Unknown Errors

If the error is not in known-errors.md, classify it:

### Things3 MCP Errors

| Symptom | Likely Cause | Fix to try |
|---------|-------------|------------|
| Task created but no date set | Date passed in initial `make new to do` block | Set date as separate statement after creation |
| `-10006` on reschedule | `set schedule date` on existing task | Move to "Anytime" first, then set `due date` |
| `count` syntax error | `count` is reserved in AppleScript | Rename variable to `taskCount`, `itemCount`, etc. |
| MCP tool returns no result / times out | Things3 MCP connection dropped | Fall back to heart-queue (see things3 skill) |
| Task goes to wrong list | `when` param sent a date → moved out of Inbox | Omit `when` if no specific date; task goes to Inbox |

### AppleScript Errors

| Error Code | Meaning | Fix |
|-----------|---------|-----|
| `-1719` | Invalid mailbox index | Use `whose name is "All Mail"` form instead of direct `mailbox "Name"` |
| `-1728` | Can't get mailbox | Switch to `first mailbox of theAccount whose name is "..."` |
| `-2741` | Syntax error in reply | Remove `replying to all` — default reply IS reply-all |
| `-10006` | Can't set property on existing object | Split operation: move first, then set property |

### Claude Code Tool Errors

| Error | Fix |
|-------|-----|
| "File has not been read yet" (Write tool) | Call Read on the path first, even if file doesn't exist |
| Bash sandbox: "Operation not permitted" | Retry with `dangerouslyDisableSandbox: true` if path is clearly safe |

### Shell / Code Execution Errors

- Read the error message carefully — most contain the fix (wrong flag, wrong path, missing dependency)
- Check if the same command pattern is in known-errors.md
- Try the simplest fix first (correct the flag/path/syntax), re-run once
- If still failing, escalate

---

## Step 3: Apply Fix and Retry

1. Apply the fix (correct the code, adjust parameters, change approach)
2. Retry the original operation **once**
3. If successful → continue without mentioning the error to the user
4. If still failing → go to Step 4

Do not retry more than once. Repeated retries on broken operations waste time and can create duplicate side effects (e.g., duplicate Things3 tasks).

---

## Step 4: Document the Error

Whether recovery succeeded or failed, document any error that wasn't already in known-errors.md.

**Append to `${CLAUDE_PLUGIN_ROOT}/state/operational/known-errors.md`** under the appropriate section:

```markdown
### [Short descriptive title]
**Error:** [Exact error message or code]
**Root cause:** [What actually caused it]
**Fix:** [What resolved it — or "unresolved" if escalating]
```

Update the `Last Updated` date at the bottom of the file.

---

## Step 5: Escalate if Unresolved

If the operation still fails after one retry, surface it to the user:

**Good escalation format:**
```
[Operation] failed: [error in plain English].
Tried: [fix attempted].
Options: [what the user can do — e.g., check Things3 connection, provide missing info, skip this step].
```

**Bad escalation:**
- Don't dump a raw stack trace
- Don't say "I don't know what happened"
- Don't retry the same broken call a third time

---

## Calling This Skill from Other Skills

Other skills should invoke auto-fix on any failed operation rather than surfacing errors directly. Pattern:

```
1. Attempt the operation
2. On failure → invoke auto-fix skill with: error message, operation attempted, parameters used
3. auto-fix diagnoses, retries, documents
4. Returns: "recovered" (continue) or "unresolved: [escalation message]"
```

The things3 skill already has a heart-queue fallback for MCP outages — auto-fix handles everything else (bad params, AppleScript errors, wrong syntax).

---

## What NOT to Do

- Don't retry infinitely — one fix attempt, one retry, then escalate
- Don't create duplicate tasks/events/records while diagnosing
- Don't surface raw error codes to the user without translation
- Don't document trivial one-time typos — only document errors that could recur
