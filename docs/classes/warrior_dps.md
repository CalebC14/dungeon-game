# Warrior Dps — Dungeon Game

**Status:** Design decisions recorded from project conversations; not proof of Godot implementation. All unspecified details are TBD, not invented.

## Locked milestones
- **L9 Weapon Mastery (passive):** +10% physical weapon damage on normal attacks and weapon-based abilities; requires one- or two-handed melee weapon.
- **L10 Power Attack (active):** Single-target 150% normal weapon damage, +10 percentage points critical chance; 5 SP, 3-round cooldown, melee weapon required.
- **L20 Riposte (passive):** On successfully dodging a melee attack, 40% chance immediate counterattack for 100% normal weapon damage, normal crit; melee weapon required. Distinct from Warrior Tank's block-based Riposte.
- **L30 Cleave (active):** Hit all enemies for 75% normal weapon damage each; independent critical rolls; Weapon Mastery applies; 10 SP, 4-round cooldown; melee weapon required.
- **L40 Relentless Assault (passive):** Landing a melee critical hit grants +10% physical damage for 3 rounds; maximum 3 stacks (+30%); further critical hits refresh duration. No SP/cooldown. This supersedes the earlier unapproved on-any-hit proposal.
- **L50 Combat Surge (active):** Immediately gain one extra action usable for a normal attack or available ability (normal SP/cooldown rules apply); gain +20% physical damage and +10 percentage points crit for 2 rounds. 15 SP, 7-round cooldown; melee weapon required. Extra action cannot chain Combat Surge.
- **L60 Slash & Bash (active):** Slash all enemies for 125% normal weapon damage each, then Bash one selected enemy for 175% normal weapon damage ignoring 25% of target armor. Independent crit per hit; selected enemy may receive both hits. 25 SP, 8-round cooldown; melee weapon required.
