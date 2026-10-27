# <package>

<What it owns, who calls it, the boundary it must not cross. Example: owns the price cache; called by checkout; never reads the orders table.>

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
