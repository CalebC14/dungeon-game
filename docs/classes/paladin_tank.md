# Paladin Tank — Dungeon Game

**Status:** Design decisions recorded from project conversations; not proof of Godot implementation. All unspecified details are TBD, not invented.

## Locked milestones
- **L9 Sacred Guardian (passive):** 2× threat; 10% damage reduction while shield equipped.
- **L10 Shield Bash (active):** Same mechanics as Warrior Tank Shield Bash: shield required, normal weapon damage, 3× normal damage-based threat. SP/cooldown not established in available record.
- **L20 Valiant Protector (passive):** Shield required; 20% chance when an ally takes direct damage to reduce that hit by 25%.
- **L30 Taunt (active):** Force one enemy to attack Paladin for 2 rounds; threat at least 110% of current highest. 5 SP, 4-round cooldown.
- **L40 Thorns of Retribution (passive):** When directly hit and damaged, retaliate with Holy damage equal to 20% of pre-mitigation incoming damage; 2× threat. No shield required. Damage-over-time does not trigger; no retaliation chaining; Holy immunity applies.
- **L50 Divine Bulwark (active):** Shield required; party-wide −30% all incoming damage for 1 + WIS modifier rounds (minimum 1, maximum 5); 20 SP, 8-round cooldown; does not stack with other percentage defensive cooldowns. WIS modifier formula TBD.
- **L60 Chivalrous Intervention (active):** Shield required; intercept all direct attacks aimed at party for 1 round, reduce intercepted damage by 50%; attackers stunned 1 round; bosses instead have current attack interrupted (not fully stunned). 30 SP, 10-round cooldown.
