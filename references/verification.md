# Verification

The cheap default check is in `SKILL.md`. Load this when the user asks for evidence, or when the file guards an expensive workflow.

## Quantified comparison

1. Pick one ambiguous task and one multi-file task from the backlog.
2. Run each condition on the same starting commit: once with the full chain, once without. Remove the root and nested `AGENTS.md`, `AGENTS.override.md`, `CLAUDE.md` imports or symlinks, and Copilot instructions, or use a clean checkout without them.
3. Compare success, wall time, tokens or credits, diff size, and files touched.
4. Run each condition at least five times and compare medians. One run is noise; a single-run result has flipped sign in practice.
5. Two conditions, two tasks, and five runs is 20 agent runs. Budget for that before starting.
6. A throwaway repo with no backlog and no git baseline cannot support this comparison. Say the file is unverified and hand it off.

## Reading a failed run

- Missed command: the line was unclear, or the command sits in prose. Make it literal and scoped.
- Invented command: the file gave a pattern without an example. Add the real command.
- Wrong directory: state "from the repo root" or the exact path.
- Unnecessary exploration: the file lacks a layout pointer the task needed, or the task was out of scope.
- Repeated mistake: add one line only after the same mistake appears twice.
