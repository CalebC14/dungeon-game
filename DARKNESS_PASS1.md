# Darkness — Warehouse first pass

The corridor tiles `(8,11)` through `(12,11)` and sorting gate `(9,12)` are
dark. With the lantern off, the main view is obscured and the map shows only
the player's tile and its eight immediate neighbors. Distant map markers are
hidden too. Nearby interaction hints, facing, coordinates, and party status
remain readable. Darkness does not change collisions or combat rules.

## Try it

Reach `(8,11)` using the key corridor at y=11. The lantern starts off. The main
view says it is too dark to see ahead. Press L to light the lantern: the normal
view and map return. Press L again to extinguish it. The position line shows
the light setting. Moving back to `(7,11)` also restores ordinary visibility,
because that tile is outside the dark area.

The Sun/Moon switches and gate remain usable without light. For testing,
interactions do not require visibility and nearby hints still describe them.
The lantern is free, has no fuel, and requires no inventory item or class.
It can be toggled during dungeon exploration, including ordinary lit areas,
but not from combat or management menus. Holding L does not repeatedly toggle.

## Data and saves

Dungeon data defines `dark_tiles`, an array of grid positions. Other dungeons
without it keep normal visibility. The lantern setting is party-wide, persists
across dungeon changes and expeditions, and is saved as the optional boolean
`dungeon.lantern_on`. Older saves default it to false. Invalid saved values are
rejected before changing the live game.

The map restriction is temporary and does not erase anything. This pass does
not introduce explored-map memory, fuel, spell light, enemy darkness penalties,
or darkness-specific encounters.

## Validation

All 32 Godot test suites and headless startup pass. Darkness tests check lit
and unlit visibility, nearby map range, usable interactions, lantern input and
key repeat, no resource cost, saved on/off state, leaving dark areas, expedition
persistence, malformed saves, older saves, and combat restrictions. Native
Godot screenshots of both views were checked for layout and visibility.
