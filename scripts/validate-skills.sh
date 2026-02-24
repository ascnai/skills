#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

failures=0

error() {
  echo "ERROR: $*" >&2
  failures=1
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    error "missing required command: $1"
  fi
}

trim_quotes() {
  local value="$1"
  value="${value%\"}"
  value="${value#\"}"
  value="${value%\'}"
  value="${value#\'}"
  echo "$value"
}

frontmatter_value() {
  local file="$1"
  local key="$2"
  awk -v key="$key" '
    BEGIN { in_fm = 0 }
    /^---$/ {
      if (in_fm == 0) { in_fm = 1; next }
      else { exit }
    }
    in_fm == 1 {
      if ($0 ~ ("^" key ":[[:space:]]*")) {
        sub("^" key ":[[:space:]]*", "", $0)
        print $0
        exit
      }
    }
  ' "$file"
}

require_cmd jq

if [[ ! -f ".claude-plugin/skills.json" ]]; then
  error "missing .claude-plugin/skills.json"
fi

if [[ ! -f "skills/index.yaml" ]]; then
  error "missing skills/index.yaml"
fi

index_value() {
  local skill_id="$1"
  local field="$2"
  awk -v id="$skill_id" -v field="$field" '
    /^[[:space:]]*-[[:space:]]id:[[:space:]]*/ {
      current=$0
      sub(/^[[:space:]]*-[[:space:]]id:[[:space:]]*/, "", current)
      in_block=(current == id)
      next
    }
    in_block == 1 && $0 ~ ("^[[:space:]]*" field ":[[:space:]]*") {
      val=$0
      sub("^[[:space:]]*" field ":[[:space:]]*", "", val)
      print val
      exit
    }
  ' skills/index.yaml
}

while IFS= read -r skill_dir; do
  skill_id="$(basename "$skill_dir")"
  skill_file="$skill_dir/SKILL.md"

  for req in SKILL.md README.md VERSION CHANGELOG.md contracts references agents; do
    if [[ ! -e "$skill_dir/$req" ]]; then
      error "$skill_id missing required path: $req"
    fi
  done

  if [[ ! -f "$skill_file" ]]; then
    continue
  fi

  name="$(frontmatter_value "$skill_file" "name")"
  version="$(frontmatter_value "$skill_file" "version")"
  owner="$(frontmatter_value "$skill_file" "owner")"
  maturity="$(frontmatter_value "$skill_file" "maturity")"
  description="$(frontmatter_value "$skill_file" "description")"

  name="$(trim_quotes "$name")"
  version="$(trim_quotes "$version")"
  owner="$(trim_quotes "$owner")"
  maturity="$(trim_quotes "$maturity")"
  description="$(trim_quotes "$description")"

  if [[ "$name" != "$skill_id" ]]; then
    error "$skill_id frontmatter name must equal skill id ($skill_id), got: $name"
  fi

  version_file="$(cat "$skill_dir/VERSION" | tr -d '[:space:]')"
  if [[ "$version" != "$version_file" ]]; then
    error "$skill_id frontmatter version ($version) != VERSION file ($version_file)"
  fi

  json_path="$(jq -r --arg id "$skill_id" '.skills[] | select(.id == $id) | .path' .claude-plugin/skills.json)"
  json_version="$(jq -r --arg id "$skill_id" '.skills[] | select(.id == $id) | .version' .claude-plugin/skills.json)"
  json_owner="$(jq -r --arg id "$skill_id" '.skills[] | select(.id == $id) | .owner' .claude-plugin/skills.json)"
  json_maturity="$(jq -r --arg id "$skill_id" '.skills[] | select(.id == $id) | .maturity' .claude-plugin/skills.json)"
  json_description="$(jq -r --arg id "$skill_id" '.skills[] | select(.id == $id) | .description' .claude-plugin/skills.json)"

  if [[ -z "$json_path" || "$json_path" == "null" ]]; then
    error "$skill_id missing in .claude-plugin/skills.json"
  else
    if [[ "$json_path" != "skills/$skill_id" ]]; then
      error "$skill_id json path must be skills/$skill_id, got: $json_path"
    fi
    if [[ "$json_version" != "$version_file" ]]; then
      error "$skill_id json version ($json_version) != VERSION ($version_file)"
    fi
    if [[ "$json_owner" != "$owner" ]]; then
      error "$skill_id json owner ($json_owner) != SKILL.md owner ($owner)"
    fi
    if [[ "$json_maturity" != "$maturity" ]]; then
      error "$skill_id json maturity ($json_maturity) != SKILL.md maturity ($maturity)"
    fi
    if [[ "$json_description" != "$description" ]]; then
      error "$skill_id json description mismatch with SKILL.md"
    fi
  fi

  idx_path="$(trim_quotes "$(index_value "$skill_id" "path")")"
  idx_version="$(trim_quotes "$(index_value "$skill_id" "version")")"
  idx_owner="$(trim_quotes "$(index_value "$skill_id" "owner")")"
  idx_maturity="$(trim_quotes "$(index_value "$skill_id" "maturity")")"
  idx_description="$(trim_quotes "$(index_value "$skill_id" "description")")"

  if [[ -z "$idx_path" ]]; then
    error "$skill_id missing in skills/index.yaml"
  else
    if [[ "$idx_path" != "./$skill_id" && "$idx_path" != "skills/$skill_id" ]]; then
      error "$skill_id index path must be ./$skill_id or skills/$skill_id, got: $idx_path"
    fi
    if [[ "$idx_version" != "$version_file" ]]; then
      error "$skill_id index version ($idx_version) != VERSION ($version_file)"
    fi
    if [[ "$idx_owner" != "$owner" ]]; then
      error "$skill_id index owner ($idx_owner) != SKILL.md owner ($owner)"
    fi
    if [[ "$idx_maturity" != "$maturity" ]]; then
      error "$skill_id index maturity ($idx_maturity) != SKILL.md maturity ($maturity)"
    fi
    if [[ "$idx_description" != "$description" ]]; then
      error "$skill_id index description mismatch with SKILL.md"
    fi
  fi
done < <(find skills -mindepth 1 -maxdepth 1 -type d | sort)

if rg -n "skills/skills/" skills/*/SKILL.md >/dev/null 2>&1; then
  error "found invalid duplicated path segment skills/skills/ in SKILL.md files"
fi

if [[ "$failures" -ne 0 ]]; then
  echo "Skill validation failed." >&2
  exit 1
fi

echo "Skill validation passed."
