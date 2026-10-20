# Imported Church Nave — playable test pass

The imported Church Nave now has a separate playable binding at
`architect_test_church_nave`. It uses the preview's exact 25 × 19 map, with
explicit test gameplay data layered over it. The original Reliquary and its
quest progression are unchanged. Generated preview files remain unmodified.

## Enter and leave

Use an active conscious party. Press F12, then N for Imported Nave Test.
At the Guild, F12 then T can load the existing test roster first. The new
shortcut refuses entry without a party capable of adventuring.

The entrance is `(12,16)`, facing north. Enter there returns to Thornwake at
any time. Move north to `(12,15)` for the one-time introduction. The lower
half (y=9–18) has no random battles so you can test interactions; traps and
fixed encounters remain active. The northern area uses small groups of
existing Skeletons. L and the exploration clock retain their current behavior;
no new dark area or resource cost is introduced.

## Test content

| Position | Behavior |
| --- | --- |
| (3,9) | Search the cracked-pew clue from adjacent floor or underfoot for 25 gold once. |
| (11,10) | Visible loose-flagstone trap; 4 HP once, disarmable with existing Rogue rules. |
| (20,9) | One-time shrine lore. |
| (20,3) | Search from an adjacent tile to open a concealed niche, then walk onto it for inscription lore. |
| (12,4) | Profaned Nave Guardian: a single existing Skeleton as an intentionally simple stand-in. |
| (12,2) | Enter to descend to the playable imported Archives after defeating the guardian. |

The guardian is not a new balanced boss. Its normal Skeleton XP/gold/loot use
the existing reward system and duplicate-victory guard. Defeat persists under
a test-only encounter ID. No Purge quest state is changed. Guardian defeat,
cache collection, trap/niche state, lore, and the current position save normally.

The trapdoor checks `requires_defeated` before travel, so walking around the
guardian cannot unlock it. Escape leaves it sealed. It now leads to the playable imported Archives. The Archives return stair
leads back here; the Nave entrance remains the exit to town. See
PLAYABLE_ARCHIVES_PASS1.md for the connected walkthrough.

## Presentation and scope

The dungeon map now scales to fit its side panel, including small labels.
The Warehouse retains its original 18-pixel tile size. Transition hints show
the entrance and stair controls when no newer message is present.
The developer menu lists the new N shortcut.

This pass does not replace existing dungeon IDs or save locations, register
all imported floors, redesign enemy stats, or add world/quest access to this
test dungeon. Future Architect exports can change coordinates, so revalidate
these bindings after regenerating the preview.

## Validation

All 41 test suites and headless startup pass. The added integration test uses
the developer shortcut, immediate exit, imported geometry, reachable guardian,
pre-victory exit gate, treasure, trap damage, niche/lore, guardian victory,
unchanged quest state, save/load, guardian-gated descent, and re-entry. Encounter and
layout validators accept the live binding. Native Godot views of the entry,
map, and developer menu were checked.
