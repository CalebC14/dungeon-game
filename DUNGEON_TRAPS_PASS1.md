# Dungeon traps — first pass

The Warehouse contains a visible floor spike trap at `(4,11)`, on the corridor
between the brass key and the locked store door. It is optional; the existing
route around the Warehouse remains available.

## Try it

From the entrance `(1,13)`, face north and move twice to `(1,11)`. Turn east
and move to `(3,11)`. The red T marker and floor spikes identify the trap ahead.

- Walk east onto `(4,11)` to trigger it. The first conscious active character
  in formation order loses 4 HP. Moving backward onto a trap also triggers it.
- Alternatively, face it from `(3,11)`, press R, choose Disarm Trap (2), and
  press Enter. The K class menu uses the same target and rules.
- Disarming has the existing 70% test chance. Success makes the floor safe.
  Failure triggers the trap on the selected Rogue for 4 HP.

Traps fire once. Spent and disarmed traps show a teal T and cannot damage the
party or accept another disarm attempt. They give no gold or items. State and
attempt history persist through dungeon re-entry, new expeditions, and saves.
Older saves without trap state treat the trap as active.

Damage uses normal incapacitation rules and never advances the death timer
outside combat. Full-party defeat enters the existing reload-last-save flow.
On a trap-triggering step, the game resolves the trap before encounters and
keeps its damage message visible; no encounter is rolled on that step.

## Data and scope

Add an interaction with a unique `id`, `type: "trap"`, `name`, and `damage` on
a walkable tile. Trap state uses the shared dungeon interaction save dictionary,
with boolean `triggered` and `disarmed` flags. No map mutation is needed.

This pass uses visible, single-use damage traps. Hidden detection, resettable
traps, poison, scaling difficulty, and tools are left for later design.

## Validation

28 Godot test suites and headless startup pass. Trap tests cover forward and
backward movement, target selection, one-shot damage, successful and failed
disarms, incapacitation, persistent safe states, and full-party defeat.
