# crystal.local.yaml keys for project-intake

The skill reads and (on first run) writes two keys in `~/.claude/crystal.local.yaml`. Both live at the top level of the YAML document as simple scalar values. The config helper is intentionally dumb — it expects flat top-level keys and will not parse nested structures.

## `projects_path`

Absolute path to the directory where the user keeps their projects. Tilde (`~`) expansion is supported at read time; the helper stores the literal value as written.

- **Type:** string
- **Required:** yes (prompted on first run if missing)
- **Default on decline:** `~/Documents/Projects`
- **Example:**

```yaml
projects_path: "~/Documents/Projects"
```

## `project_tracker_convention`

How this user organizes per-project metadata files. One of four shapes:

| Value | Meaning | File location relative to `projects_path` |
|---|---|---|
| `_project_md_inside` | A `_project.md` file inside each project folder | `<name>/_project.md` |
| `sibling_md` | A `<name>.md` file beside the project folder | `<name>.md` |
| `yaml_front` | A `.project.yaml` sidecar at the project folder root | `<name>/.project.yaml` |
| `none` | User does not use tracker files at all | — |

- **Type:** string (one of the four values above)
- **Required:** yes (auto-detected and confirmed on first run)
- **Example:**

```yaml
project_tracker_convention: "_project_md_inside"
```

Unrecognized values (typos, old schema leftovers) cause the skill to warn and skip tracker creation rather than crash.

## First-run behavior

If either key is missing, `project-intake` will:

1. For `projects_path`: ask where projects live. Default to `~/Documents/Projects/` if the user presses enter without answering. Create the directory with `mkdir -p` if it doesn't exist.
2. For `project_tracker_convention`: run `scripts/detect-convention.sh "$projects_path"` to scan the first 10 existing project folders. If a dominant convention is found (3+ matches and 60%+ of scanned projects), present it and ask to confirm. If nothing is dominant, ask the user to pick from the four values. If the directory is empty (first-time user, no existing projects), ask directly.
3. Persist both agreed values via `scripts/read-config.sh --write`.

Subsequent runs read both keys without rescanning — zero overhead after first run.

## Legal file shape

The helper only touches the two keys listed above. Other CrystalAI keys in the same file are left alone. Example of a valid file:

```yaml
# CrystalAI Environment Configuration
vault_path: "/Users/someone/obsidian-vault"
projects_path: "~/Documents/Projects"
project_tracker_convention: "_project_md_inside"

user:
  name: "Jane Doe"
  primary_email: "jane@example.com"
```

Nested keys, flow-style YAML, multi-line scalars, and comment-attached values will not parse through the simple grep/sed helper. Stick to flat `key: "value"` for anything this skill needs to touch.

## Write failures

If the config file can't be written (permissions, missing parent directory that won't `mkdir`, upstream YAML syntax broken by hand edits), the helper will exit non-zero. The skill should warn, proceed with in-memory values for the current invocation, and tell the user to fix the file manually before the next run.
