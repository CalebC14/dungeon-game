# Druid Tank — Dungeon Game

**Status:** Design decisions recorded from project conversations; not proof of Godot implementation. All unspecified details are TBD, not invented.

## Locked milestones — Bear Form
- **L9 Guardian of the Wild (passive):** +15% max HP in Bear Form; 2× threat.
- **L10 Crushing Paw (active):** Single enemy 125% normal Bear attack damage, 3× threat; 20% stagger chance (boss 10%) causing −15% enemy physical damage for 2 rounds. 5 SP, 3-round cooldown.
- **L20 Growl (active):** Bear Form single-target Taunt for 2 rounds; threat at least 110% highest; 5 SP, 4-round cooldown.
- **L30 Swipe (active):** All enemies 75% normal Bear damage each, 2× threat; independent 20% bleed chance per target, bleed deals 10% normal Bear damage per round for 3 rounds and generates threat. 10 SP, 4-round cooldown.
- **L40 Thick Hide (passive):** Bear Form −15% physical damage taken; killing blow (including Swipe bleed) heals 10% max HP if not full; if already at full HP, instead gain +1% temporary maximum and current HP per kill, maximum 10 stacks (+10%) lasting until combat ends.
- **L50 Primal Roar (active):** Bear Form +20% max HP for 3 rounds and immediately add corresponding current HP; −20% all damage for 3 rounds; AoE threat equivalent to two Bear attacks. 20 SP, 8-round cooldown. HP bonus stacks with Thick Hide; DR does not stack with other active percentage defense cooldowns; current HP capped when buff expires.
- **L60 Ancient Guardian (active):** Bear Form transformation for 3 rounds: +30% max HP, +25% physical damage, −25% all damage, 3× normal threat on damaging attacks. 30 SP, 10-round cooldown. Visual: massive bark-armored glowing bear.

## Open detail
Exact interaction of Ancient Guardian with Primal Roar's temporary HP and active damage reduction needs clarification; do not assume full stacking.
