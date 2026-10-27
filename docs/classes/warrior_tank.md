# Warrior Tank — Dungeon Game

**Status:** Design decisions recorded from project conversations; not proof of Godot implementation. All unspecified details are TBD, not invented.

## Locked milestones
- **L9 Defender’s Presence (passive):** 2× normal damage-based threat; +10 percentage points shield block chance.
- **L10 Shield Bash (active):** Shield required; deals normal weapon damage; generates 3× normal damage-based threat. SP/cooldown not established in available record.
- **L20 Riposte (passive):** After successful melee block, 30% chance to counterattack for 75% normal weapon damage; 2× threat.
- **L30 Taunt (active):** Force one enemy to attack Warrior for 2 rounds; set threat to at least 110% of enemy’s highest existing threat. 5 SP, 4-round cooldown; normal targeting resumes after expiration.
- **L40 Disarm (active):** One weapon-wielding enemy suffers −30% physical damage for 3 rounds (boss −15%); 8 SP, 5-round cooldown; generates threat equivalent to one normal weapon attack ×2.
- **L50 Shield Wall (active):** Shield required; −50% all incoming damage for 2 rounds; 12 SP, 6-round cooldown; threat equivalent to two normal attacks ×2; stacks with armor, not other active percentage defensive cooldowns.
- **L60 Unbreakable Guardian (active):** Shield required; intercept all single-target attacks aimed at one selected ally for 2 rounds; intercepted damage −30%; generates additional threat equal to 150% intercepted damage against each attacker. 15 SP, 8-round cooldown; does not intercept AoE.
