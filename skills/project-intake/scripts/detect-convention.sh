#!/usr/bin/env bash
# detect-convention.sh — infer the project tracker convention from existing projects.
#
# Usage: detect-convention.sh <projects_path>
#
# Prints one of:
#   _project_md_inside  — most projects have _project.md inside their folder
#   sibling_md          — most projects have a <name>.md beside their folder
#   yaml_front          — most projects have a .project.yaml sidecar
#   none                — projects exist but no dominant convention found
#   unknown             — no projects exist yet (first-time user)
#
# Rules:
#   - Scan up to 10 immediate subdirectories of <projects_path> (skipping hidden
#     dirs, "archive", and underscore-prefixed system dirs like "_meta").
#   - Count how many have each kind of tracker file.
#   - Winner needs at least 3 matches AND at least ceil(60%) of scanned projects.
#   - If multiple conventions tie or nothing reaches the threshold, return "none".
#   - If the directory is empty or doesn't exist, return "unknown".

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "usage: $0 <projects_path>" >&2
    exit 2
fi

PROJECTS_PATH=$1
# Expand tilde.
PROJECTS_PATH="${PROJECTS_PATH/#\~/$HOME}"

if [[ ! -d "$PROJECTS_PATH" ]]; then
    echo "unknown"
    exit 0
fi

# Gather up to 10 project-looking subdirectories.
projects=()
while IFS= read -r dir; do
    base=$(basename "$dir")
    [[ "$base" == .* ]] && continue
    [[ "$base" == archive ]] && continue
    [[ "$base" == _* ]] && continue
    projects+=("$dir")
    [[ ${#projects[@]} -ge 10 ]] && break
done < <(find "$PROJECTS_PATH" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)

total=${#projects[@]}
if [[ $total -eq 0 ]]; then
    echo "unknown"
    exit 0
fi

inside_count=0
yaml_count=0
sibling_count=0

for proj in "${projects[@]}"; do
    [[ -f "$proj/_project.md" ]]    && inside_count=$((inside_count + 1))
    [[ -f "$proj/.project.yaml" ]]  && yaml_count=$((yaml_count + 1))
    [[ -f "${proj}.md" ]]           && sibling_count=$((sibling_count + 1))
done

# Threshold: at least 3 matches AND at least ceil(60%) of scanned projects.
threshold=$(( (total * 6 + 9) / 10 ))
[[ $threshold -lt 3 ]] && threshold=3

# Find the convention with the most matches that also clears the threshold.
winner="none"
best=0
for kv in "inside:$inside_count:_project_md_inside" \
          "yaml:$yaml_count:yaml_front" \
          "sibling:$sibling_count:sibling_md"; do
    IFS=':' read -r _ count name <<< "$kv"
    if (( count > best && count >= threshold )); then
        best=$count
        winner=$name
    fi
done

echo "$winner"
