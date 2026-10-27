# Hunter Dps — Dungeon Game

**Status:** Design decisions recorded from project conversations; not proof of Godot implementation. All unspecified details are TBD, not invented.

## Locked milestones
- **L9 Beast Bond (passive):** Hunter DPS-specific animal companion automatically follows a successful Hunter weapon attack with physical damage equal to 25% of Hunter's normal weapon damage, to same enemy. No separate turn, SP, cooldown, crits, independent targeting, HP/death, or commands. For multi-target attacks, at most one follow-up against one successfully hit enemy per attack action. Pet appearance may vary without changing mechanics.
- **L10 Marked Target (active):** Mark one enemy for 3 rounds; Hunter and pet deal +15% damage to that enemy; only one mark at a time. 5 SP, 4-round cooldown.
- **L20 Coordinated Assault (passive):** On Hunter critical hit, companion makes an additional attack against same enemy for 50% normal Hunter weapon damage, separate from Beast Bond's regular follow-up. No SP/cooldown; pet attacks do not crit.
- **L30 Multi-Shot (active):** Up to 3 *different* enemies, 75% normal weapon damage per target, independent crit rolls. At most 1 Beast Bond follow-up per Multi-Shot action if any arrow hits; at most 1 Coordinated Assault bonus pet attack per action if any arrow crits, even if multiple crit. 10 SP, 4-round cooldown; ranged weapon required.
- **L40 Predator's Instinct (passive):** Permanently upgrades Beast Bond pet damage from 25% to 40% normal Hunter weapon damage, and Coordinated Assault from 50% to 75%. No HP condition, SP, or cooldown; existing trigger caps unchanged.
- **L50 Rapid Fire (active):** Three consecutive ranged shots for 75% normal weapon damage each; may independently target different enemies; independent crit. **Each shot counts separately:** every successful shot triggers Beast Bond pet follow-up, every critical shot triggers Coordinated Assault bonus attack; up to 3 of each if all crit. 15 SP, 6-round cooldown; ranged weapon required.
- **L60 Arrow Storm (active):** All-enemy ranged attack, 150% normal weapon damage per enemy, independent crit. At most 1 Beast Bond follow-up against a successfully hit enemy and 1 Coordinated Assault bonus attack if any arrow crits (same per-action caps as Multi-Shot, not Rapid Fire). 25 SP, 8-round cooldown; ranged weapon required.

## Interactions
Marked Target's +15% applies to both Hunter and pet attacks against marked enemy. Pet attacks themselves cannot crit or recursively trigger pet attacks. Predator's Instinct upgrades pet percentages from L40 onward. Do not confuse Multi-Shot/Arrow Storm per-action pet caps with Rapid Fire's per-shot triggers.
