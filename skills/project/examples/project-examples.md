# /project Skill Examples

Real-world usage examples for quick project creation.

## Example 1: Simple Project Creation

### Scenario
User wants to start tracking a new work project.

### Command
```
User: /project
```

or

```
User: "Create a new project"
```

### Interaction
```
Claude: I'll help you create a new project. What would you like to name this project?

User: Website Redesign

Claude: What's the current status of this project?
Options:
- Planning (initial phase, gathering requirements)
- Active (currently working on it)
- Paused (on hold temporarily)
- Complete (finished)

User: Planning

Claude: Can you provide a brief description of this project? (Optional - press Enter to skip)

User: Redesign company website with modern UI and improved performance

Claude: Creating project...

Created project: Website Redesign
- File: Projects/website-redesign.md
- Status: Planning
- Started: 2026-01-30
- Added to CLAUDE.md Active Projects
- Opened in Obsidian for editing
```

### Result
- File created: `Projects/website-redesign.md`
- CLAUDE.md updated with project entry
- Obsidian opens with new project file
- User can immediately start adding details

---

## Example 2: Quick Project Without Details

### Scenario
User has a vague idea and wants to create project placeholder.

### Command
```
User: "Start a new project called API Migration"
```

### Interaction
```
Claude: I'll help you create a new project. What would you like to name this project?

User: API Migration

Claude: What's the current status?

User: Planning

Claude: Brief description? (Optional)

User: [presses Enter to skip]

Claude: Created project: API Migration
- File: Projects/api-migration.md
- Status: Planning
- Started: 2026-01-30
- Opened in Obsidian for editing

You can add details to the project file when ready.
```

### Result
- Minimal project file created
- User can flesh out details later
- Project tracking started immediately

---

## Example 3: Project Already Exists

### Scenario
User tries to create a project that already exists.

### Command
```
User: "Create a new project"
User: Obsidian Smart Assistant
```

### Interaction
```
Claude: A project with this name already exists at:
Projects/obsidian-smart-assistant.md

What would you like to do?
1. Open existing project
2. Choose a different name
3. Overwrite (not recommended)

User: 1

Claude: Opening existing project: Obsidian Smart Assistant
[Opens in Obsidian]
```

### Result
- No duplicate created
- User directed to existing project
- Data preserved

---

## Example 4: Creating Multiple Projects

### Scenario
User wants to set up several project trackers at once.

### Command
```
User: "I need to create three new projects"
```

### Interaction
```
Claude: I'll help you create the projects one at a time.

Let's start with the first project. What would you like to name it?

User: Q1 Planning

Claude: Status?
User: Active

Claude: Description?
User: Quarterly planning and goal setting for Q1 2026

Claude: Created project: Q1 Planning
[Opens in Obsidian]

Now for the second project. What's the name?

User: Team Onboarding

Claude: Status?
User: Planning

Claude: Description?
User: [skips]

Claude: Created project: Team Onboarding

Final project. What's the name?

User: Performance Optimization

Claude: Status?
User: Active

Claude: Description?
User: Optimize application performance and reduce load times

Claude: Created project: Performance Optimization

Summary:
Created 3 projects:
- Q1 Planning (Active)
- Team Onboarding (Planning)
- Performance Optimization (Active)

All projects added to CLAUDE.md Active Projects section.
```

### Result
- 3 project files created
- All added to CLAUDE.md
- Ready for independent tracking

---

## Example 5: Project with Special Characters

### Scenario
Project name has special characters and spaces.

### Command
```
User: "Create a new project"
User: API v2.0 Migration & Cleanup
```

### Interaction
```
Claude: Creating project: API v2.0 Migration & Cleanup

Status?
User: Planning

Description?
User: Migrate to API v2.0 and clean up deprecated endpoints

Claude: Created project: API v2.0 Migration & Cleanup
- File: Projects/api-v20-migration-cleanup.md
- Status: Planning
- Opened in Obsidian
```

### Result
- Special characters removed from filename
- Spaces converted to hyphens
- Display name preserves original formatting
- File: `api-v20-migration-cleanup.md`

---

## Example 6: Integration with /compress

### Scenario
User works on a project and compresses the session.

### Full Workflow
```
09:00 - User: "Create a new project"
        User: Infrastructure Upgrade
        Claude: [Creates project]

09:15 - User: "Let's work on the infrastructure upgrade"
        [Work session with Claude]

11:00 - User: /compress

        Claude: Analyzing session...

        What should I preserve?
        ✅ Key learnings
        ✅ Decisions made
        ✅ Pending tasks

        Which project is this related to?
        Options:
        - Infrastructure Upgrade
        - Website Redesign
        - (None)

        User: Infrastructure Upgrade

        Claude: Session compressed
        - Created: state/sessions/2026-01-30-0900-infrastructure.md
        - Linked to project: Infrastructure Upgrade
        - Created 3 tasks in Things3 (tagged: infrastructure-upgrade)
        - Updated project Current State section
```

### Result
- Session log links to project
- Project file updated with session reference
- Tasks created in Things3 with project tags
- Complete traceability

---

## Example 7: Quick Project from Conversation

### Scenario
During a conversation, user realizes they need to track this as a project.

### Conversation
```
User: "I've been thinking about improving our documentation"

Claude: "That's a great idea. What aspects of the documentation would you like to improve?"

User: "The API docs are outdated and hard to navigate. Actually, let's make this a project."

User: /project

Claude: Creating new project. What's the name?

User: Documentation Improvement

Claude: Status?
User: Planning

Claude: Description?
User: Update API documentation and improve navigation

Claude: Created project: Documentation Improvement
- Added to CLAUDE.md
- Opened in Obsidian

Our conversation about documentation has been captured. Would you like me to add this discussion to the project file's Notes section?

User: Yes

Claude: Added conversation context to project notes.
```

### Result
- Conversation context preserved
- Project tracking started mid-discussion
- Seamless workflow integration

---

## Example 8: Project Status Updates

### Scenario
User wants to update project status later.

### Command
```
User: "Update the Website Redesign project status to Active"
```

### Interaction
```
Claude: I'll update the Website Redesign project status.

[Reads project file]
[Updates status from "Planning" to "Active"]
[Updates "Last Updated" timestamp]
[Updates CLAUDE.md entry]

Updated: Website Redesign
- Status: Planning → Active
- Last Updated: 2026-01-30

Would you like to add a note about what triggered the status change?

User: Yes, we got approval from stakeholders

Claude: Added to Key Decisions:
"### 2026-01-30: Project Status Change to Active
- Decision: Move from Planning to Active
- Rationale: Received stakeholder approval
- Impact: Full development can begin"
```

### Result
- Status updated in project file
- CLAUDE.md updated
- Decision documented
- Change tracked

---

## Example 9: Completing a Project

### Scenario
User finishes a project and wants to mark it complete.

### Command
```
User: "Mark the API Migration project as complete"
```

### Interaction
```
Claude: I'll mark the API Migration project as complete.

[Updates project file]
- Status: Active → Complete
- Completed: 2026-01-30
- Last Updated: 2026-01-30

[Updates CLAUDE.md entry to show "Complete"]

Project completed: API Migration
Started: 2026-01-15
Completed: 2026-01-30
Duration: 15 days

This entry will be archived from CLAUDE.md during the next auto-archive (when file exceeds 280 lines).

Would you like to add final notes or retrospective thoughts to the project?

User: Yes, the migration went smoothly with no downtime

Claude: Added to Notes section:
"Project completed successfully with zero downtime. The planning phase (5 days) was crucial for the smooth execution."
```

### Result
- Project marked complete
- Completion date recorded
- CLAUDE.md updated
- Ready for archiving

---

## Example 10: Error - Template Missing

### Scenario
Template file is missing or deleted.

### Command
```
User: /project
User: New Project
```

### Interaction
```
Claude: I'll create the project, but I notice the project template is missing:
Projects/_template.md

I'll create a minimal project file with basic structure.

Created project: New Project
- File: Projects/new-project.md
- Status: Planning
- Basic structure provided

Recommendation: Recreate the project template for future projects with:
- Goals section
- Current State tracking
- Key Decisions log
- Things3 Tasks integration
```

### Result
- Project still created (don't block user)
- Minimal structure provided
- User notified of issue
- Graceful degradation

---

## Command Variations

### Direct Skill Call
```
User: /project
→ Prompts for project details
→ Creates project interactively
```

### Explicit Request
```
User: "Create a new project"
→ Triggers /project skill
→ Same interactive flow
```

### With Context
```
User: "Let's start a new project called Dashboard Redesign"
→ Triggers /project skill
→ Pre-fills name: "Dashboard Redesign"
→ Still prompts for status and description
```

### Variation: "Set up project"
```
User: "Set up a project for the new mobile app"
→ Triggers /project skill
→ Extracts name: "New Mobile App"
```

---

## Integration Patterns

### Pattern 1: Project → Work → Compress
```
Morning:
User: /project
Create: "Q1 Goals Review"

Work session:
User: "Let's work on the Q1 goals"
[Discussion and planning]

End of day:
User: /compress
Link session to "Q1 Goals Review"
Create tasks in Things3

Result: Complete tracking from start to tasks
```

### Pattern 2: Retrospective Project Creation
```
User: "We've been working on performance optimization for a week"
User: "Let's create a project to track this"
User: /project
Create: "Performance Optimization"
Status: Active (already in progress)

Result: Retroactive project tracking started
```

### Pattern 3: Resume → Check Projects
```
User: /resume

Claude shows:
- Active Projects:
  - Website Redesign (Planning)
  - API Migration (Active)
  - Documentation Improvement (Planning)
- Recent sessions linked to projects
- Things3 tasks tagged with projects

User: "Let's work on the Documentation Improvement project"

Result: Context loaded, ready to work
```

### Pattern 4: Meeting → Project Creation
```
User: [Meeting notes in +Inbox/]
User: /process-inbox

Claude: "This meeting discusses a new initiative. Should I create a project for it?"
User: Yes

Claude: Creates project from meeting context
- Name extracted from meeting topic
- Stakeholders from meeting attendees
- Initial goals from meeting notes

Result: Project bootstrapped from meeting
```

---

## Best Practices from Examples

**Do:**
- Create projects early (even with minimal details)
- Update project status as work progresses
- Link sessions to projects via /compress
- Use projects to organize Things3 tasks
- Document key decisions in project files
- Complete projects when done (don't leave open forever)

**Don't:**
- Wait for "perfect" project definition
- Duplicate project tracking in multiple places
- Forget to link sessions to projects
- Leave completed projects in Active status
- Overcomplicate project structure initially

**Key Insight:**
Quick project creation with minimal friction encourages better tracking. Details can be added iteratively as the project evolves.

---

## Performance & UX

### Typical Timing
```
Skill invocation: < 100ms
User interaction: Variable (depends on user input)
File creation: 10-50ms
CLAUDE.md update: 10-30ms
Obsidian opening: 200-500ms
Total user experience: ~1 second after providing input
```

### User Experience
- Feels fast and responsive
- Interactive prompts are clear
- Obsidian opens smoothly
- Project immediately usable
- No manual file navigation needed

---

## Common Questions

**Q: Can I create a project without opening Obsidian?**
A: Yes, the Obsidian opening step can fail gracefully. File is still created and added to CLAUDE.md.

**Q: Can I bulk-create projects from a list?**
A: Not directly, but you can create them one at a time in quick succession. Each takes ~30 seconds with interaction.

**Q: What if I forget to create a project?**
A: You can create it retroactively anytime. Just backdate the "Started" field if needed.

**Q: How do I rename a project?**
A: Best approach: create new project with correct name, manually copy content, delete old project, update CLAUDE.md references.

**Q: Can I have sub-projects?**
A: Not formally, but you can mention parent/child relationships in the Overview section and link between project files.

**Q: What's the limit on number of projects?**
A: No hard limit. Practical limit: ~20-30 active projects before CLAUDE.md becomes unwieldy. Complete and archive finished projects regularly.
