# Encounter data and reward validation — first pass

## Developer content check

`EncounterValidation.all_errors()` reports contextual errors for:

- Dungeon, wilderness, and legacy weighted-table enemy references, positive
  integer weights, and positive ordered integer group ranges.
- Dungeon table owners that do not reference a known dungeon.
- Fixed encounter IDs (required and unique within their dungeon), floor-tile
  positions, enemy references, positive counts, and nonempty mixed groups.
- Enemy XP and gold ranges: nonnegative integers with maximum at least minimum.
- Dungeon event, interaction, and class-object gold fields, plus event/interaction
  treasure item references when present.

Run the check with Godot's headless script runner:

```
Godot --headless --path /Users/caleb/dungeon-game --script res://tests/test_encounter_validation.gd
```

Use your installed Godot executable in place of `Godot`. The check exits with
an error if content fails; it does not auto-repair data or change encounter
balance. Current authored content passes. Map reachability, transitions,
probability balance, loot drop tables, and quest payouts are outside this
first validator's scope.

## Reward lifecycle

Combat now tracks an encounter-local `rewards_claimed` flag. Starting a random,
specific, or mixed encounter resets it. Victory handling refuses to pay if:

- Rewards were already claimed for the current encounter.
- The enemy list is empty or includes a surviving enemy.
- The whole party is incapacitated/dead, including mutual defeat.

A valid victory claims the encounter before updating boss/quest state and
awarding XP, gold, and loot. Repeated handler calls leave those rewards and
the existing result unchanged. Legitimate future encounters can pay normally.
The guard is encounter-local: combat is not a supported save location. Boss
completion, inventory, XP, and gold use existing persisted state.

This pass retains current XP behavior: only characters above 0 HP share XP,
integer division drops the remainder, and gold is shared. It does not change
reward amounts, item capacity policy, loot probabilities, or quest rewards.

## Testing

All 36 test suites and headless startup pass. The two added suites validate
all current content and deliberately malformed fixtures, then exercise the
Warehouse boss victory, repeated payout attempts, save/load, a subsequent
encounter, successful escape with no rewards, mutual defeat with no rewards,
and mixed-encounter reset. Existing hidden treasure, trap, puzzle, party,
health, and combat tests remain passing.
