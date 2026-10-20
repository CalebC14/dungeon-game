# Warehouse layout and pacing — first pass

The Warehouse now separates a quiet mechanics-testing area from the deeper
rat-patrol route. Existing test-object positions are preserved.

## Layout

One wall at `(3,12)` becomes a floor connector between the southern aisle
`(3,13)` and loading corridor `(3,11)`. Together with the existing western
entrance, it creates a small loop. The secret passage at `(5,12)` and Sun/Moon
gate at `(9,12)` remain optional additional connections. The original route to
the Rat Broodmother at `(13,1)` stays accessible with all mechanisms closed.

The new loop does not remove the floor trap at `(4,11)`. Classes, keys, secret
searches, and puzzle completion are not mandatory for reaching the boss.

## Pacing and walkthrough

1. Enter at `(1,13)`. Move north to `(1,12)` to read the loading-aisle notice.
2. Use the southern aisle for class-skill tests, and either connector at x=1
   or x=3 to reach the key corridor at y=11.
3. Test the key `(2,11)`, floor trap `(4,11)`, hidden treasure `(6,11)`, locked
   door `(7,10)`, and lever `(7,9)`. Search or disarm before stepping onto hazards.
4. Continue east to test darkness and the Sun/Moon switches. L lights the free
   lantern. Solve the optional gate to reconnect to the southern aisle.
5. When ready for combat, head east to x=13 and then north. The warning at
   `(13,10)` introduces the deeper patrol area. Continue exploring toward the
   northeast nest.

Random encounters are disabled in x=1–13/y=11–13 and x=6–7/y=9–10, including
the door and lever test area. These are `Rect2i` entries in `quiet_areas`.
Walls inside those rectangles remain walls. Elsewhere the existing random
encounter chance and Giant Rat table are unchanged. Both notices are one-time
lore events; their first display gets the usual event priority over a random
encounter. Repeated visits to the warning tile can roll encounters normally.

Quiet areas prevent random battles only: traps still deal damage, fixed
encounters still trigger first, and successful movement still advances the
exploration clock. Other dungeons have no quiet areas and retain prior pacing.
Notice consumption uses existing persistent event save state.

## Validation

All 38 test suites and headless startup pass. A new breadth-first route check
proves the boss is reachable with closed barriers and every test object has an
accessible floor tile or adjacent interaction position. Behavioral tests force
100% random encounters to verify quiet-area suppression and deeper patrols,
then check notices, persistent consumption, traps, and fixed-encounter priority.
This is a simple test layout, not final encounter balance or a full dungeon
reachability validator.
