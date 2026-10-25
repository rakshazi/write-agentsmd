#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Nikita Chernyi <https://rakshazi.me>
# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck disable=SC2016,SC1091,SC2154
# Core regression suite for scripts/audit.sh. Run: bash scripts/tests/run.sh
set -u
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"

# Root-level init fossilization used to pass an empty relative path to git log.
d=$tmp/root-fossil
write_agents "$d" '# Demo

## Commands

- Test: `true`'
gitinit "$d"
out=$(run "$d" AGENTS.md); rc=$?
check_rc 0 "$rc" "root fossilization: exits 0"
check_contains "only one commit touches AGENTS.md" "$out" "root fossilization: root pathspec is a bare filename"
check_contains "init fossilization risk" "$out" "root fossilization: warning fires"

# Nested files keep working.
d=$tmp/nested-fossil
write_agents "$d/pkg" '# pkg

## Verify

`true`'
gitinit "$d"
out=$(run "$d/pkg" AGENTS.md); rc=$?
check_rc 0 "$rc" "nested fossilization: exits 0"
check_contains "only one commit touches pkg/AGENTS.md" "$out" "nested fossilization: warning fires"

# Missing parent directory must be reported with and without a trailing slash.
d=$tmp/missing-dir
write_agents "$d" '# Demo

## Commands

- Test: `true`

## Layout

- `src/nothere/` - deleted subtree.
- `src/nothere` - same path without a trailing slash.'
out=$(run "$d" AGENTS.md); rc=$?
check_rc 0 "$rc" "missing top-level dir: warning only"
check_contains "missing relative path: src/nothere/" "$out" "missing top-level dir: trailing slash reported"
check_contains "missing relative path: src/nothere" "$out" "missing top-level dir: bare path reported"
out=$(run "$d" --strict AGENTS.md); rc=$?
check_rc 1 "$rc" "missing top-level dir: strict fails"
check_contains "strict: 2 warning(s)" "$out" "missing top-level dir: strict summary"

# Override files join the chain and shadow the plain file.
d=$tmp/override-chain
write_agents "$d" '# Demo

## Commands

- Test: `true`'
head -c 33000 /dev/zero | tr '\0' 'x' > "$d/AGENTS.override.md"
out=$(run "$d" AGENTS.md); rc=$?
check_rc 1 "$rc" "override chain: exits 1"
check_contains "AGENTS.override.md shadows this file" "$out" "override chain: shadow warning"
check_contains "combined chain is" "$out" "override chain: chain includes override"
check_contains "AGENTS.override.md" "$out" "override chain: override named"

# The Codex global file counts toward the chain.
d=$tmp/global-chain
write_agents "$d" '# Demo

## Commands

- Test: `true`'
mkdir -p "$tmp/codex"
head -c 33000 /dev/zero | tr '\0' 'x' > "$tmp/codex/AGENTS.md"
out=$(cd "$d" && CODEX_HOME="$tmp/codex" bash "$audit" AGENTS.md 2>&1); rc=$?
check_rc 1 "$rc" "global chain: exits 1"
check_contains "codex/AGENTS.md" "$out" "global chain: global file named"

# An empty global override falls back to the non-empty global AGENTS.md.
d=$tmp/global-empty
write_agents "$d" '# Demo

## Commands

- Test: `true`'
mkdir -p "$tmp/codex-empty"
: > "$tmp/codex-empty/AGENTS.override.md"
head -c 33000 /dev/zero | tr '\0' 'x' > "$tmp/codex-empty/AGENTS.md"
out=$(cd "$d" && CODEX_HOME="$tmp/codex-empty" bash "$audit" AGENTS.md 2>&1); rc=$?
check_rc 1 "$rc" "empty global override: exits 1"
check_contains "codex-empty/AGENTS.md" "$out" "empty global override: falls back to AGENTS.md"
check_absent "codex-empty/AGENTS.override.md" "$out" "empty global override: override not counted"

# The raw template fails strict and passes default.
d=$tmp/template
mkdir -p "$d"
cp "$root/assets/template.md" "$d/AGENTS.md"
out=$(run "$d" AGENTS.md); rc=$?
check_rc 0 "$rc" "raw template: default exits 0"
out=$(run "$d" --strict AGENTS.md); rc=$?
check_rc 1 "$rc" "raw template: strict exits 1"
check_contains "template placeholder" "$out" "raw template: placeholders reported"

# Style checks are opt-in.
d=$tmp/style
mkdir -p "$d"
printf '# Demo\n\n## Commands\n\n- Test: `true`\n\nCaf\xc3\xa9 and a \xe2\x80\x94 b.\n' > "$d/AGENTS.md"
out=$(run "$d" AGENTS.md); rc=$?
check_rc 0 "$rc" "style: default exits 0"
check_absent "em or en dash" "$out" "style: dash check off by default"
check_absent "non-ASCII" "$out" "style: ASCII check off by default"
out=$(run "$d" --style AGENTS.md); rc=$?
check_rc 0 "$rc" "style: opt-in exits 0"
check_contains "em or en dash" "$out" "style: dash check opt-in"
check_contains "non-ASCII" "$out" "style: ASCII check opt-in"

# Command extraction prints commands and skips plain paths.
d=$tmp/extract
mkdir -p "$d"
cat > "$d/AGENTS.md" <<'EOF'
# Demo

## Commands

```bash
go test ./...
# this is a comment
```

Run `just lint` or read `src/app.py`.
EOF
out=$(run "$d" --extract-commands AGENTS.md); rc=$?
check_rc 0 "$rc" "extract: exits 0"
check_contains "candidate commands in AGENTS.md" "$out" "extract: header printed"
check_contains "go test ./..." "$out" "extract: fenced command printed"
check_contains "just lint" "$out" "extract: inline command printed"
check_absent "src/app.py" "$out" "extract: plain path skipped"
check_absent "this is a comment" "$out" "extract: fenced comment skipped"

# Bad invocations.
d=$tmp/invoke
write_agents "$d" '# Demo

## Commands

- Test: `true`'
out=$(run "$d" --nope AGENTS.md); rc=$?
check_rc 2 "$rc" "bad flag: exits 2"
out=$(run "$d" missing.md); rc=$?
check_rc 2 "$rc" "missing file: exits 2"
out=$(run "$d" --strict --extract-commands AGENTS.md); rc=$?
check_rc 2 "$rc" "conflicting flags: exits 2"

# Static guard against bash 4-only idioms.
if grep -qE 'declare -A|declare -n|mapfile|readarray|local -n|&>>|coproc|wait -n|\$\{[A-Za-z_][A-Za-z0-9_]*(\^\^?|,,?|@[QEPAa])' "$audit"; then
  nope "bash 3.2 compatibility: bash 4-only idiom found"
else
  ok "bash 3.2 compatibility: no bash 4-only idiom"
fi

finish
