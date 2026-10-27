# Berserker Tank — Dungeon Game

**Status:** Design decisions recorded from project conversations; not proof of Godot implementation. All unspecified details are TBD, not invented.

## Locked milestones
- **L9 Unyielding Fury (passive):** 2× threat; 10% damage reduction always, increasing to 20% below 50% HP.
- **L10 Lunatic Howl (active):** All-enemy threat equivalent to two normal weapon attacks per enemy, no damage; enemies deal −10% physical damage for 2 rounds (bosses −5%). 8 SP, 4-round cooldown.
- **L20 Brutal Challenge (passive):** On taking direct damage, gain +5% physical damage for 3 rounds; max 3 stacks (+15%); threat 2×.
- **L30 Taunt (active):** Force one enemy to attack Berserker 2 rounds, set threat at least 110% highest; 5 SP, 4-round cooldown.
- **L40 Savage Intervention (active):** Intercept next direct attack aimed at selected ally within 2 rounds; Berserker takes hit then counterattacks for 150% normal weapon damage, generating 3× threat. 10 SP, 5-round cooldown; melee weapon required.
- **L50 Untouchable (passive):** Each dodge grants +10% physical damage and +25% threat generated for 3 rounds; maximum 3 stacks (+30% damage, +75% threat); dodges refresh duration; bonuses on top of baseline 2× threat.
- **L60 Dance of Carnage (active):** Hit all enemies once for 125% normal weapon damage each, 3× threat each; gain +20 percentage points dodge for 3 rounds. 25 SP, 8-round cooldown; melee weapon required.
