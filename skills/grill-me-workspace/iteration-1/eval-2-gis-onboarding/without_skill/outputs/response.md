Solid plan. Here's how I'd structure it in n8n:

## High-level workflow

1. **Trigger: Email webhook or Gmail node** — poll for emails from HR matching a pattern (e.g., subject contains "New Hire" or from a specific HR sender)
2. **Parse email** — extract name, personal email, role, start date, grade level or department
3. **Create Google account** — Google Workspace Admin SDK via HTTP Request node (POST to `/admin/directory/v1/users`)
4. **Add to groups** — loop over relevant groups based on role/department, POST to `/admin/directory/v1/groups/{groupKey}/members`
5. **Chromebook provisioning** — depends on your MDM. If you're using Google's Chrome Device Management, you can move the device to the right OU via the Directory API. If devices are pre-enrolled, you'd assign the user to the device.
6. **Send welcome email** — Gmail node or SMTP, templated with login info

## Things to nail down before building

- **Email format from HR** — is it a structured format (form output, CSV attachment) or freeform prose? Freeform requires an AI/LLM node to parse reliably. Structured is way easier.
- **Group mapping** — you'll need a lookup table: role → Google Groups. An n8n Code node or a Google Sheet as a reference works well here.
- **Chromebook workflow** — are devices pre-enrolled in your domain? If yes, provisioning is just OU assignment. If not, there's a manual step that can't be automated.
- **Password handling** — auto-generated temp password needs to get to the user somehow. If their personal email is in the HR email, you can send it there. Otherwise you're emailing HR to relay it.
- **Error handling** — account creation failures, duplicate accounts, group membership errors. You'll want a failure branch that notifies you rather than silently failing.

## Suggested node structure

```
Gmail Trigger (poll HR inbox)
  → Code node (parse/extract fields)
  → Google Admin HTTP Request (create user)
  → IF (success?)
      → YES: Loop over groups → Add to each group
              → Chromebook OU assignment (if applicable)
              → Send welcome email
              → Archive/label HR email
      → NO: Send failure notification to you
```

## Quick wins vs. harder parts

**Easy:** Account creation, group membership, welcome email — all well-documented Google APIs, n8n has good HTTP Request support.

**Harder:** Parsing unstructured HR emails reliably, Chromebook provisioning if devices aren't pre-enrolled, handling edge cases (name conflicts, existing accounts from subs/contractors).

Want me to draft the actual n8n workflow JSON, or start with the Google Admin API calls first?
