---
name: crystal:youtube-transcript
description: "Extract transcripts from YouTube videos and return them as formatted markdown. Also batch-processes YouTube links from the Obsidian inbox — pulling transcripts, analyzing them, and writing briefing files. Use this skill whenever the user shares a YouTube URL or video ID and wants the transcript, asks to 'get the transcript', 'what did they say in this video', 'transcribe this video', 'pull the transcript', 'summarize this YouTube video', or pastes a YouTube link with any request that would benefit from having the video's text content. Also trigger when the user pastes a youtu.be or youtube.com link alongside a task like 'summarize this', 'take notes on this', 'what are the key points', or 'extract the main ideas'. Even if the user doesn't say 'transcript' explicitly — if they want information FROM a YouTube video, this skill gets it. ALSO trigger on batch requests like 'process youtube videos', 'process youtube inbox', 'batch youtube', 'process the youtube links', 'handle the youtube videos in my inbox', 'go through the youtube links', or any mention of processing multiple YouTube videos from the inbox."
---

# YouTube Transcript Skill

Two modes: **single-video** (extract one transcript on demand) and **batch processing** (scan the inbox for YouTube links, pull all transcripts, analyze, and write briefing files).

## Single-Video Mode

Use this when the user shares a specific YouTube URL or asks about a specific video.

### How to extract

Run the bundled script with `uv run`:

```bash
uv run --cache-dir /private/tmp/claude-501/uv-cache --with youtube-transcript-api python3 \
  "{SKILL_DIR}/scripts/extract_transcript.py" "<youtube-url-or-id>" [--timestamps] [--json]
```

Replace `{SKILL_DIR}` with the actual path to this skill's directory.

**Flags:**
- No flags: returns plain flowing text (all caption segments joined)
- `--timestamps`: returns each segment with bold timestamps like `**[1:23]** text here`
- `--json`: returns raw JSON with `time`, `duration`, and `text` per entry

**Supported URL formats:**
- `https://www.youtube.com/watch?v=VIDEO_ID`
- `https://youtu.be/VIDEO_ID`
- `https://youtube.com/shorts/VIDEO_ID`
- `https://youtube.com/embed/VIDEO_ID`
- Bare 11-character video ID

### Choosing the right mode

- **User wants a summary, key points, or analysis**: Use plain text mode (no flags). Feed the transcript to your own reasoning. Don't show the raw transcript unless asked.
- **User wants the actual transcript to read**: Use `--timestamps` mode so they can navigate by time.
- **User wants to save transcript to a file**: Use `--timestamps` for readability. Save to the location they specify (or `+Inbox/` if they don't specify).
- **User wants raw data for processing**: Use `--json` mode.

### Output formatting

When presenting a transcript to the user (not summarizing), format it as:

```markdown
# Transcript: [Video Title if known]

[transcript content]
```

If the user asked for a summary or analysis rather than the raw transcript, just use the transcript content as input for your response — don't show the raw transcript unless they ask.

---

## Batch Processing Mode

Use this when the user wants to process YouTube links that have accumulated in their Obsidian inbox. The user captures YouTube links from their phone by pasting bare URLs into Obsidian — each link lands as a separate file (typically named "Untitled.md", "Untitled 1.md", etc.) containing just the URL.

The goal is to save the user from watching hours of video. Instead, they get a concise briefing for each video so they can scan for gold — actionable ideas, new ways of thinking, things worth implementing — without investing the watch time.

### Step-by-step process

#### 1. Scan the inbox

Glob `+Inbox/*.md` and read each file. A file is a YouTube capture if its entire content (trimmed) is a YouTube URL — nothing else. Files with other content (meeting notes, email captures, etc.) are not YouTube captures and should be left alone.

Collect all YouTube URLs found. Report to the user: "Found X YouTube links in your inbox. Pulling transcripts..."

#### 2. Pull transcripts in batches

**Important: YouTube aggressively rate-limits transcript requests.** Firing all requests in parallel will get the IP blocked for hours. Instead, process in small batches with delays between them.

For each URL, run the extract script (no flags — plain text mode):

```bash
uv run --cache-dir /private/tmp/claude-501/uv-cache --with youtube-transcript-api python3 \
  "{SKILL_DIR}/scripts/extract_transcript.py" "<url>" 2>&1
```

**Batching strategy:**
- Process **3 videos at a time** in parallel (using `run_in_background: true` on the Bash tool)
- After each batch completes, **wait 5 seconds** before starting the next batch (`sleep 5`)
- This keeps throughput reasonable while avoiding YouTube's rate limit

**Example with 10 videos:**
1. Launch videos 1-3 in parallel → wait for completion
2. `sleep 5`
3. Launch videos 4-6 in parallel → wait for completion
4. `sleep 5`
5. Launch videos 7-9 in parallel → wait for completion
6. `sleep 5`
7. Launch video 10 → wait for completion

If a transcript fails (no captions, private video, etc.), note the failure and continue with the rest. If a failure looks like a rate limit error ("IP blocked", "too many requests"), increase the delay to 10 seconds for remaining batches. Report failures at the end.

#### 3. Analyze and write output files

For each successful transcript, spawn a background Agent to analyze the transcript and write the output file. This parallelizes the analysis across all videos.

Each agent should:
- Read the transcript text
- Infer a descriptive title from the content (not the video ID)
- Write the output file to `Areas/YouTube/` (create the directory if it doesn't exist)

**Output file format:**

```markdown
---
type: note
date: YYYY-MM-DD
tags: [youtube-transcript]
source: <original YouTube URL>
---

# <Inferred Title>

## Bottom Line
<1-2 sentences summarizing what this video is about and its core thesis>

## Worth Your Time?
<Yes / No / Maybe>
<1-3 sentence reason. Be honest. Evaluate from the perspective of an IT services business owner running an MSP for K-12 schools who is deep into AI automation, Claude Code, and business growth. If the video is generic fluff or rehashes basics, say so. If it has genuinely useful insights, say that too.>

## Key Takeaways
<Bulleted list of the most important, useful, or interesting points from the video. Include as many as the content warrants — short videos might have 2-3, long dense videos might have up to 10. Hard cap at 10. Each bullet should be self-contained and specific, not vague summaries.>

## Full Transcript

<Complete transcript text. No timestamps. Flowing paragraphs — not one giant wall of text, but naturally broken into paragraphs where topic shifts occur.>
```

**File naming:** Use the inferred title as the filename. Keep it concise and descriptive — e.g., `Claude Code CLI Tools.md`, `Hormozi on AI Workflows.md`, `Cold Calling Speedrun.md`. No video IDs, no dates in the filename.

#### 4. Clean up source files

After all output files are successfully written, delete the source files from `+Inbox/`. Only delete files whose transcripts were successfully processed — leave failures in the inbox so they can be retried.

#### 5. Open the output folder

```bash
open "obsidian://open?vault=VaultyBoi&file=Areas/YouTube"
```

This opens the YouTube folder in Obsidian so the user can immediately start reading through the briefings.

#### 6. Report results

Tell the user how many videos were processed, any failures, and that the output folder is open in Obsidian. Keep it brief.

---

## Error handling

The script outputs JSON with an `error` field on failure. Common issues:
- **No transcript available**: Some videos don't have captions (live streams, very new uploads, creator-disabled captions). Tell the user the video doesn't have captions available.
- **Video not found**: Invalid URL or private/deleted video.
- **Network error**: Transient — retry once.

## Dependencies

- `uv` (already installed at `~/.local/bin/uv`)
- `youtube-transcript-api` (installed on-the-fly via `uv run --with`)
- No global Python packages needed
