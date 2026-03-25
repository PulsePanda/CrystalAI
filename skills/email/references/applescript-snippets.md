# Apple Mail AppleScript Snippets

Ready-to-use AppleScript patterns. All require `dangerouslyDisableSandbox: true`.

---

## Create Draft

```applescript
tell application "Mail"
  set m to make new outgoing message with properties {subject:"...", content:"...", visible:true}
  tell m
    set sender to "avanalstyne@germanschool-mn.org"
    make new to recipient with properties {address:"recipient@example.com"}
  end tell
  save m
end tell
```

Default sender for Reboot work: `austin@rebootsystems.net`.

## Reply-All (default)

```applescript
tell application "Mail"
  set acct to first account whose name is "GIS"
  set theInbox to some mailbox of acct whose name is "INBOX"
  set msg to first message of theInbox whose message id is "MESSAGE_ID_HEADER"
  set replyMsg to reply msg with opening window
  tell replyMsg
    set content to "Reply body here"
  end tell
  save replyMsg
end tell
```

`reply msg with opening window` is reply-all by default. Do NOT use `replying to all` — throws -2741.

## Forward Email

```applescript
tell application "Mail"
  set acct to first account whose name is "GIS"
  set theInbox to some mailbox of acct whose name is "INBOX"
  set msg to first message of theInbox whose message id is "MESSAGE_ID_HEADER"
  set fwdMsg to forward msg with opening window
  tell fwdMsg
    make new to recipient at end of to recipients with properties {address:"recipient@example.com"}
  end tell
  send fwdMsg
end tell
```

## iCloud Archive (only for iCloud — Gmail uses GWS)

```applescript
tell application "Mail"
  set acct to first account whose name is "iCloud"
  set theInbox to some mailbox of acct whose name is "INBOX"
  set archiveBox to some mailbox of acct whose name is "Archive"
  set msgs to every message of theInbox
  repeat with i from 1 to count of msgs
    set msg to item i of msgs
    if id of msg is TARGET_ID then
      move msg to archiveBox
    end if
  end repeat
end tell
```

**AppleScript quirks:**
- Always use `some mailbox of acct whose name is "X"` — never `mailbox "X" of acct` (throws -1728)
- Always use index-based iteration — `repeat with msg in (messages of inbox)` throws -1728
- **Never pass a list to `move`** — `move (list_of_msgs) to target` throws -1700. Move one message at a time.
- **Gmail archiving = GWS CLI, not AppleScript** — use `messages modify` to remove INBOX label. AppleScript move is unreliable for Gmail IMAP.

**Correct iteration pattern:**
```applescript
set msgs to every message of theInbox
repeat with i from 1 to count of msgs
    set m to item i of msgs
    if subject of m contains "some text" then
        -- work with m
    end if
end repeat
```
