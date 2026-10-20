# Dungeon Architect JSON import — first pass

The supplied `broken_reliquary_project.json` identifies project schema 0.3.0
and floor schema 0.1.0. The importer supports those exact versions for now.
It produces validated, separate Godot preview data; it does not replace the
existing Broken Reliquary or register new playable dungeons.

## Sample result

All five exported floors are 25 × 19 and pass layout validation:

| Export floor | Preview start | Stair links |
| --- | --- | --- |
| Church Nave | (12,16), explicit entrance | Archives |
| Forgotten Archives | (12,16), return stair | Church / Upper Catacombs |
| Upper Catacombs | (12,16), return stair | Archives / Lower Catacombs |
| Lower Catacombs | (12,16), return stair | Upper Catacombs / Chapel |
| Chapel of the Black Warlock | (12,16), return stair | Lower Catacombs |

The four project connections generate eight directed transitions. Floor tile
metadata is cross-checked against these links. The sample has no geometry or
transition errors. Five explicit warnings explain that gameplay markers are
annotations, one per floor. These warnings are not discarded.

Generated files live in `import_previews/broken_reliquary/`. They have IDs
prefixed with `architect_` and are not added to `DungeonData.DUNGEONS`.
Each file is a loadable Godot script with a `DATA` dictionary.

## Convert and validate

Replace `Godot` with the installed executable:

```
Godot --headless --path /Users/caleb/dungeon-game --script res://tools/import_dungeon_architect.gd -- /Users/caleb/Downloads/broken_reliquary_project.json
```

With no output directory this is a dry run. To write scripts, append a new,
nonexistent output directory. Existing files/directories are never overwritten.
Validation happens before creating output. Invalid input produces errors,
returns a failure exit code, and writes nothing. Filesystem write failures are
reported; a new directory may contain partial output if an I/O failure occurs.

## Conversion policy

- The full tile grid must have unique integral coordinates and known types.
  Width/height are limited to 1–256. JSON integral numeric values are supported.
- Walls become `#`. Floors, stairs, entrances, and annotated gameplay positions
  become `.` for preview geometry. No doors are silently made into playable
  locked mechanisms. A secret marker may mean a niche or boss-gated exit, so
  it is not automatically converted into the Warehouse secret-door mechanic.
- Marker dictionaries and floor notes are preserved as inert metadata. Text is
  data; descriptions are not interpreted as instructions or executed.
- Explicit entrances set starts. Other floors require one return stair to the
  immediately preceding numbered floor. Facing defaults to north.
- Top-level project connections are authoritative; stair markers must agree.
  Duplicate IDs/endpoints, orphan stairs, missing floors and contradictory
  destinations fail. Two-way links generate both directions; one-way links
  generate the forward transition. Both endpoints must be stairs in this pass.
  Per-floor duplicate connection summaries are not used as a second authority.
- All converted floors run through `DungeonLayoutValidation` as one temporary
  catalog. Any layout error rejects the entire conversion.

## Still needed before playable integration

Many markers have no enemy composition, treasure reward, door key, trap damage,
or machine-readable boss prerequisite. The guardian text mentions unlocking a
trapdoor; the final secret mentions an exit after the boss. Those descriptions
are retained but do not create behavior. Dungeon encounter tables, world entry,
town/zone metadata, quest hooks, and boss gating need explicit mapping before
these previews replace any live content. Several export floor IDs and map
sizes differ from the current game, so existing save locations must be handled
when a future replacement is planned.

## Validation

All 40 test suites and headless startup pass. The sample converts, and all five
generated scripts load in Godot. CLI checks verify refusal to overwrite output
and that invalid input creates no output. Fixtures cover schema versions,
JSON numbers, geometry, reciprocal links, preserved markers, malformed grids,
unknown tiles, conflicting/orphan links and layout rejection. Source input and
existing gameplay content remain unchanged.

## Playable test binding

The Church Nave preview now has a separate playable test binding at
`architect_test_church_nave`. F12 → N enters it with an active party. This
binding adds explicit first-pass content without modifying or registering the
generated preview itself. The Archives also has a connected playable test binding; see
PLAYABLE_ARCHIVES_PASS1.md. The Upper Catacombs also has a connected test binding; see
PLAYABLE_UPPER_CATACOMBS_PASS1.md. The Lower Catacombs and Chapel remain previews.
See PLAYABLE_CHURCH_NAVE_PASS1.md for controls, test values, and limitations.
