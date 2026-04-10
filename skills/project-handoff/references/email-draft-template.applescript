-- Project handoff email draft template.
-- Placeholders: {{SUBJECT}}, {{BODY}}, {{SENDER}}, {{RECIPIENT}}, {{ATTACHMENT_PATH}}
--
-- Fill placeholders via shell substitution before running. Example:
--   sed -e "s|{{SUBJECT}}|$SUBJECT|" \
--       -e "s|{{SENDER}}|$SENDER|" \
--       -e "s|{{RECIPIENT}}|$RECIPIENT|" \
--       -e "s|{{ATTACHMENT_PATH}}|$ZIP_PATH|" \
--       email-draft-template.applescript > /tmp/handoff-draft.applescript
--
-- BODY is trickier because it's multi-line. Write the body text to a temp file,
-- read it in the shell, then embed with a heredoc-style replacement OR write the
-- full applescript from scratch in the skill rather than using sed substitution
-- for the body. Multi-line AppleScript strings work fine — literal newlines
-- inside the quoted string are preserved.
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
  tell content of m
    make new attachment with properties {file name:(POSIX file "{{ATTACHMENT_PATH}}")} at after last paragraph
  end tell
  save m
end tell
