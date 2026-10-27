# Dungeon Game — Class Design Compendium

**Source of truth:** The user-supplied `dungeon_game_class_compendium.zip`, explicitly designated authoritative by the project owner on 2026-10-26. Its locked and provisional design statuses are preserved. Implementation observations never override these designs.

## Verified from recorded design decisions

| Specialization | Design | File |
|---|---|---|
| Warrior Tank | Locked L9–60 | [warrior_tank.md](warrior_tank.md) |
| Warrior DPS | Locked L9–60 | [warrior_dps.md](warrior_dps.md) |
| Paladin Tank | Locked L9–60 | [paladin_tank.md](paladin_tank.md) |
| Paladin Healer | Locked L9–50; L60 provisional | [paladin_healer.md](paladin_healer.md) |
| Berserker Tank | Locked L9–60 | [berserker_tank.md](berserker_tank.md) |
| Berserker DPS | Locked L9–60 | [berserker_dps.md](berserker_dps.md) |
| Hunter DPS | Locked L9–60 | [hunter_dps.md](hunter_dps.md) |
| Hunter Support | Locked L9–60 | [hunter_support.md](hunter_support.md) |
| Druid Tank | Locked L9–60 | [druid_tank.md](druid_tank.md) |
| Conjurer Tank | Locked L9–60 | [conjurer_tank.md](conjurer_tank.md) |
| Other specializations | Partial framework only | [other_specializations.md](other_specializations.md) |

## Shared design rules and cautions
- Level cap approximately 60; specialization milestone levels 9, 10, 20, 30, 40, 50, 60.
- Combat is turn-based. Each enemy maintains a separate threat table; normally targets highest-threat valid living character, with boss-specific exceptions. Tank specialization baseline threat generally 2×.
- Some ability interactions and global CON/WIS/INT modifier formulas remain unresolved; these are marked in the individual files.
- **Design lock is not code implementation.** Do not infer these abilities are already implemented or tested in Godot. Previous tests of some tank phases do not prove complete implementation of this compendium.
- Never overwrite a locked ability with an earlier superseded proposal. In particular: Hunter DPS L9 is Beast Bond (not Precision), Hunter DPS L40 upgrades pet damage (not wounded-enemy crit), Hunter Support L50 is Bear Trap (not Explosive Trap), L60 is Pack Ambush (not Hunter's Ambush).
- This package does not claim to reproduce all earlier specialization designs not recoverable from current conversation records.

## Implementation and provenance

- [Implementation differences and coverage](implementation-differences.md) tracks observed code separately from locked designs.
- [Current implementation reference](implementation/current-behavior.md) records existing combat behavior; it is not a design specification.
- [Source provenance](SOURCES.md) records the supplied package and verification hashes.

All 11 non-index Markdown files from the supplied ZIP are preserved byte-for-byte. This index adds maintenance and implementation links. Paladin Healer L60 remains provisional; all source-marked TBDs remain unresolved. The former recovery-only entries are superseded by the supplied designs.

## Persistent access

Canonical repository location: [CalebC14/dungeon-game — docs/classes](https://github.com/CalebC14/dungeon-game/tree/main/docs/classes). Other Dungeon Game conversations with GitHub access should read this index, the relevant specialization file, and the separate implementation differences. Repository persistence does not imply automatic upload to ChatGPT Project Sources.
