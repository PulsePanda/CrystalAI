-- Project handoff email draft template (link-in-body variant).
-- Placeholders: {{SUBJECT}}, {{BODY}}, {{SENDER}}, {{RECIPIENT}}
--
-- Since the switch to Drive-hosted handoffs in skill v1.1, the Drive link lives
-- inside {{BODY}} — there's no attachment. Embedding the link directly avoids
-- Gmail's attachment scanner, which reliably flags zipped code projects even
-- when they're clean.
--
-- Fill placeholders before running. SUBJECT/SENDER/RECIPIENT are single-line
-- strings safe for sed substitution. BODY is multi-line — simpler to write
-- the full filled-in AppleScript from the skill rather than trying to sed a
-- multi-line string in. Literal newlines inside an AppleScript double-quoted
-- string are preserved as-is by Apple Mail.
--
-- The draft opens visible in Apple Mail and is saved to Drafts. The user
-- reviews and clicks send — this script NEVER sends automatically.

set theBody to "{{BODY}}"

tell application "Mail"
  set m to make new outgoing message with properties {subject:"{{SUBJECT}}", content:theBody, visible:true}
  tell m
    set sender to "{{SENDER}}"
    make new to recipient with properties {address:"{{RECIPIENT}}"}
  end tell
  save m
end tell

-- ── Fallback: attachment-based variant (if Drive upload fails) ─────────
--
-- If you need the old attachment behavior (e.g., Drive API is down, network
-- issue, or user explicitly wants an attachment), uncomment the block below
-- and replace the `save m` line above with the attachment-aware version.
--
-- Add inside the `tell application "Mail"` block, after the recipient is set
-- but before `save m`:
--
--   tell content of m
--     make new attachment with properties {file name:(POSIX file "{{ATTACHMENT_PATH}}")} at after last paragraph
--   end tell
--
-- Gmail will likely flag this in the web UI and ask the sender to "send with
-- Drive instead." This is why the default workflow uses Drive upfront.
