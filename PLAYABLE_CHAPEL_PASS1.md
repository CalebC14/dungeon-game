# Imported Chapel — playable connected test pass

`architect_test_black_warlock_chapel` completes the five-floor imported test
chain. It uses the exact generated 25 × 19 Chapel geometry with explicit test
bindings. Original Reliquary gameplay/quests and generated previews are unchanged.

## Reach it and return

Start with F12 → N and follow the imported Nave, Archives, Upper Catacombs,
and Lower Catacombs chain. At Lower Catacombs `(22,2)`, Enter descends to Chapel
`(12,16)`, facing north. Enter at arrival returns immediately to Lower Catacombs
`(22,2)`, facing south. Both directions require Enter, preventing auto bounce.

The stair return is available before and after the boss. Continue through the
previous floors to the Nave entrance for its unconditional town exit.

## First-pass content

- Twelve keyless doors at the exported door markers. Enter from adjacent floor
  opens them permanently. No key, roll, class, cost, or toggle-close is added.
- Two hidden offering caches at `(11,2)` and `(13,2)`, worth 25 gold each once.
- A test boss at `(12,5)`: one existing Black Acolyte stands in for Bristle-Aptarj.
  It uses existing targeting/attack/reward rules, not a newly designed boss AI.
- A victory-revealed town exit at `(12,2)`. After winning the test boss encounter,
  Enter at that tile returns to Thornwake. Before victory it has no travel hint
  or usable current transition. The raw transition path still enforces the gate.
- One-time introduction at `(12,15)`. The southern y=13–18 area suppresses random
  encounters; other areas use small Skeleton groups. Fixed encounters stay active.

No live Purge quest or Bristle completion state is changed. The encounter uses
its own test ID/tag, normal Black Acolyte XP/gold/loot, and the existing one-time
victory guard. The full live Bristle enemy stats are intentionally not used.
There is no new spell system, darkness, trap, fuel cost, or boss-balance work.

## Exit and persistence

The exit's `hide_until_defeated` and `requires_defeated` fields use the test
encounter's saved defeated flag. Fleeing does not reveal the exit or complete
the boss. Victory, door openings, caches, current floor/position, and shared
exploration steps persist through saves and re-entry. The revealed exit remains
available after loading. A defeated test boss does not respawn or pay again.
Saving on an open Chapel door restores its passability normally.

The exit is represented by a travel hint on its floor tile, with no new portal
art. The return stair works regardless of exit visibility. Later content is not
required: all five imported floors are now separately bound as test dungeons,
while their generated preview IDs remain unregistered.

## Validation

All 45 test suites and headless startup pass. Integration coverage checks matched
stair coordinates/facing, immediate return, arrival movement, doors and save-on-door,
caches, hidden exit and raw gate enforcement, boss encounter, escape, one-time
victory rewards, unchanged live quests, persisted exit reveal, town completion,
re-entry, and the entire stair return chain. An iterative access check proves
approachable doors lead to both caches, the boss, and exit. Layout and encounter
validation report no errors. Native Godot entry and exit views were checked.
