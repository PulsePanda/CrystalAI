# message:// Link Snippets

Generate Apple Mail `message://` links from GWS Gmail message IDs. Confirmed working 2026-03-17.

---

## Get message:// Link from GWS Message ID

```bash
GWS="/Users/Austin/Library/Mobile Documents/iCloud~md~obsidian/Documents/VaultyBoi/_System/scripts/gws-mac.sh"
"$GWS" ACCOUNT gmail users messages get --params '{"userId":"me","id":"GWS_MSG_ID","format":"metadata","metadataHeaders":["Message-ID"]}' 2>/dev/null | \
  python3 -c "
import json,sys,urllib.parse
d=json.load(sys.stdin)
mid=[h['value'] for h in d['payload']['headers'] if h['name']=='Message-ID'][0]
raw=mid.strip('<>')
print(f'message://%3C{urllib.parse.quote(raw, safe=\"@.\")}%3E')
"
```

**Output:** `message://%3Ccalendar-a1e56498-1c95-4913-999b-5d242f65c3aa@google.com%3E`

## Get Subject + From + Link Together (for task notes)

```bash
"$GWS" ACCOUNT gmail users messages get --params '{"userId":"me","id":"GWS_MSG_ID","format":"metadata","metadataHeaders":["Subject","From","Date","Message-ID"]}' 2>/dev/null | \
  python3 -c "
import json,sys,urllib.parse
d=json.load(sys.stdin)
h={x['name']:x['value'] for x in d['payload']['headers']}
mid=h.get('Message-ID','').strip('<>')
link=f'message://%3C{urllib.parse.quote(mid, safe=\"@.\")}%3E'
print(f'Subject: {h.get(\"Subject\")}')
print(f'From: {h.get(\"From\")}')
print(f'Link: {link}')
"
```

## Markdown Link Format

```markdown
[Email from Bryan](message://%3CABC123@mail.example.com%3E)
```

`%3C` = `<` and `%3E` = `>` (URL-encoded angle brackets around the Message-ID)
