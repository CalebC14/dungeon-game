# Warehouse puzzle — first pass

Two switches open the sorting gate permanently. The clue on both switches and
the closed gate reads **Sun before Moon**. Press Sun, then Moon. Any wrong
press (including Sun twice) resets the sequence; it causes no damage or cost.
The puzzle is optional and the existing boss route remains accessible.

## Try it

Reach the southern Warehouse corridor at y=11 using the original route or
secret door. Stand at `(8,11)`, face north, and press Enter for the Sun switch.
Walk east to `(10,11)`, face north, and press Enter for the Moon switch.
The sorting gate at `(9,12)` opens, connecting `(9,11)` and `(9,13)`.
Switches also work when directly ahead. A P map marker identifies each switch;
the gate is marked D and turns teal when open.

Try Moon first, or Sun twice, to test the reset. You can retry indefinitely.
No class, item, skill roll, gold, or HP is required or awarded. Solved switches
leave the gate open on all later interactions.

## State and data

Switch interactions use type `puzzle_switch`, a unique `id`, `name`,
`puzzle_id` naming the gate, and `step` (1 for Sun, 2 for Moon). The destination
uses type `puzzle_door`. This first pass supports exactly two ordered presses.
The gate's namespaced state stores boolean `primed` for partial progress and
`open` for completion. Both persist through saves, re-entry, and expeditions.
The gate uses the existing passability overlay; its original map wall is
unchanged. Saves on the opened gate load correctly. Disconnected switches
report an error without changing state. Earlier saves start unsolved.

## Validation

31 Godot test suites and headless startup pass. New coverage checks clues,
wrong order, repeated first switch, retry, restored partial progress, permanent
completion, traversal, saves on the gate, re-entry, combat restrictions,
malformed state, and disconnected switch data.
