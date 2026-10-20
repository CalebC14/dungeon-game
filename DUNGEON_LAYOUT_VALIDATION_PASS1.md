# Dungeon layout validation — first pass

This developer check reads dungeon data without changing maps, game state, or
saved games. It complements encounter/reward validation and Warehouse pacing
checks; it is independent of the layout editor used to author a dungeon.

## Run

Use the installed Godot executable with:

```
Godot --headless --path /Users/caleb/dungeon-game --script res://tools/validate_dungeon_layouts.gd
```

The report identifies the dungeon, data section, and position for each issue.
Exit code 1 means errors were found; warnings alone exit successfully.

## Checks

- Nonempty rectangular string maps containing only floor `.` and wall `#`.
- Initially walkable starts and valid start facing (0–3).
- In-bounds encounter, event, transition, skill-object, and interaction positions.
- Floor placement and reachability for encounters, events, transitions, and
  current-tile skill objects. Interactions may be operated from adjacent floor.
- Known dungeon transition destinations, valid initial landing tiles, and valid
  facing; omitted landing/facing use the destination's defaults. City/wilderness
  exits are recognized but their destination content is outside this check.

Breadth-first scans compare all barriers closed with all barriers open. Content
that needs an opened barrier gets a warning. Content inaccessible even with
barriers open gets an error. Isolated floor tiles without required content get
a warning, because they may be intentional decorative rooms.

The open-barrier scan is optimistic: it does not prove that keys, switches,
secret searches, or a puzzle sequence can actually open every barrier. This
pass does not simulate combat, validate room quality, require reciprocal exits,
or enforce connected decorative space. Mechanism dependency validation and
pacing metrics can be added later.

## Current content report

13 dungeons checked: **0 errors, 2 warnings**.

- Broken Reliquary Church: 21 disconnected floor tiles.
- Broken Reliquary Archives: 5 disconnected floor tiles.

No required content positions were reported stranded. These warnings are for
review, not proof of a broken dungeon. No dungeon layouts were modified.

## Dungeon Architect

Dungeon Architect is the user's design tool. The supplied JSON confirms project
schema 0.3.0 and floor schema 0.1.0. A separate preview adapter now converts
that format into Godot dungeon dictionaries and invokes this validator before
writing output. See DUNGEON_ARCHITECT_IMPORT_PASS1.md. The validator itself
remains reusable for both hand-authored and imported layouts.

## Validation

All 39 test suites and headless startup pass. New fixtures cover malformed
maps, invalid starts/facing, invalid content positions, transition destinations
and defaults, barrier-dependent routes, isolated content, and adjacent wall
interactions. All current dungeons are also checked for errors in the suite.
Warnings remain visible in the dedicated report instead of being suppressed.
