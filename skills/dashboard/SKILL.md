---
name: crystal:dashboard
description: This skill should be used when the user asks to "show my priorities", "what's on my plate", "show today's tasks", "daily dashboard", or types "/dashboard". Generates an interactive HTML dashboard that opens in the browser.
version: 1.0.0
allowed-tools: Read, Glob, Bash, Write
---

# Interactive Dashboard

Generate a single-file HTML dashboard that opens in the browser, providing a GUI frontend for projects, tasks, sessions, and meetings.

## Output

- **File:** `/tmp/claude/dashboard.html`
- **Behavior:** Generated fresh each invocation, opens automatically in browser
- **Features:** Tab navigation, expandable project cards, clickable email links (message://), obsidian:// links for deep dives, dark theme

## How It Works

### Phase 1: Data Gathering (Parallel)

Run these steps in parallel since they're independent:

#### Step 1.1: Read Today's Daily Note

Use **Read tool** (NOT Bash) to read today's daily note:
```
Read: Daily Notes/YYYY-MM-DD.md
```

Extract:
- **Priorities** (the 3 bullet points under "Priorities:")
- **From Things3 Today** items (under "From Things3 Today:")
- **Session Summaries** (each ### header under "Session Summaries")

If no daily note exists, note this and suggest running `/resume`.

#### Step 1.2: Query Things3 for Today's Tasks

**IMPORTANT: Use `dangerouslyDisableSandbox: true` for this call.**

```bash
osascript -e 'tell application "Things3" to set todayTodos to to dos of list "Today"
set output to ""
repeat with t in todayTodos
  set taskName to name of t
  set output to output & "- " & taskName & linefeed
end repeat
return output'
```

If Things3 is unavailable, skip gracefully.

#### Step 1.3: Glob Session Files (Last 7 Days)

Use **Glob tool** to find recent session files:
```
Glob: state/sessions/2026-02-*.md
```

**Parse filenames only** (don't read content). Extract:
- Date (YYYY-MM-DD)
- Time (HHmm)
- Topic (rest of filename)

Example: `2026-02-27-1445-email-batch-processing.md` → Feb 27, 14:45, "email batch processing"

Note: session logs are now stored in CrystalAI `state/sessions/` — update glob pattern to match current year/month.

#### Step 1.4: Glob Meeting Files (Last 14 Days)

Use **Glob tool** to find recent meeting files:
```
Glob: Areas/Work/Meeting notes/2026-02-*.md
```

**Parse filenames only** (don't read content). Extract:
- Date (YYYY-MM-DD)
- Format (text in first [brackets])
- People (text in second [brackets])
- Topic (rest after brackets)

Example: `2026-02-26 [Call] [Kim, Tracy Suh] Spectrum VOIP.md` → Feb 26, Call, Kim + Tracy Suh, "Spectrum VOIP"

#### Step 1.5: Glob Project Files

Use **Glob tool** to list all projects:
```
Glob: Projects/*.md
```

Exclude `_template.md`.

### Phase 2: Read Active Projects Only

For each project file from Phase 1.5, use **Read tool** to read **only active projects** (status != complete).

Extract from each active project:
- **Frontmatter:** status, date-created, tags
- **Overview:** First paragraph after `## Overview`
- **Action Item Count:** Count of unchecked `- [ ]` items
- **Email Links:** All `message://` URLs with their link text

Skip reading completed/archived projects - just note their filename for the completed list.

### Phase 3: Generate HTML Dashboard

Build a single HTML file with embedded CSS/JS. Use the template below, populating the `DASHBOARD_DATA` object with gathered data.

**Write to:** `/tmp/claude/dashboard.html`

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Dashboard - {TODAY_FORMATTED}</title>
  <style>
    :root {
      --bg-primary: #1a1a2e;
      --bg-secondary: #16213e;
      --bg-card: #0f3460;
      --text-primary: #e8e8e8;
      --text-secondary: #a0a0a0;
      --accent-green: #4ade80;
      --accent-yellow: #facc15;
      --accent-blue: #60a5fa;
      --accent-gray: #6b7280;
      --accent-purple: #a78bfa;
      --border-color: #374151;
    }

    * { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: var(--bg-primary);
      color: var(--text-primary);
      line-height: 1.6;
      min-height: 100vh;
    }

    .header {
      background: var(--bg-secondary);
      padding: 1.5rem 2rem;
      border-bottom: 1px solid var(--border-color);
    }

    .header h1 {
      font-size: 1.5rem;
      font-weight: 600;
    }

    .header .date {
      color: var(--text-secondary);
      font-size: 0.9rem;
    }

    .tabs {
      display: flex;
      gap: 0;
      background: var(--bg-secondary);
      border-bottom: 1px solid var(--border-color);
      padding: 0 2rem;
    }

    .tab {
      padding: 1rem 1.5rem;
      cursor: pointer;
      color: var(--text-secondary);
      border-bottom: 2px solid transparent;
      transition: all 0.2s;
      font-weight: 500;
    }

    .tab:hover { color: var(--text-primary); }

    .tab.active {
      color: var(--accent-blue);
      border-bottom-color: var(--accent-blue);
    }

    .content {
      padding: 2rem;
      max-width: 1200px;
      margin: 0 auto;
    }

    .panel { display: none; }
    .panel.active { display: block; }

    .section {
      margin-bottom: 2rem;
    }

    .section-title {
      font-size: 1.1rem;
      font-weight: 600;
      margin-bottom: 1rem;
      color: var(--text-secondary);
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }

    .card {
      background: var(--bg-card);
      border-radius: 8px;
      padding: 1rem 1.25rem;
      margin-bottom: 0.75rem;
      border: 1px solid var(--border-color);
    }

    .card-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      cursor: pointer;
    }

    .card-title {
      font-weight: 600;
      font-size: 1rem;
    }

    .card-meta {
      display: flex;
      gap: 0.75rem;
      align-items: center;
    }

    .badge {
      padding: 0.25rem 0.5rem;
      border-radius: 4px;
      font-size: 0.75rem;
      font-weight: 500;
      text-transform: uppercase;
    }

    .badge-active { background: var(--accent-green); color: #000; }
    .badge-on-hold { background: var(--accent-yellow); color: #000; }
    .badge-planning { background: var(--accent-blue); color: #000; }
    .badge-complete { background: var(--accent-gray); color: #fff; }

    .expand-icon {
      transition: transform 0.2s;
      color: var(--text-secondary);
    }

    .card.expanded .expand-icon {
      transform: rotate(180deg);
    }

    .card-body {
      display: none;
      margin-top: 1rem;
      padding-top: 1rem;
      border-top: 1px solid var(--border-color);
    }

    .card.expanded .card-body {
      display: block;
    }

    .overview {
      color: var(--text-secondary);
      margin-bottom: 1rem;
    }

    .links {
      display: flex;
      flex-wrap: wrap;
      gap: 0.5rem;
    }

    .link {
      display: inline-flex;
      align-items: center;
      gap: 0.25rem;
      padding: 0.25rem 0.75rem;
      background: var(--bg-secondary);
      border-radius: 4px;
      color: var(--accent-blue);
      text-decoration: none;
      font-size: 0.85rem;
      transition: background 0.2s;
    }

    .link:hover {
      background: var(--bg-primary);
    }

    .link-email {
      color: var(--accent-purple);
    }

    .list-item {
      padding: 0.75rem 1rem;
      background: var(--bg-card);
      border-radius: 6px;
      margin-bottom: 0.5rem;
      display: flex;
      justify-content: space-between;
      align-items: center;
      border: 1px solid var(--border-color);
    }

    .list-item-title {
      font-weight: 500;
    }

    .list-item-meta {
      color: var(--text-secondary);
      font-size: 0.85rem;
    }

    .task-list {
      list-style: none;
    }

    .task-item {
      padding: 0.5rem 0;
      border-bottom: 1px solid var(--border-color);
      display: flex;
      align-items: flex-start;
      gap: 0.5rem;
    }

    .task-item:last-child {
      border-bottom: none;
    }

    .task-bullet {
      color: var(--accent-blue);
      margin-top: 0.1rem;
    }

    .priority-item {
      padding: 0.75rem 1rem;
      background: var(--bg-card);
      border-radius: 6px;
      margin-bottom: 0.5rem;
      border-left: 3px solid var(--accent-green);
    }

    .stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
      gap: 1rem;
      margin-bottom: 2rem;
    }

    .stat-card {
      background: var(--bg-card);
      border-radius: 8px;
      padding: 1rem;
      text-align: center;
      border: 1px solid var(--border-color);
    }

    .stat-value {
      font-size: 2rem;
      font-weight: 700;
      color: var(--accent-blue);
    }

    .stat-label {
      color: var(--text-secondary);
      font-size: 0.85rem;
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }

    .empty-state {
      text-align: center;
      padding: 2rem;
      color: var(--text-secondary);
    }

    .action-count {
      font-size: 0.85rem;
      color: var(--accent-yellow);
    }

    .completed-projects {
      display: flex;
      flex-wrap: wrap;
      gap: 0.5rem;
    }

    .completed-link {
      padding: 0.25rem 0.75rem;
      background: var(--bg-secondary);
      border-radius: 4px;
      color: var(--text-secondary);
      text-decoration: none;
      font-size: 0.85rem;
    }

    .completed-link:hover {
      color: var(--text-primary);
    }
  </style>
</head>
<body>
  <div class="header">
    <h1>Dashboard</h1>
    <div class="date">{TODAY_FORMATTED}</div>
  </div>

  <div class="tabs">
    <div class="tab active" data-tab="overview">Overview</div>
    <div class="tab" data-tab="projects">Projects</div>
    <div class="tab" data-tab="meetings">Meetings</div>
    <div class="tab" data-tab="sessions">Sessions</div>
  </div>

  <div class="content">
    <!-- Overview Panel -->
    <div id="overview" class="panel active">
      <div class="stats-grid">
        <div class="stat-card">
          <div class="stat-value">{TASK_COUNT}</div>
          <div class="stat-label">Tasks Today</div>
        </div>
        <div class="stat-card">
          <div class="stat-value">{ACTIVE_PROJECT_COUNT}</div>
          <div class="stat-label">Active Projects</div>
        </div>
        <div class="stat-card">
          <div class="stat-value">{SESSION_COUNT}</div>
          <div class="stat-label">Sessions (7d)</div>
        </div>
        <div class="stat-card">
          <div class="stat-value">{MEETING_COUNT}</div>
          <div class="stat-label">Meetings (14d)</div>
        </div>
      </div>

      <div class="section">
        <div class="section-title">Priorities</div>
        {PRIORITIES_HTML}
      </div>

      <div class="section">
        <div class="section-title">Things3 Today</div>
        {TASKS_HTML}
      </div>

      <div class="section">
        <div class="section-title">Active Projects</div>
        {ACTIVE_PROJECTS_HTML}
      </div>
    </div>

    <!-- Projects Panel -->
    <div id="projects" class="panel">
      <div class="section">
        <div class="section-title">Active Projects</div>
        {ACTIVE_PROJECTS_HTML}
      </div>

      <div class="section">
        <div class="section-title">Completed Projects</div>
        {COMPLETED_PROJECTS_HTML}
      </div>
    </div>

    <!-- Meetings Panel -->
    <div id="meetings" class="panel">
      <div class="section">
        <div class="section-title">Recent Meetings (14 days)</div>
        {MEETINGS_HTML}
      </div>
    </div>

    <!-- Sessions Panel -->
    <div id="sessions" class="panel">
      <div class="section">
        <div class="section-title">Recent Sessions (7 days)</div>
        {SESSIONS_HTML}
      </div>
    </div>
  </div>

  <script>
    // Tab switching
    document.querySelectorAll('.tab').forEach(tab => {
      tab.addEventListener('click', () => {
        document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
        document.querySelectorAll('.panel').forEach(p => p.classList.remove('active'));
        tab.classList.add('active');
        document.getElementById(tab.dataset.tab).classList.add('active');
      });
    });

    // Card expansion
    document.querySelectorAll('.card-header').forEach(header => {
      header.addEventListener('click', () => {
        header.closest('.card').classList.toggle('expanded');
      });
    });
  </script>
</body>
</html>
```

### Phase 4: Open in Browser

```bash
open /tmp/claude/dashboard.html
```

## Template Sections

### Priorities HTML
```html
<div class="priority-item">{PRIORITY_TEXT}</div>
```
If no priorities, show: `<div class="empty-state">No priorities set. Run /resume to set them.</div>`

### Tasks HTML
```html
<ul class="task-list">
  <li class="task-item">
    <span class="task-bullet">•</span>
    <span>{TASK_NAME}</span>
  </li>
</ul>
```

### Active Project Card HTML (expandable)
Use the same expandable card format for projects on both Overview and Projects tabs:
```html
<div class="card">
  <div class="card-header">
    <span class="card-title">{PROJECT_NAME}</span>
    <div class="card-meta">
      <span class="badge badge-{STATUS}">{STATUS}</span>
      <span class="expand-icon">▼</span>
    </div>
  </div>
  <div class="card-body">
    <p class="overview">{OVERVIEW}</p>
    <div class="links">
      <a href="obsidian://open?vault=VaultyBoi&file={FILE_PATH}" class="link">Open in Obsidian</a>
      {EMAIL_LINKS}
    </div>
  </div>
</div>
```

### Email Link HTML
```html
<a href="{MESSAGE_URL}" class="link link-email">📧 {LINK_TEXT}</a>
```

### Completed Projects HTML
```html
<div class="completed-projects">
  <a href="obsidian://open?vault=VaultyBoi&file={FILE_PATH}" class="completed-link">{PROJECT_NAME}</a>
</div>
```

### Meeting Item HTML
```html
<div class="list-item">
  <div>
    <span class="list-item-title">{TOPIC}</span>
    <span class="list-item-meta">{PEOPLE}</span>
  </div>
  <div class="card-meta">
    <span class="list-item-meta">{DATE} • {FORMAT}</span>
    <a href="obsidian://open?vault=VaultyBoi&file={FILE_PATH}" class="link">Open</a>
  </div>
</div>
```

### Session Item HTML
```html
<div class="list-item">
  <div>
    <span class="list-item-title">{TOPIC}</span>
    <span class="list-item-meta">{TIME}</span>
  </div>
  <div class="card-meta">
    <span class="list-item-meta">{DATE}</span>
    <a href="obsidian://open?vault=VaultyBoi&file={FILE_PATH}" class="link">Open</a>
  </div>
</div>
```

## Key Rules

- **Minimal reads** — Only read today's daily note + active projects
- **Filename parsing** — Extract session/meeting info from filenames, not content
- **Single HTML file** — All CSS/JS inline, no external dependencies
- **Dark theme** — Matches terminal aesthetic
- **Links work** — `message://` for emails, `obsidian://` for notes

## Error Handling

- **No daily note:** Show empty priorities, suggest `/resume`
- **Things3 unavailable:** Show "Things3 unavailable" in tasks section
- **No active projects:** Show "No active projects" message
- **No meetings/sessions:** Show "No recent meetings/sessions" message
