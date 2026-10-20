# Imported Archives — playable connected test pass

`architect_test_archives` is a separate playable binding over the generated
25 × 19 Archives preview. Original Reliquary floors and quests are unchanged;
the generated preview is unmodified. The Nave trapdoor now connects to this
floor instead of acting as a temporary town exit.

## Reach it and return

1. With an active party, use F12 → N to enter the imported Nave test.
2. Defeat the Nave guardian at `(12,4)` and press Enter to continue after combat.
3. Go to `(12,2)` and press Enter. Arrive in the Archives at `(12,16)`, north-facing.
4. Enter at the arrival tile immediately returns to the Nave at `(12,2)`, facing
   south. Both stair transitions require Enter, preventing automatic bouncing.
5. The Nave entrance `(12,16)` remains an unconditional exit to Thornwake.

The Nave guardian gate is preserved. A party cannot descend before defeating
it, and its defeat persists across floor changes and saves.

## First-pass content

From the Archives arrival, walk north twice to `(12,14)`, turn east, and move
one tile to `(13,14)` for the guardian. It uses one existing Skeleton, with
normal rewards and no changes to the live Reliquary quest. After victory, face
north and press Enter to open the Archivist's door at `(13,13)`.

All six imported door markers become keyless doors: Enter from adjacent floor
to open permanently. No keys, skill rolls, rewards, or closing/toggling behavior
are added. Doors show D on the map, brown while closed and teal when open.
Closed doors block movement; open doors use the existing passability overlay.

| Position | Content |
| --- | --- |
| (11,5), (4,7), (20,7), (4,11), (20,11), (13,13) | Keyless doors. |
| (2,2), (22,16) | Searchable caches, 25 gold each, once. |
| (2,16) | One-time ritual ledger lore. |
| (12,15) | One-time testing/return-route notice. |
| (12,2) | Enter descends to the playable imported Upper Catacombs. |

The lower region y=12–18 has no random battles, while fixed encounters remain
active. Northern areas use small Skeleton groups. Movement advances the shared
exploration counter. There is no new darkness or fuel requirement.

## Persistence and boundaries

Door states, caches, lore, and guardian defeat use namespaced IDs and persist
through saves and travel. Saves made standing on an opened door restore its
passability before validating position. Both floors share party inventory,
health, gold, and exploration time. Re-entry cannot repeat permanent rewards.

The Upper Catacombs now has a playable test binding. Enter at `(12,2)` descends
to its `(12,16)` return stair. No additional boss gate is added in this pass.
See PLAYABLE_UPPER_CATACOMBS_PASS1.md. There is no separate direct Archives
developer shortcut; test it through the connected Nave route.

## Validation

All 42 test suites and headless startup pass. Integration coverage includes
actual movement from arrival to the guardian, both stair directions, no auto
bounce, the Nave gate, door opening/traversal and save-on-door, two one-time
caches and saved collection, guardian persistence, unchanged quest state,
Upper Catacombs link and return, and returning to town. An iterative door-access check proves
that opening approachable doors reaches both caches and the upper stair marker.
Native Godot views of the arrival and closed door were checked.

At the end of the Archives pass, the layout report covered 15 dungeons with zero errors and 12 warnings:
ten barrier-dependent content warnings across the test Nave/Archives, plus the
two pre-existing disconnected-floor warnings. Door access is intentional and
covered by integration tests; warnings have not been suppressed.
