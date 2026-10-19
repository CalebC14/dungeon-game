# Dungeon interactions — Warehouse first pass

A reusable, data-driven interaction resolver now supports keys, locked doors,
levers, and shortcuts. The Warehouse provides a small optional test route. No
new class, skill roll, resource cost, or puzzle prerequisites are required.
Existing Rogue/class objects and the rat boss route remain accessible.

## Walkthrough

Enter the Abandoned Warehouse with an active party. Starting at `(1,13)`, face
north and move two tiles to `(1,11)`, then move east one tile to `(2,11)`.

1. Press Enter to pick up the **Warehouse brass key** at `(2,11)`.
2. Continue east to `(7,11)`, face north, and press Enter to unlock the
   **Warehouse store door** at `(7,10)`.
3. Move north onto the opened door tile. Press Enter to pull the adjacent
   **Cross-passage lever** at `(7,9)`.
4. Move north onto `(7,9)` and face west. The **Warehouse cross-passage** at
   `(6,9)` is now open. Walk west through it into the other storage corridor.

Normal exploration encounters still apply while walking. The existing G exit
shortcut and class skill test objects remain available.

## Rules and feedback

Enter interacts with the object directly ahead, falling back to the current
tile. The brass key uses the existing shared party quest-item keyring and is
reusable. Picking it up removes its map marker; it cannot be farmed or sold.
The door stays locked without it and remains open after unlocking. Pulling the
lever opens the cross-passage permanently; repeated pulls do not toggle it shut.

Closed barriers block movement in either direction. Open barriers behave as
floor for movement, the first-person view, and the map. The reference map data
is never modified: persistent state supplies a passability overlay. The
cross-passage connects two storage corridors and genuinely shortens their
previous walking detour. The original route to the boss works before any of
these interactions are used, and the lever can also be reached by exploring
that original layout.

The first-person view uses simple door, key, and lever drawings. Map labels:
K = key, D = door, L = lever, S = shortcut. Closed barriers are brown; opened
barriers are teal. Side-panel text explains the target and outcome.

## Reusable data

Dungeon data has an `interactions` dictionary keyed by tile position. Entries
have an ID, type, and name. Locked doors specify a `key_id`. Keys award that ID.
Levers specify an `opens` array of door/shortcut IDs and an optional message.
These are predefined actions; dungeon data never executes arbitrary scripts.
Lever destinations are checked before any state changes are applied.

Interaction state is namespaced by dungeon and object ID. It survives leaving,
starting a new expedition, and save/load. The new save field is optional for
older saves. Restoring applies the passability overlay before validating the
saved location, so loading while standing on an open door or shortcut works.
Malformed interaction state leaves the current game unchanged.

This first pass uses explicit key-based doors and one-way lever activation.
Rogue lockpicking for real doors, consumable keys, toggling mechanisms, multi-step
puzzles, and secret-door discovery remain separate extensions.

## Validation

Godot 4.7.2: all 26 tests pass, including the prior 24 regression suites. New
tests cover key pickup, missing keys, barrier movement, reusable keys, lever
activation, idempotence, shorter path distance, persistence, opened-tile saves,
older saves, malformed state, and compatibility with skill interactions.
Headless startup passes. Native Godot renders of the closed door, key, lever,
and opened shortcut were checked visually.
