# GWS Gmail CLI Snippets

Ready-to-use bash snippets for Gmail operations via GWS. Replace `ACCOUNT` and `MSG_ID` placeholders.

**GWS wrapper path:**
```bash
GWS="/Users/Austin/Documents/GitHub/CrystalAI/scripts/gws-mac.sh"
```

**Account names:** `personal`, `umb`, `gis`, `sja`, `kesa` (lowercase)

All commands use `2>/dev/null` to suppress the keyring backend log line.

---

## List Inbox

```bash
"$GWS" ACCOUNT gmail users messages list --params '{"userId":"me","q":"in:inbox","maxResults":50}' 2>/dev/null
```

Returns `{"messages":[{"id":"19cfc273d74771b2","threadId":"..."},...]}`. IDs are Gmail hex strings.

## Get Message Metadata

```bash
"$GWS" ACCOUNT gmail users messages get --params '{"userId":"me","id":"MSG_ID","format":"metadata","metadataHeaders":["Subject","From","Date","Message-ID"]}' 2>/dev/null
```

## Get Full Message (includes body)

```bash
"$GWS" ACCOUNT gmail users messages get --params '{"userId":"me","id":"MSG_ID","format":"full"}' 2>/dev/null
```

Headers are in `payload.headers[]` as `{name, value}` objects. Body is base64url encoded in `payload.body.data` or nested in `payload.parts[].body.data`.

## Parse Headers (Python one-liner)

```bash
"$GWS" ACCOUNT gmail users messages get --params '{"userId":"me","id":"MSG_ID","format":"metadata","metadataHeaders":["Subject","From","Date","Message-ID"]}' 2>/dev/null | \
  python3 -c "import json,sys;d=json.load(sys.stdin);h={x['name']:x['value'] for x in d['payload']['headers']};print(f'Subject: {h.get(\"Subject\")}\nFrom: {h.get(\"From\")}\nDate: {h.get(\"Date\")}\nMessage-ID: {h.get(\"Message-ID\")}')"
```

## Archive (Remove INBOX Label)

```bash
"$GWS" ACCOUNT gmail users messages modify --params '{"userId":"me","id":"MSG_ID"}' --json '{"removeLabelIds":["INBOX"]}' 2>/dev/null
```

Returns `{"id":"...","labelIds":[...],"threadId":"..."}` — INBOX will no longer be in labelIds.

## Batch Archive

```bash
for id in MSG_ID1 MSG_ID2 MSG_ID3; do
  "$GWS" ACCOUNT gmail users messages modify --params "{\"userId\":\"me\",\"id\":\"$id\"}" --json '{"removeLabelIds":["INBOX"]}' 2>/dev/null
done
```

## Add/Remove Labels

```bash
"$GWS" ACCOUNT gmail users messages modify --params '{"userId":"me","id":"MSG_ID"}' --json '{"addLabelIds":["STARRED"]}' 2>/dev/null
"$GWS" ACCOUNT gmail users messages modify --params '{"userId":"me","id":"MSG_ID"}' --json '{"removeLabelIds":["UNREAD"]}' 2>/dev/null
```

## Search

```bash
"$GWS" ACCOUNT gmail users messages list --params '{"userId":"me","q":"from:kweber@raptortech.com newer_than:7d","maxResults":10}' 2>/dev/null
```

## Fetch All 5 Accounts in Parallel

```bash
for acct in umb gis sja kesa personal; do
  "$GWS" $acct gmail users messages list --params '{"userId":"me","q":"in:inbox","maxResults":50}' 2>/dev/null &
done
wait
```

Or use separate Bash tool calls in parallel (preferred — easier to parse results per account).
