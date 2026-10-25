---
name: write-agentsmd
description: "Create, audit, trim, or split a repository's agent instructions: AGENTS.md, CLAUDE.md, or nested package files. Use when the user asks to write, update, audit, trim, or split agent instructions, onboard an agent to a repo, or make a repo agent-ready, including when they name CLAUDE.md, Codex, or Copilot instruction files."
metadata:
  version: "1.2.0"
license: "Mixed: GPL-3.0-or-later for code, CC-BY-SA-4.0 for Markdown, CC0-1.0 for assets. See LICENSES/ and REUSE.toml."
compatibility: "Requires bash 3.2+ (macOS default) with POSIX grep, awk, sed, sort, tr, uniq, wc, and dirname; git optional. No network access."
---

# write-agentsmd

Write the repository's agent context file. Every root line is paid on every task.

Scope: `AGENTS.md` and nested variants, plus tool files. READMEs stay user-facing.

Measured: auto-generated files add about 20% cost with no success gain; short curated files cut median runtime 29%. Details: `references/evidence.md`.

## Rules

- MUST keep a line only when it changes what the agent does.
- MUST run every documented read-only command before shipping the line. Ask the user before deploy, apply, migrate, restart, or live data.
- MUST record discovered bugs in `TODO_BEFORE_SHIPPING.md`; MUST NOT fix them in this session.
- MUST NOT document a bug as a caveat, workaround, or pre-existing issue.
- MUST NOT put secrets, tokens, customer data, or credentialed URLs in the file. Name the env var.
- MUST update the file in the same change as the command, path, or invariant it describes.
- MUST keep `AGENTS.md` authoritative. `CLAUDE.md` imports `@AGENTS.md`; Copilot reads `.github/copilot-instructions.md` plus `AGENTS.md` where supported; Codex reads `AGENTS.md`.

## Pick a mode

Pick the first match.

1. **Small edit**: the request changes one line, one command, or one path. Change it. Run the command once if read-only. Confirm the path exists. Stop. MUST NOT run recon, audit, or a behavior test. Escalate if the edit adds a section, changes structure, or covers several rules.
2. **Migration**: the request moves agent rules from a package README into the package `AGENTS.md`. Move them and replace the README copy with a pointer. If the user insists on both, `AGENTS.md` wins and both change together. Delete a README only on explicit request.
3. **Nested**: the request adds `AGENTS.md` files for one or more subtrees. Create 10-60 lines for each named subtree from `assets/nested-template.md`.
4. **New file**: the request writes a root `AGENTS.md` and none exists. Run Recon, draft from `assets/template.md`, run the commands, verify one task.
5. **Audit**: the request reviews or trims any existing `AGENTS.md`, root or nested. Run Audit on that file, cut, fix, verify.

If a root file is missing after modes 2-3, complete New file for the root. In a monorepo, New file and Audit add a nested file for each subtree with a distinct build or contract.

## Recon

Collect facts. Do not write prose yet.

1. **Stack**: read the manifest (`go.mod`, `package.json`, `pyproject.toml`, `Cargo.toml`, `pom.xml`, `build.gradle`, `*.csproj`, `CMakeLists.txt`, `justfile`, `Makefile`), top-level dirs, and CI.
2. **Commands**: build, test, single test, lint, format, typecheck, generate, run. Run read-only commands. Record exact flags.
3. **Generated files**: markers (`DO NOT EDIT`, `zz_generated`, `dist/`, `vendor/`, `*.pb.go`, mocks). Record the regenerate command. A missing generator goes to `TODO_BEFORE_SHIPPING.md`.
4. **Environment**: required env vars and startup prerequisites from README, `.env.example`, config, Dockerfiles. Note which fail startup and which are optional.
5. **Landmines**: grep `must`, `never`, `order`, `race`, `lock`, `legacy`, `workaround`, `keep in sync`, `deprecated`, `prod`, `secret`. Read nested `AGENTS.md` files and the last 20 bugfix commits. A defect goes to `TODO_BEFORE_SHIPPING.md`, never the draft.
6. **Docs**: README, CONTRIBUTING, docs index, package READMEs. If a rule matters and has no source in the repo, ask the user. MUST NOT invent policy.

## Write

Use `assets/template.md` at the root and `assets/nested-template.md` in a subtree. Delete every unused section. A 25-line file is valid.

| Section | Content |
|---|---|
| Project | One or two sentences: what it is, stack, one fact that changes work. |
| Commands | Exact scoped test, single test, full check, lint, build, generate; prerequisites. |
| Layout | Non-obvious paths; mark generated paths. |
| Conventions | Only what a linter or compiler cannot enforce. |
| Testing | Location, one-test command, mocks, regression rule. |
| Git and PR | Only when the repo has a convention. |
| Landmines | Silent failures, ordering, global state, production data, accepted limitations. |
| Boundaries | Always / Ask first / Never, with commands and paths. |
| Pointers | Path plus why and when to load it. |

Size: root 60-150 lines (150-260 for a large monorepo with generated code or policy); nested 10-60. At 200 lines, split. Codex caps the combined chain at 32 KiB.

## What earns a line

Keep only:

- a non-default command with exact flags
- a silent failure, ordering constraint, or late-failing prerequisite
- a boundary or user-confirmed accepted limitation
- a generated file plus its regenerate command
- a verification step that defines done
- a pointer with a purpose and a load trigger

Cut:

- lint, format, naming, import order rules
- repo tours, directory lists, architecture prose
- README copies: setup, install, contribution flow
- vague advice: clean code, best practices, be careful
- `/init` output and unpruned LLM prose
- task procedures and runbooks
- contradictions, stale paths, bare links
- known bugs parked as caveats
- rules an agent can ignore; move them to CI, hooks, or branch protection

## Bugs found

1. Tell the user: file, function, trigger, impact, proposed fix.
2. Record it in `TODO_BEFORE_SHIPPING.md` at the repo root.
3. Keep the code unchanged. The user owns the fix and decides when it lands.
4. An accepted limitation needs explicit user confirmation. Then delete the TODO item and record the reason in the file.
5. Leave `TODO_BEFORE_SHIPPING.md` unignored, delete it before commit, and MUST NOT list it as a pointer.

## Audit

`<skill-dir>` is this skill's absolute directory (the parent of `scripts/`). From the repo root:

```bash
bash <skill-dir>/scripts/audit.sh --strict AGENTS.md
bash <skill-dir>/scripts/audit.sh --strict packages/api/AGENTS.md
bash <skill-dir>/scripts/audit.sh --style AGENTS.md
bash <skill-dir>/scripts/audit.sh --extract-commands AGENTS.md
```

With `--strict`, exit 0 means no warnings, 1 means a hard failure or a warning, 2 means bad invocation. Without it, warnings exit 0. Fix hard failures; keep warnings only as deliberate exceptions. `--style` adds prose checks (ASCII, dashes, contrast negation). `--extract-commands` prints commands to run in a sandbox.

Then check by hand:

- [ ] Every command runs from the repo root with its prerequisites.
- [ ] Every path, symbol, and pointer resolves.
- [ ] No contradiction, stale line, removed feature, or lint rule.
- [ ] No unconfirmed bug documented as a caveat.
- [ ] No subtree-only rule at the root.

## Verify

Run for every new or heavily edited file.

1. Start a fresh session. Ask the agent to list the loaded instruction sources and summarize them. A missing or invented command marks that line.
2. Run every documented read-only command from the repo root, in order. Stop at the first failure and fix the line.
3. Run one real backlog task in a clean checkout. Compare the diff with the file's promises.
4. Cut lines that do not change behavior. Add a line only after the same mistake appears twice.
5. No backlog or git baseline: mark the file unverified. MUST NOT invent a number.

Measured comparison is opt-in: `references/verification.md`. Two conditions, two tasks, five runs each is 20 agent runs.

## References

- `references/evidence.md` - studies and numbers. Read when challenging a limit.
- `references/examples.md` - real files, sizes, patterns. Read when calibrating length.
- `references/stacks.md` - per-stack commands and landmines. Read for an unfamiliar stack.
- `references/maintenance.md` - precedence, re-audit triggers, fossilization. Read when updating.
- `references/verification.md` - measured comparison protocol. Read when the user asks for evidence.
- `assets/template.md`, `assets/nested-template.md` - skeletons to copy and prune.
- `scripts/audit.sh` - mechanical checks; `--help` documents flags.
- `evals/evals.json`, `evals/behavioral.json` - trigger and fixture tests. Read only when tuning.
