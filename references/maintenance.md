# Maintenance

Load this when updating an existing file or after the repo moves.

- Update the file in the same change as the command, path, or invariant it describes.
- When a README gives up its agent rules, replace the README copy with a pointer, then update root pointers, code comments, and docs in the same change. Search for the old path.
- Re-audit after renames, dependency upgrades, build system changes, and architecture moves.
- When the user accepts a limitation, delete its item from `TODO_BEFORE_SHIPPING.md` and document the limitation with the reason.
- Watch for init fossilization: one commit touches the file and the repo moved on. Re-run recon on the commands and paths before trusting it.
- Remove a line when the behavior it prevents becomes impossible, or when the tool now enforces it.
- Keep the root file a map of the traps. The encyclopedia belongs in docs.
- Precedence: `AGENTS.md` is authoritative for agents. When a rule appears in both `AGENTS.md` and a README, the README points at `AGENTS.md` and the two never carry the same rule.
