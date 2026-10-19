# Party Mechanics — Implementation Pass 1

The Guild roster owns character dictionaries with stable `character_id` values.
There is no roster size cap. Six fixed slots refer to those IDs: front left,
front center, front right, rear left, rear center, rear right. Empty slots remain
empty; combat and inventory receive a compact array of occupied characters.
The active array shares the canonical character dictionaries, so damage,
equipment, and progression survive a return to the Guild.

## Controls

- At the Guild, press P to assemble the party.
- Page Up / Page Down browse all roster pages, nine characters per page.
- Left / Right select a formation position.
- Number keys 1–9 assign a character from the visible page.
- Assigning a reserve replaces the selected occupant, returning them to reserves.
- Assigning an active character swaps their position with the selected occupant.
- Backspace returns the selected occupant to reserves without moving other slots.
- Enter leaves with 1–6 members. Escape returns to the Guild.
- An empty party is allowed while assembling, but cannot leave the Guild.
- Developer test-party replacement is available only at the Guild.

## Persistence and scope

`PartySystem.to_data()` and `restore()` provide a versioned, validated data
format. Restore rejects unknown or repeated IDs and invalid slot arrays before
changing the live party. This is serialization support, not a disk save menu:
the existing game has no general save/load system. Formation persists during
play across locations and encounters. Row combat modifiers, exploration
abilities, death timing, resurrection, and general disk saves are later work.

## Validation

With Godot 4.7.2, import the project, then run each SceneTree test with
`--headless --path <project> --script res://tests/<test>.gd`.

`test_party_roster.gd` covers reserves beyond 20, six-member limits, identity,
Guild restrictions, replacement and swaps, holes, deletion, and JSON round trips.
`test_party_guild.gd` exercises paged keyboard selection, empty-party departure,
formation removal, page limits, and rejection outside the Guild. Existing
combat tests remain unchanged.
