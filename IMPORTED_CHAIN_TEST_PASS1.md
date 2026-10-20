# Full imported dungeon chain — first test pass

A new end-to-end smoke test drives the five-floor imported chain through the
actual game controller. No gameplay data or balance changes are made.

## Automated route

1. Load the unmodified six-character test party and enter with F12 → N.
2. Walk to the Nave cache and guardian, then descend to the Archives.
3. Fight the Archives guardian, collect its southern cache, and descend.
4. Save to a unique temporary file at Upper Catacombs arrival, turn, then reload
   with the normal F5/F9 handlers. Compare the full saved state with the checkpoint.
5. Walk to the Upper cache, then the Lower cache, and continue into the Chapel.
6. Fight the Chapel boss through ordinary combat resolution, collect both
   offering caches, and use the revealed exit to Thornwake.
7. Re-enter the Nave and search the first cache again to check it cannot pay twice.

Navigation uses keyboard movement/turns and Enter to open doors and use stairs.
A breadth-first route planner can plan through keyless doors, but it must face,
open, and walk through each one using normal input. It never teleports the party.
Combat submits normal actions through `queue_current_action`: front members
attack, rear Magician/Priest use their existing abilities, and the rear Bard
defends. It never zeros enemy HP, grants stats, forces victory flags, or adds
out-of-combat healing. The default party wins all three placed encounters.

The fixed seed is 123456. Random encounters are disabled only in the test
instance, leaving fixed battles active. This is a repeatable connectivity,
persistence, and integration check, not random-encounter balance testing or a
full combat-menu UI automation test.

## Results

All 46 test suites and headless startup pass. The full-chain run completes
three real battles, opens eight doors on its chosen route, and walks 262 tiles
including the final Nave re-entry check. These are test-route totals, not a
recommended dungeon length or encounter pacing target.

The test asserts one-time payouts for six caches, per-move exploration time,
free stair travel, exact disk checkpoint restoration, all three fixed victory
flags across floors, completion at Thornwake, and unchanged live quest state.
Its temporary save is removed afterward. Existing per-floor tests continue to
cover alternate caches, doors, traps, lore, return chains, escape, and defeat.

## Manual smoke test

Use the per-floor walkthroughs, starting at PLAYABLE_CHURCH_NAVE_PASS1.md.
F12 → N enters the chain with an active party. At the Chapel, after winning,
stand at `(12,2)`, **face north**, and press Enter to exit. Facing an adjacent
cache prioritizes searching it instead. This is the existing facing-object
interaction rule; no runtime behavior was changed for the test.

Save/load partway through, then check that prior doors remain open, collected
caches remain empty, and defeated guardians do not respawn. You can always
return through stairs to the Nave entrance instead of using the final exit.
Manual random-encounter pacing and extended balance playtesting remain pending.

## Run

```
Godot --headless --path /Users/caleb/dungeon-game --script res://tests/test_imported_chain.gd
```

Replace `Godot` with the installed executable. Failure to reach a route target,
open a door, win a fixed battle within the action limit, restore state, or finish
the journey causes the script to exit with an error.

## Random pacing follow-up

Imported floors now have a lower random-encounter rate and saved movement
protection; see IMPORTED_ENCOUNTER_PACING_PASS1.md. This end-to-end test keeps
random battles disabled to isolate connectivity and persistence. Its state
checkpoint also covers the new pacing fields.

## Random-enabled companion

The random-disabled journey remains as a focused integration baseline.
`tests/test_imported_chain_random.gd` now reuses its route with normal random
encounters enabled and adds battle spacing, quiet-area, and party-resource
reporting. See IMPORTED_CHAIN_RANDOM_TEST_PASS1.md for seeded results and
resource-cost limitations.
