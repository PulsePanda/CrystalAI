# Red Lines — Hardcoded Irreversible Action Gates

These actions MUST be approved by Judge Two before execution. This list is hardcoded into the framework and cannot be overridden by the Planner, Executor, or any other agent.

## The Red Lines

1. **Sending emails** — Any email sent via Apple Mail, Gmail API, or any other mechanism
2. **Creating or modifying calendar events** — Any iCal, Google Calendar, or other calendar modification
3. **API calls that post or modify external data** — Any HTTP POST/PUT/PATCH/DELETE to an external service (Buffer, Freshdesk, YNAB, etc.)
4. **Pushing code to remote repositories** — Any `git push` to any remote
5. **Spending money** — Any purchase, subscription creation, payment execution, or financial transaction

## How Red Lines Work

When an Executor reaches a step that involves a red-line action:

1. Executor prepares the action (drafts the email, stages the commit, formats the API call)
2. Executor sends the proposed action to Judge Two via claude-peers with full details:
   - What action is being taken
   - The complete content (email body, commit diff, API payload, etc.)
   - Which plan step this fulfills
3. Executor **waits** for Judge Two's verdict
4. If APPROVED: Executor proceeds with the action
5. If BLOCKED: Executor reads Judge Two's required changes, makes them, and resubmits

## What is NOT a Red Line

- Reading emails, calendar events, or API data (GET requests)
- Writing files to the local filesystem
- Creating Todoist tasks (internal, easily reversible)
- Running local scripts or commands
- Reading from MCP servers

The distinction is irreversibility and external visibility. If the action can be undone trivially and no one outside the system sees it, it's not a red line.
