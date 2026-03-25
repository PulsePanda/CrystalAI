---
name: crystal:format-song-prompt
description: "Formats raw song notes into clean, copy-pasteable prompts for AI music generators (Suno, Udio, etc.). Use this skill whenever the user pastes song lyrics with production notes, structure notation (V1/C1/S1/B1), instrument directions, tempo/time signature info, or style references and wants them formatted for a music generator. Also trigger on: '/format-song-prompt', 'format this song', 'turn this into a music prompt', 'split into lyrics and style', 'make this a Suno prompt', 'make this a Udio prompt', 'format for music AI', or any time someone pastes raw songwriter notes with mixed lyrics and production direction."
---

# Format Song Prompt

Takes raw song notes — the messy, stream-of-consciousness kind with structure codes, parenthetical production notes, instrument directions, and rough lyrics all jumbled together — and splits them into two clean sections ready to paste into a music generator.

## Why two sections

Music generators like Suno and Udio typically want:
1. A **style/genre description** (the production direction, vibe, instruments, tempo, vocal style)
2. **Lyrics** with section tags (the actual words to sing, plus instrumental directions)

Songwriters don't think in those two buckets — they think in one continuous stream. This skill does the separation.

## How to process the input

Read the raw notes and mentally sort everything into two piles:

### Style pile (production direction)
Extract and organize:
- **Genre/era/influences** — "70s blues-rock", "Clapton guitar", "like Greta Van Fleet"
- **Tempo/time** — BPM, time signature, feel descriptions ("pace of a slow walk")
- **Instruments** — what plays, when, how (guitar voicing, drum style, harmonica placement rules)
- **Vocal style** — register, delivery, tone ("soulful high vocals", "half-sung half-spoken")
- **Mix/production notes** — EQ direction, frequency emphasis, clarity vs mud, raw vs polished
- **Structure overview** — the section order as a roadmap (Intro - V1 - C1 - V2 - C1 - Solo - Bridge - C1)
- **Performance specifics** — strumming patterns, beat placement, what plays on which beats, scale references
- **Section-level rules** — "harmonica only on chorus", "no harmonica on verses", "guitar mirrors vocal in bridge"

Condense into a dense but readable paragraph. Lead with genre, then layer in specifics. **The style section MUST be 1000 characters or less** — this is a hard limit from music generators. Prioritize: genre/influences first, then vocal style, then tempo/time, then key performance details. Cut redundant adjectives and compress aggressively. If the songwriter gave more detail than fits, keep the most distinctive/specific details and drop generic ones. Count characters before outputting.

### Lyrics pile
Extract and organize:
- **Section tags** — Convert shorthand (V1, C1, S1, B1) to full `[Verse 1]`, `[Chorus]`, `[Solo]`, `[Bridge]` tags
- **Lyrics** — Clean up spelling, punctuation, and capitalization while preserving the songwriter's voice. Don't rewrite — just tidy. Keep contractions, slang, and stylistic choices intact.
- **Instrumental sections** — Convert production notes for non-vocal sections into parenthetical stage directions: `(4 bars plain pattern, then 4 bars harmonica solo...)`
- **Repeat markers** — Expand "repeat C1" into the full chorus lyrics. Music generators don't understand references — they need the actual words every time.
- **Ending instructions** — Note hard stops, fades, or specific ending behavior in parentheses after the last section.

## Handling songwriter shorthand

Songwriters use a lot of shorthand. Translate these consistently:
- `C1`, `C2` → `[Chorus]`, `[Chorus 2]` (if lyrics differ between choruses; if identical, just `[Chorus]`)
- `V1`, `V2` → `[Verse 1]`, `[Verse 2]`
- `S1` → `[Solo]`
- `B1` → `[Bridge]`
- `I1` → `[Intro]`
- `O1` → `[Outro]`
- "Repeat C1" → write out the full chorus lyrics again
- Parenthetical notes mid-lyric → keep them as parentheticals in the lyrics section if they're performance directions ("(spoken)" or "(whispered)"), move to style section if they're production notes
- Self-corrections in the notes ("Sorry, I meant V1") → silently apply the correction, don't include the meta-commentary

## Output format

Always output in this exact format with the `---` separator:

```
**Style:**
[Dense paragraph with all production direction. Genre first, then tempo, instruments, vocal style, structure overview, mix notes, performance specifics. One paragraph — no bullet points.]

**Structure:** [Section order on one line, e.g., "Intro - V1 - C1 - V2 - C1 - Solo - Bridge - C1"]

---

**Lyrics:**

[Intro]
(Instrumental direction in parentheses)

[Verse 1]
Lyrics here
Clean and properly punctuated

[Chorus]
Chorus lyrics
Every time, fully written out

[Solo]
(Instrumental direction in parentheses)

[Bridge]
Bridge lyrics

[Chorus]
(Note about return to main feel if relevant)
Full chorus lyrics again
(Hard stop / fade / ending instruction)
```

## Things to watch for

- **Don't editorialize.** The songwriter's commentary about their own song ("I feel like a genius", "I hope the AI does justice") is meta — don't include it in either section.
- **Don't add musical ideas.** Only include what the songwriter specified. If they didn't mention bass, don't add bass.
- **Preserve all specifics.** If they said "toms" not "drums", use "toms". If they gave beat-level placement ("guitar on 1 and 4"), keep that precision.
- **Genre-agnostic.** This works for any genre. Don't assume blues-rock conventions — read what the songwriter actually wrote.
- **When in doubt about a note's destination** (style vs lyrics): if it tells a performer *what to play/sing*, it's style. If it tells the *listener what they'll hear in sequence*, it's lyrics/stage direction.
