---
name: auto-fix
description: Internal tool skill — automatic error recovery. Called whenever a tool call, MCP operation, script, or skill execution fails. Diagnoses the error, applies the known fix if one exists, retries the operation, and documents new errors to known-errors.md. Other skills should call this instead of surfacing errors directly to the user.
version: 1.0.0
allowed-tools: Read, Write, Edit, Bash, Grep
---

# Auto-Fix Skill

When any operation fails, run this skill before surfacing the error to the user. The goal: fix it silently, retry, and only escalate if recovery is impossible.

---

## Step 1: Consult known-errors.md

Before doing anything else, read the error log:

```
${STATE_PATH}/operational/known-errors.md
```

Search for the error message, error code, or operation type. If a match is found:
- Apply the documented fix immediately
- Retry the original operation
- If retry succeeds → proceed silently (do not mention the error to the user)
- If retry fails → escalate (Step 4)

---

## Step 2: Diagnose Unknown Errors

If the error is not in known-errors.md, classify it:

### MCP Tool Errors

| Symptom | Likely Cause | Fix to try |
|---------|-------------|------------|
| MCP tool returns no result / times out | MCP connection dropped | Check if server is running; retry once |
| Parameter validation error | Wrong param type or format | Check tool schema, correct params, retry |
| Authentication / permission error | Token expired or missing | Note in escalation — user needs to reconfigure |

### AppleScript Errors (macOS)

| Error Code | Meaning | Fix |
|-----------|---------|-----|
| `-1719` | Invalid index | Use `whose name is "..."` form instead of direct reference |
| `-1728` | Can't get object | Switch to `first [object] whose name is "..."` |
| `-10006` | Can't set property on existing object | Split operation: modify first, then set property |

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

Do not retry more than once. Repeated retries on broken operations waste time and can create duplicate side effects (e.g., duplicate tasks or records).

---

## Step 4: Document the Error

Whether recovery succeeded or failed, document any error that wasn't already in known-errors.md.

**Append to `${STATE_PATH}/operational/known-errors.md`** under the appropriate section:

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
Options: [what the user can do — e.g., check connection, provide missing info, skip this step].
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

---

## What NOT to Do

- Don't retry infinitely — one fix attempt, one retry, then escalate
- Don't create duplicate tasks/events/records while diagnosing
- Don't surface raw error codes to the user without translation
- Don't document trivial one-time typos — only document errors that could recur
