# Exploration time — Warehouse first pass

The Warehouse now has a cumulative exploration clock measured in steps.
One successful move to a different tile costs one step, whether moving forward
or backward. Entering a trap or an opened door still costs exactly one step.

Turning, blocked moves, searches, switch presses, skill attempts, inventory,
light toggling, and saving/loading are free. Direct placement by dungeon entry
or transitions is not movement and does not advance the clock. Combat rounds
continue to use their separate timing system.

## Try it

Enter the Warehouse and watch `EXPLORATION: 0 steps` at the bottom of the main
view. Move north once: the clock becomes 1. Move backward: it becomes 2.
Turn toward a wall and try walking into it: the count remains unchanged.
Search for the secret door or open a menu: still unchanged. Moving through
the opened door advances it normally. The counter remains visible in darkness.

F5 saves the counter and F9 restores it with the rest of the game. Leaving,
returning, or starting another expedition keeps the cumulative value. Loading
an older save without the field starts it at zero.

## Scope

Dungeon data opts in with `tracks_exploration_time: true`. Only the Warehouse
opts in for this test. `DungeonSystem.exploration_steps` is one cumulative
counter; if other dungeons opt in later, they will share this total rather than
have independent clocks. The optional saved integer `dungeon.exploration_steps`
must be nonnegative. Invalid values reject the save before live mutation.

This is a test clock, not elapsed seconds or minutes. It does not consume fuel,
advance poison, add encounter rolls, reset puzzles, or advance the death
countdown outside combat. Existing movement-triggered encounters remain as
before. Additional time costs and timed consequences require later design.

## Validation

All 37 test suites and headless startup pass. New checks cover forward/backward
movement, blocked and same-position moves, free turns/menus/light/search,
opened passages, trap entry, paused incapacitation countdown, save/load,
expedition persistence, nonparticipating dungeons, and invalid/older saves.
Native Godot rendering was checked for the counter in dark and lit views.
