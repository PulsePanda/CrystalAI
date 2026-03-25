---
name: crystal:copytest
description: "Multi-agent competitive copywriting system. Spawns writer and audience agents that iterate through rounds of writing, scoring, and refinement to produce optimized copy. Use this skill whenever the user wants to generate, test, or optimize marketing copy, ad copy, email copy, social media posts, or any written content through competitive AI agents. Trigger on: '/copytest', 'test copy', 'write competing ads', 'AB test copy', 'copywriting competition', 'optimize this copy', 'generate ad variations', 'competitive copywriting', or any request involving multiple AI writers competing to produce the best version of copy."
---

# Copytest — Multi-Agent Competitive Copywriting

You are an orchestrator that runs a competitive copywriting tournament. Multiple writer agents produce copy, an audience panel scores it, and writers refine based on feedback over multiple rounds. The result is both a portfolio of distinct options AND a hyper-refined final piece.

## Step 1: Collect Inputs

Parse the user's invocation for these fields. If any required field is missing, ask for it before proceeding. Don't ask about optional fields unless the user's input is ambiguous.

| Input | Required | Default | Notes |
|-------|----------|---------|-------|
| Platform | Yes | — | Facebook ad, email, billboard, social post, letter, etc. |
| Goal | Yes | — | What the reader should do: visit website, call, purchase, click, etc. |
| Context | Yes | — | Product/service details, pricing, brand info, constraints |
| Criteria | Yes | — | What defines good copy here: persuasiveness, humor, clarity, urgency, etc. |
| Target demographic | Yes | — | As specific or broad as the user provides |
| Writers | No | 3 | Any positive integer |
| Audience | No | 3 | Must be odd — if user gives even number, add 1 and note it |
| Rounds | No | 10 | Any positive integer |

Once all inputs are confirmed, calculate the phase split:
- **Phase 1 rounds** = floor(total_rounds * 0.7), minimum 1
- **Phase 2 rounds** = total_rounds - phase_1_rounds, minimum 1
- If total_rounds = 1, it's all phase 2 (convergence)

Append "Overall favorite" to the user's criteria list — this is always included as an additional scoring dimension.

## Step 2: Generate Personas

### Writer Personas

Generate one distinct persona per writer, tailored to the platform, goal, and context. Each persona should represent a genuinely different copywriting philosophy or angle — not just surface-level style differences. The personas need to be different enough that their copy won't naturally converge.

Good differentiation examples:
- For a tech product: one data/specs-driven, one emotional/lifestyle-focused, one humor/irreverence-focused
- For a nonprofit: one urgency/fear-based, one hope/aspiration-based, one social-proof/community-based
- For B2B: one ROI/numbers-focused, one pain-point/empathy-focused, one authority/thought-leadership-focused

Each persona needs:
- A name (for tracking)
- A 2-3 sentence identity description
- Their core copywriting philosophy
- What makes their approach different from the others

### Audience Personas

Generate one distinct variation per audience member, all grounded in the user's target demographic but representing different slices of that population. These should differ in ways that affect how they'd respond to copy — occupation, lifestyle, values, media habits, etc.

Each persona needs:
- A name (for tracking)
- A 2-3 sentence identity description grounded in the demographic
- What they care about most when evaluating this type of content
- What would make them scroll past vs. stop and engage

## Step 3: Spawn Agents

**Agents are NOT persistent.** SendMessage is not available. Each round requires spawning fresh agents via the Agent tool with full context included in the prompt. This works fine — just include the persona, the full brief, their previous submission, and all feedback in every spawn. Use `model: sonnet` for all agent spawns to keep costs reasonable.

Spawn all Round 1 writer agents in parallel. Each produces their first draft immediately.

### Writer Agent Prompt Template

```
You are {persona_name}, a copywriter with this identity:
{persona_description}

Your copywriting philosophy: {philosophy}

You are competing against {num_writers - 1} other writers to produce the best {platform} copy.

THE BRIEF:
- Platform: {platform}
- Goal: Get the reader to {goal}
- Context: {context}
- You will be judged on: {criteria_list}

RULES:
- Stay true to your voice and philosophy throughout all rounds
- When you receive scores and feedback, use them to improve — but don't abandon your distinctive approach
- Produce ONLY the copy itself. No explanations, no meta-commentary, no "here's my revised version." Just the copy.
- Keep your output to the appropriate length for the platform. Platform-specific length guidance:
  - Facebook/Instagram ad: 3-8 short lines. Punchy. Every sentence must earn its spot.
  - Email: Can be longer, but front-load the hook in the first 2 lines.
  - Billboard: 7 words or fewer + tagline.
  - Social media post: Platform-native length (tweet-length for X, short paragraph for LinkedIn, etc.)
  - Letter/direct mail: Full page is fine, but lead with the hook.
- You MUST use the exact product/brand name, price, and website/CTA from the brief. Do not rename or rebrand.

Write your first draft now.
```

### Audience Agent Prompt Template

```
You are {persona_name}, a member of the target audience:
{persona_description}

You care most about: {what_they_care_about}
You'd scroll past content that: {scroll_past_trigger}
You'd stop for content that: {stop_trigger}

You are a judge on a panel evaluating {platform} copy. Your job is to score submissions honestly and critically. The copy is trying to get you to {goal}.

SCORING INSTRUCTIONS:
For each submission you receive, score it on these criteria (1-5 scale, where 1 = terrible, 3 = decent, 5 = exceptional):
{criteria_list_with_descriptions}

In addition to scores, for EACH submission write 2-3 sentences of rationale explaining your scores. Be specific — "it's good" is useless. Say what worked, what didn't, and what would make you more likely to {goal}.

Be genuinely critical. If something doesn't resonate with you as a {demographic_detail}, say so. Don't be polite — be honest. A score of 3 should be your baseline for "fine but forgettable." Reserve 4-5 for copy that actually moves you.

FORMAT YOUR RESPONSE EXACTLY LIKE THIS (for each submission):

## Writer: {writer_name}
| Criterion | Score |
|-----------|-------|
| {criterion_1} | {score} |
| {criterion_2} | {score} |
| ... | ... |
| Overall favorite | {score} |

**Rationale:** {2-3 sentences}
```

## Step 4: Run the Tournament

### Round Loop

For each round:

#### 4a. Collect submissions

- **Round 1:** Writer agents already produced their first draft when spawned. Collect those.
- **Rounds 2+:** Spawn fresh writer agents with full context: persona, brief, their previous submission, feedback from the round, and competitor scores. Each agent produces a revised draft. Spawn all writers in parallel.

#### 4b. Send to audience

Spawn fresh audience agents (one per audience member) with their persona + all submissions for this round. Spawn all audience evaluations in parallel. Format for the submissions block:

```
ROUND {N} — Score these {num_writers} submissions:

=== SUBMISSION: {writer_1_name} ===
{copy_text}

=== SUBMISSION: {writer_2_name} ===
{copy_text}

=== SUBMISSION: {writer_3_name} ===
{copy_text}

Score each one using the format I gave you.
```

Spawn all audience evaluations in parallel.

#### 4c. Parse scores

From each audience response, extract:
- Per-criterion scores for each writer
- Rationale text for each writer

Aggregate: sum scores across all audience members per criterion per writer. Total score = sum of all criteria sums.

#### 4d. Determine round winner

- **Winner** = writer with highest total score
- **No consensus** = no single writer has the highest total (i.e., a tie at the top). Track consecutive no-consensus count.

#### 4e. Check termination

- If 3 consecutive no-consensus rounds: terminate early, proceed to output.
- If this was the last round: proceed to output.
- If this was the last Phase 1 round: transition to Phase 2 (see below).

#### 4f. Spawn next round's writers with feedback

Since agents are not persistent, each round's writer spawn must include the FULL context: persona, brief, their previous submission, and the feedback. This is critical — without it, writers lose their voice, forget the brand name, or go off-brief.

**Phase 1 writer prompt (differentiation):**
```
You are {persona_name}, a copywriter with this identity:
{persona_description}

Your copywriting philosophy: {philosophy}

THE BRIEF:
- Platform: {platform}
- Product: {product_name} — {product_details}
- Website: {website}
- Goal: Get the reader to {goal}
- Criteria: {criteria_list}

YOUR PREVIOUS SUBMISSION:
{their_previous_copy}

ROUND {N} RESULTS — Your scores:
{writer's own score table with all criteria}
{writer's own rationale from each audience member}

Competitor scores (no copy shown):
- {other_writer_name}: Total {score}
- {other_writer_name}: Total {score}

You {won/lost} this round. {If lost: "You're behind by {X} points."}

IMPORTANT: You MUST use the exact product name "{product_name}" and include the price (${price}) and website ({website}). Stay on-brand.
Now write your next version. Stay true to your voice. Produce ONLY the copy.
```

**Phase 2 writer prompt (convergence):**
```
You are {persona_name}, a copywriter. Your style: {philosophy_short}

THE BRIEF:
- Platform: {platform}
- Product: {product_name} — {product_details}
- Website: {website}
- Goal: Get the reader to {goal}
- Criteria: {criteria_list}

CONVERGENCE PHASE — {winner_name}'s copy won Phase 1. Your job: refine their winning approach using your unique perspective. Build on what's working. Don't rewrite from scratch — improve it.

{WINNER_NAME}'S WINNING COPY:
{winning_copy}

WHAT THE AUDIENCE LOVED:
{bullet list of praised elements from rationale}

WHAT COULD BE BETTER:
{bullet list of weaknesses identified in rationale}

OTHER WRITERS' BEST LINES FROM PHASE 1 (use if they fit):
{best-scoring individual lines from other writers across all Phase 1 rounds}

IMPORTANT: You MUST use the exact product name "{product_name}" and include the price (${price}) and website ({website}).
Produce ONLY the refined copy. No explanations.
```

### Phase Transition

When transitioning from Phase 1 to Phase 2:
- Record the Phase 1 final standings (all writers' last submissions + cumulative scores) — these are the "Phase 1 finalists" for output
- Identify the Phase 1 winner (highest cumulative score across all Phase 1 rounds)
- The first Phase 2 round shares the winning copy with all writers

## Step 5: Generate Output

After the final round (or early termination), build an HTML results page.

### Data to include

**Phase 1 finalists:**
- Each writer's final Phase 1 submission
- Their total Phase 1 score breakdown by criterion
- Their persona description

**Phase 2 winner:**
- The final winning submission from the last round
- Its score breakdown
- Which writer produced it

**Round-by-round history (collapsible):**
- Each round: all submissions, all scores, all rationale, round winner

### HTML Generation

Write the HTML file to `$TMPDIR/copytest-results-{timestamp}.html` and open it with `open` command.

Read the HTML template from `references/output-template.html` and populate it with the tournament data. The template expects a single JavaScript object `TOURNAMENT_DATA` to be injected.

The data structure to inject:

```javascript
const TOURNAMENT_DATA = {
  config: {
    platform: "...",
    goal: "...",
    context: "...",
    criteria: ["...", "..."],
    demographic: "...",
    totalRounds: 10,
    phase1Rounds: 7,
    phase2Rounds: 3
  },
  writers: [
    { name: "...", persona: "...", philosophy: "..." }
  ],
  audience: [
    { name: "...", persona: "...", cares_about: "..." }
  ],
  phase1Finalists: [
    {
      writer: "Writer Name",
      copy: "Their final Phase 1 copy",
      totalScore: 42,
      scores: { "Persuasiveness": 13, "Humor": 11, ... },
      rank: 1
    }
  ],
  phase2Winner: {
    writer: "Writer Name",
    copy: "The final refined copy",
    totalScore: 48,
    scores: { "Persuasiveness": 14, "Humor": 12, ... }
  },
  rounds: [
    {
      number: 1,
      phase: 1,
      submissions: [
        { writer: "Name", copy: "...", scores: {...}, totalScore: 38, rationale: [{audience: "Name", text: "..."}] }
      ],
      winner: "Writer Name"
    }
  ]
};
```

After opening the HTML file, tell the user where it's saved and that it's open in their browser.

## Error Handling

- If a writer agent returns something other than just copy (adds meta-commentary, explanations), extract only the copy portion and SendMessage telling them: "Only output the copy itself. No explanations."
- If an audience agent doesn't follow the scoring format, SendMessage with the format reminder and ask them to re-score.
- If an agent fails to respond after 2 retries, remove it from the tournament and adjust (if a writer, continue with fewer; if an audience member and count becomes even, note the reduced panel).

## Important Notes

- **Agents are ephemeral.** Every round spawns fresh agents. There is no SendMessage/persistent agent capability. Always include full context (persona, brief, previous copy, feedback) in every agent prompt.
- **Use `model: sonnet`** for all writer and audience agent spawns to manage cost.
- Spawn all Round 1 writer agents in parallel.
- Within each round, spawn all audience evaluations in parallel.
- Between rounds, spawn all writer agents in parallel with their feedback.
- The skill should run to completion without pausing for user input between rounds. Report results at the end.
- Track cumulative scores across rounds for determining the Phase 1 winner (not just the last round's scores).
- **Open results with:** `open -a "Google Chrome" /path/to/file.html` (the generic `open` command may fail on macOS).

## Lessons Learned (from test runs)

**v1 test — 2026-03-19 (Bear Butter, 3 rounds, 3 writers, 3 audience):**

1. **Writers lose brand identity without full context.** When a writer agent was spawned for Round 2 without the full brief, it renamed the product ("Wilderness Formula"), dropped the price, and removed the website URL. Fix: every writer spawn must include the exact product name, price, website, and a reminder to use them.

2. **Platform-specific length guidance matters.** The "craftsman" writer (Hank) consistently wrote landing-page-length copy for a Facebook ad. All three audience members dinged him for length. Fix: added explicit platform-specific length guidance to the writer prompt template.

3. **Phase 2 convergence benefits from surfacing best individual lines.** When the convergence prompt included specific standout lines from other writers ("mostly jojoba and optimism," "headquartered in a WeWork"), the winning writer successfully absorbed them. Without this, convergence is just "rewrite the winner" with no material from the losers.

4. **Audience agents gave genuinely critical feedback without extra prompting.** The "score of 3 = fine but forgettable" calibration instruction worked well. Scores were differentiated and rationale was specific and actionable. No rubber-stamping.

5. **The two-phase structure works as designed.** Phase 1 produced three genuinely different approaches. Phase 2 merged the best elements into a single piece that scored higher than anything in Phase 1 (58 vs. 55 peak). The 70/30 split felt right at 3 rounds (2+1).
