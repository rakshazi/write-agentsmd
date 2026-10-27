# <package>

<What it owns, who calls it, the boundary it must not cross. The Example is fictional: replace it, never copy it. Example: owns the tide-table cache; called by the harbour scheduler; never reads the moon-phase table.>

## Contract

- <Invariant, input/output, wiring, lifecycle.>
- <Concurrency, cache, persistence, or compatibility rule.>

## Landmines

- <Silent failure, ordering constraint, user-confirmed accepted limitation.>

## Verify

`<one scoped test command>`

## Pointers

- `<file>` - <what lives there>.
- Root rules: `<relative path>/AGENTS.md`.
