---
name: crystal:content-publish
description: Autonomous social media publisher for the Umbrella Content Engine. Reads the content queue files, finds posts that are due, and publishes them to Buffer via the GraphQL API. Use this skill when running the content publishing pipeline, when the heartbeat/raindrop dispatcher triggers it, when Austin says "publish content", "push the queue", "post to social", "/content-publish", "run the publisher", or when checking if there are scheduled posts ready to go out. This skill makes real API calls to Buffer — it actually publishes content. Also trigger when Austin asks "are there posts ready to publish" or "what's in the content queue".
---

# Content Publish

Publish scheduled social media posts from the content queue to Buffer.

## Context

This is the final step in the content pipeline:
- `/content-dump` → captures ideas
- `/content-build` → turns ideas into posts and schedules them in queue files
- **This skill** → reads the queue, publishes due posts to Buffer via API

This skill is designed to run autonomously (Heart heartbeat or Canopy raindrop dispatcher) but can also be triggered manually by Austin.

## How It Works

The bundled script at `scripts/publish.py` handles everything deterministically:

1. Reads both queue files (`_System/Content/umbrella/queue.md` and `_System/Content/austin/queue.md`)
2. Finds rows where status is `scheduled` and date/time is now or in the past
3. Resolves channel names to Buffer channel IDs and picks the correct API key (personal vs umbrella account)
4. Calls the Buffer GraphQL API to publish each post
5. Updates the queue row status to `published` (or `error: ...` if it failed)
6. Reports results

## Running the Publisher

### Manual (MacBook or any machine with vault access)

```bash
python3 .claude/skills/content-publish/scripts/publish.py \
  --vault-path "/Users/Austin/Library/Mobile Documents/iCloud~md~obsidian/Documents/VaultyBoi"
```

### Dry run (see what would publish without actually doing it)

```bash
python3 .claude/skills/content-publish/scripts/publish.py \
  --vault-path "/Users/Austin/Library/Mobile Documents/iCloud~md~obsidian/Documents/VaultyBoi" \
  --dry-run
```

### Heart / Canopy (autonomous via dispatcher)

```bash
python3 /home/crystalos/VaultyBoi/.claude/skills/content-publish/scripts/publish.py \
  --vault-path /home/crystalos/VaultyBoi
```

## When Invoked as a Skill

When Austin triggers this skill interactively (or it's triggered by a dispatcher prompt):

### Step 1: Dry run first

Run the script with `--dry-run` to see what's queued:

```bash
python3 .claude/skills/content-publish/scripts/publish.py \
  --vault-path "VAULT_PATH" \
  --dry-run
```

If running interactively (Austin triggered it), show the results and ask for confirmation before publishing. If running autonomously (heartbeat/raindrop), skip confirmation and publish directly.

### Step 2: Publish

Run without `--dry-run` to actually publish:

```bash
python3 .claude/skills/content-publish/scripts/publish.py \
  --vault-path "VAULT_PATH"
```

### Step 3: Report

Tell Austin (or log to heart-log.md if autonomous) what happened:
- How many posts published
- Which channels they went to
- Any failures and why

### Step 4: Update post files (if applicable)

If any published posts have corresponding markdown files in `_System/Content/umbrella/posts/` or `_System/Content/austin/posts/`, update their frontmatter `status` from `drafted` to `published`.

Search for post files by matching the date in the filename to the queue row date. This step is best-effort — not all queue rows have corresponding post files (e.g., social-only posts without a blog article).

## Idempotency

The script only processes rows with status `scheduled`. Once published, the status changes to `published`, so re-running is safe. Failed posts get status `error: [reason]` — these can be retried by manually changing them back to `scheduled` after fixing the issue.

## Catch-Up Behavior

If the publisher missed a window (Heart was down, dispatcher didn't run), it publishes all overdue posts on the next run. Posts are never skipped because their scheduled time passed — they go out as soon as the publisher runs.

## Error Handling

- **API call fails**: status set to `error: [message]`, skip to next post, continue processing
- **Unknown channel name**: logged as skip, doesn't crash the run
- **API keys not found**: script exits with error before publishing anything
- **Queue file empty or missing**: reports "no posts due" and exits cleanly

## Channel Map

The script has a hardcoded channel map. If channels are added/removed in Buffer, update `scripts/publish.py` CHANNEL_MAP dict.

| Channel Name | Platform | Account | Channel ID |
|-------------|----------|---------|------------|
| ThePulsePanda | Twitter | personal | `5bf667fe00c63f26e92b9774` |
| austin-vanalstyne | LinkedIn | personal | `69bf23737be9f8b1717efd1a` |
| UmbrellaSysMN | Twitter | umbrella | `69bf257e7be9f8b1717f08b7` |
| umbrella-systems-mn | LinkedIn | umbrella | `69bf24787be9f8b1717f03b7` |
| Umbrella Systems | Facebook | umbrella | `69bf24a87be9f8b1717f04b0` |

## Dispatcher Integration

To add this to Heart's heartbeat or Canopy's raindrop, register a job that runs the publish script on a schedule (e.g., every 15 minutes or hourly). The script handles its own idempotency — safe to run frequently.
