#!/usr/bin/env bash
# Fetch the latest claude-kit from raw.githubusercontent.com (on the cloud default allowlist,
# not limited by the session's attached repos) and link it into ~/.claude.
#
#   kit-sync.sh --bootstrap   from the environment setup script: also installs the VM-level
#                             settings.json whose SessionStart hook re-runs this every session
#   kit-sync.sh               from the SessionStart hook: refresh only
#
# Always exits 0: a failed refresh keeps the previous kit and must never block a session.
# stdout becomes session context, so it prints exactly one line.

KIT_REPO="${KIT_REPO:-isokeke/claude-kit}"
KIT_REF="${KIT_REF:-main}"
KIT_DIR="${KIT_DIR:-$HOME/claude-kit}"
CLAUDE_DIR="$HOME/.claude"
RAW="https://raw.githubusercontent.com/$KIT_REPO/$KIT_REF"

fetch_kit() {
  local tmp; tmp="$(mktemp -d)" || return 1
  curl -fsSL --max-time 10 "$RAW/MANIFEST" -o "$tmp/MANIFEST" || { rm -rf "$tmp"; return 1; }
  while IFS= read -r path; do
    [ -z "$path" ] && continue
    case "$path" in \#*) continue ;; esac
    mkdir -p "$tmp/$(dirname "$path")"
    curl -fsSL --max-time 10 "$RAW/$path" -o "$tmp/$path" || { rm -rf "$tmp"; return 1; }
  done < "$tmp/MANIFEST"
  # Swap in atomically-ish: only replace the kit once every file arrived.
  rm -rf "$KIT_DIR.old"; [ -d "$KIT_DIR" ] && mv "$KIT_DIR" "$KIT_DIR.old"
  mv "$tmp" "$KIT_DIR" && rm -rf "$KIT_DIR.old"
}

link_kit() {
  mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/agents"
  for d in "$KIT_DIR"/skills/*/; do [ -d "$d" ] && ln -sfn "${d%/}" "$CLAUDE_DIR/skills/$(basename "$d")"; done
  for f in "$KIT_DIR"/agents/*.md; do [ -f "$f" ] && ln -sfn "$f" "$CLAUDE_DIR/agents/$(basename "$f")"; done
  ln -sfn "$KIT_DIR/vm/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
}

status="fresh"
if [ "${KIT_LOCAL:-}" = "1" ]; then status="local"      # testing: use files already in KIT_DIR
else fetch_kit || status="fetch failed, using cached kit"; fi

if [ -f "$KIT_DIR/MANIFEST" ]; then
  link_kit
  if [ "${1:-}" = "--bootstrap" ] && [ ! -f "$CLAUDE_DIR/settings.json" ]; then
    cp "$KIT_DIR/vm/settings.json" "$CLAUDE_DIR/settings.json"
  fi
  # Content hash of the manifest's files = kit version (raw.githubusercontent has no commit sha).
  VERSION="$(cd "$KIT_DIR" && grep -v '^#' MANIFEST | xargs cat 2>/dev/null | sha256sum 2>/dev/null | cut -c1-8)"
  [ -z "$VERSION" ] && VERSION="$(cd "$KIT_DIR" && grep -v '^#' MANIFEST | xargs cat | shasum -a 256 | cut -c1-8)"
  echo "$VERSION" > "$CLAUDE_DIR/.kit-version"
  echo "claude-kit version: $VERSION ($status). Use it as kit_version in the PR trailer."
else
  echo "claude-kit: not installed ($status). Skills intake/build/ship unavailable this session."
fi
exit 0
