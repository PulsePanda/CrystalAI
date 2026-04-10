#!/usr/bin/env python3
"""UserPromptSubmit hook: classify prompt intent and provide routing hints."""

import json
import re
import sys

CATEGORIES = {
    "CAPTURE": {
        "keywords": [
            r"just had", r"quick note", r"reminder", r"don't forget",
            r"capture this", r"write this down", r"jot this down",
        ],
        "hint": "Consider saving to +Inbox/ in the vault",
    },
    "DECISION": {
        "keywords": [
            r"decided", r"decision", r"we chose", r"agreed to",
            r"let's go with", r"the call is", r"we're going with",
        ],
        "hint": "Consider logging in the relevant project file under Key Decisions",
    },
    "WIN": {
        "keywords": [
            r"shipped", r"launched", r"completed", r"achieved",
            r"won", r"promoted", r"kudos", r"shoutout",
            r"great feedback", r"recognized",
        ],
        "hint": "Consider capturing in +Inbox/ with a brag-worthy tag for later",
    },
    "TASK": {
        "keywords": [
            r"add a task", r"remind me to", r"todo", r"need to",
            r"can you add", r"create a task", r"add to todoist",
        ],
        "hint": "Consider creating in Todoist (single source of truth for tasks)",
    },
    "PROJECT_UPDATE": {
        "keywords": [
            r"project update", r"sprint", r"milestone",
            r"shipped feature", r"released", r"deployed",
        ],
        "hint": "Consider updating the relevant project file in Projects/",
    },
    "MEETING_NOTE": {
        "keywords": [
            r"just had a meeting", r"meeting notes", r"call with",
            r"meeting with",
        ],
        "hint": "Consider creating a meeting note in +Inbox/ for later processing",
    },
    "EMAIL": {
        "keywords": [
            r"send an email", r"reply to", r"draft a message to",
            r"draft an email", r"email to", r"write an email",
        ],
        "hint": "Consider using /email or /write skill for drafting",
    },
    "PERSON_CONTEXT": {
        "keywords": [
            r"told me", r"said that", r"feedback from", r"met with",
            r"talked to", r"spoke with", r"mentioned that",
        ],
        "hint": "Consider updating the person file in Areas/People/ if one exists",
    },
}


def classify(prompt):
    """Classify prompt and return matching categories with hints."""
    matches = []
    prompt_lower = prompt.lower()

    for category, config in CATEGORIES.items():
        for keyword in config["keywords"]:
            # Use word boundaries for whole-word matching
            pattern = r"\b" + keyword + r"\b"
            if re.search(pattern, prompt_lower):
                matches.append({"category": category, "hint": config["hint"]})
                break  # One match per category is enough

    return matches


def main():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)

    prompt = data.get("prompt", "")
    if not prompt:
        sys.exit(0)

    matches = classify(prompt)

    if not matches:
        sys.exit(0)

    context_lines = []
    for m in matches:
        context_lines.append(f"[{m['category']}] {m['hint']}")

    output = {
        "hookSpecificOutput": {
            "hookEventName": "UserPromptSubmit",
            "additionalContext": "Prompt classification:\n" + "\n".join(f"- {line}" for line in context_lines)
        }
    }
    json.dump(output, sys.stdout)
    sys.exit(0)


if __name__ == "__main__":
    main()
