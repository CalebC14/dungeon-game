# Imported Upper Catacombs — playable connected test pass

`architect_test_catacombs_upper` layers simple gameplay over the imported
25 × 19 Upper Catacombs map. The generated preview and original Reliquary
content remain unchanged. No new combat or interaction system is added.

## Reach it and return

Enter the imported Nave through F12 → N with an active party. Defeat its test
guardian, descend at `(12,2)` to the Archives, then reach the Archives stair at
`(12,2)` and press Enter. Arrive in the Upper Catacombs at `(12,16)`, facing north.
There is no additional boss gate for this connection in this first pass.

Enter at the arrival tile immediately returns to the Archives at `(12,2)`,
facing south. Stairs require Enter in both directions, so the party does not
bounce automatically. Return through the Archives stair `(12,16)` to the Nave,
then use the Nave entrance `(12,16)` to exit to Thornwake.

## First-pass content

| Position | Content |
| --- | --- |
| (6,3), (7,9), (15,10) | Keyless crypt doors: Enter from an adjacent tile opens permanently. |
| (22,16) | Searchable burial coin pouch: 25 gold once. |
| (3,1), (20,1) | One-time memorial and watcher's lore. |
| (12,15) | One-time test/return-route notice. |
| (12,2) | Unfinished Lower Catacombs notice; no transition onward. |

Door opening requires no class, key, or skill roll. Search the cache from
adjacent floor or underfoot. The southern region y=13–18 suppresses random
battles for arrival and cache testing. Other areas use small groups of existing
Skeletons. Movement advances the shared exploration clock; floor travel itself
is free. No new darkness, fuel, traps, or boss is introduced.

The export notes mention Sisters Bella and Gigi but contain no placed boss
marker on this floor. This pass does not invent a boss position or modify the
existing live Reliquary Sisters encounter. A designed boss can be bound later.

## Persistence and limits

Door states, cache collection, lore, current floor/position, and exploration
steps use existing saved state. Floor changes preserve state for all connected
test floors. Saving while standing on an open crypt door works normally.
Caches cannot pay twice after reloading or returning.

The Lower Catacombs and Chapel remain previews and are not exposed through
this floor. The unfinished stair gives a one-time notice. The imported test
chain has no new world entrance, quest progression, or independent developer
shortcut beyond the existing Nave entry.

## Validation

All 43 test suites and headless startup pass. New integration checks verify
both stair directions and facing, no automatic bounce, arrival movement and
notice, preserved clock, doors and save-on-door, one-time/saved treasure, lore,
closed later floors, and the entire return chain to town. An iterative access
check proves the doors can be approached/opened to reach the cache, lore, and
unfinished stair. Layout and encounter data validate without errors. Native
Godot views of the arrival and crypt door were checked.
