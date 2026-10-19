# Secret doors — Warehouse first pass

A hidden storage passage at `(5,12)` connects the southern corridor `(5,13)`
to the key corridor `(5,11)`. It uses an existing wall tile and the shared
interaction system. The base map is unchanged.

## Try it

From the entrance `(1,13)`, turn east and move four tiles to `(5,13)`, then
face north. The first-person view and map show an ordinary wall. The side
panel mentions scrape marks and offers `[Enter] Search wall`.

Press Enter to find the concealed catch and open the passage permanently.
The map now shows a teal D. Walk north through `(5,12)` to `(5,11)`.
Searching from `(5,11)` while facing south also works.

Discovery is guaranteed, available to every party, and costs no resource.
It grants no gold and consumes no class-skill attempt. Repeated interactions
leave the door open. Searching takes priority over a skill object underfoot.
The clue is only shown when directly facing the undiscovered door. Merely
walking into the wall does not reveal it, and discovery is blocked in combat.

## Persistence and data

The existing namespaced `interaction_states` dictionary stores `open: true`.
Discovery survives re-entry, new expeditions, and save/load. A save made while
standing on the passage restores the open state before validating the location.
Older saves without interaction state leave it hidden.

Create another secret passage with an interaction on a wall tile, a unique
`id`, `type: "secret_door"`, and `name`. Optional `clue` and
`discovery_message` customize feedback. Hidden doors are excluded from normal
interaction targets and map markers until opened.

This first pass has a visible nearby clue and manual guaranteed search.
Automatic detection, class bonuses, random search rolls, and hidden treasure
are reserved for later design.

## Validation

All 29 Godot test suites and headless startup pass. New coverage includes
hidden targeting, wall collision, directional search from both sides, combat
restrictions, repeat interactions, unchanged map data, persistent discovery,
saving on the passage, and older-save compatibility.
