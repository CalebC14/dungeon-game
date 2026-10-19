# Hidden treasure — Warehouse first pass

A hidden coin pouch beneath a loose floorboard at `(6,11)` awards 25 party
gold once. There is no map marker, skill roll, class requirement, or resource
cost. The cache does not block movement.

## Try it

Use the secret passage from `(5,13)` north through `(5,12)` to `(5,11)`.
Face east. The side panel mentions a loose floorboard and offers Enter to
search. Press Enter to discover the pouch and collect 25 gold. Searching while
standing on `(6,11)` also works.

Repeat searches report an empty hiding place and give no further reward.
Collection persists through leaving, new expeditions, and save/load. Loading
an older save without interaction state treats the cache as uncollected.
Reloading a save from before collection restores its earlier gold and cache
state, as expected.

## Data and scope

Add a floor interaction with a unique `id`, `type: "hidden_treasure"`, `name`,
`clue`, and `reward_gold`. Search checks directly ahead, then underfoot.
Facing a secret wall takes priority over searching a cache underfoot.

The resolver marks the cache collected and returns its gold reward. The game
controller adds it to shared party gold. The existing boolean `collected` save
flag is reused. Negative configured rewards are clamped to zero.

This pass deliberately uses guaranteed clue-based searching and gold only.
Item loot, random tables, detection bonuses, and trapped treasure are left for
later design.

## Validation

All 30 Godot test suites and headless startup pass. New checks cover hidden
presentation, clues, movement, directional and underfoot searching, combat
restriction, actual party-gold payout, repeated searches, saved collection,
dungeon re-entry, and older-save compatibility.
