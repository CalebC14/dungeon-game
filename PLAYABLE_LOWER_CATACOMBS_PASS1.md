# Imported Lower Catacombs — playable connected test pass

`architect_test_catacombs_lower` adds explicit test content over the imported
25 × 19 Lower Catacombs map. The generated preview and existing Reliquary
content are unchanged. No new mechanics or boss gate are introduced.

## Reach it and return

Enter the imported Nave using F12 → N with an active party, defeat its test
guardian, and follow the connected Archives and Upper Catacombs floors.
At Upper Catacombs `(12,2)`, press Enter to descend. Arrive in the Lower
Catacombs at `(12,16)`, facing north.

Enter at the arrival tile returns immediately to Upper Catacombs `(12,2)`,
facing south. Both transitions require Enter, preventing automatic bouncing.
Continue through the return stairs at `(12,16)` on each prior floor to reach
the Nave and its entrance exit to Thornwake.

## First-pass content

| Position | Content |
| --- | --- |
| (3,3), (7,3), (21,6), (16,13), (20,13), (18,14) | Keyless doors: Enter from adjacent floor opens permanently. |
| (18,16) | Searchable ossuary coin pouch: 25 gold once. |
| (2,2), (21,11) | One-time ossuary and procession lore. |
| (12,15) | One-time testing/return-route notice. |
| (22,2) | Enter descends to the playable imported Chapel. |

Doors require no class, key, or roll. The cache can be searched from adjacent
floor or underfoot. The southern region y=13–18 suppresses random encounters
for testing; other regions use small Skeleton groups. Successful tile movement
advances the shared exploration clock, while floor travel remains free.
No new darkness, fuel, trap, or boss is added in this pass.

## Persistence and limits

Door state, cache collection, lore, floor/position, and exploration steps use
existing saved state. Saving on an opened door works. Re-entry and loading do
not duplicate treasure. States remain namespaced across the connected floors.

The Chapel now has a playable test binding connected at `(22,2)`, with its
return stair at `(12,16)`. See PLAYABLE_CHAPEL_PASS1.md. There is no new direct
developer shortcut or live quest progression. Test through the existing imported
Nave route; the original Reliquary chain is unaffected.

## Validation

All 44 test suites and headless startup pass. New integration coverage checks
stair coordinates/facing, immediate return, no auto bounce, free floor travel,
arrival movement/notice, keyless doors and save-on-door, repeat/saved treasure,
lore, re-entry, Chapel descent/return, and the full return chain to town.
An iterative door-access check proves that opening approachable doors reaches
the cache, both lore markers, and Chapel stair. Encounter and layout
validation report no errors. Native Godot views of the arrival and door were
checked for presentation.
