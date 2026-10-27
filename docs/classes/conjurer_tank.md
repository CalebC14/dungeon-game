# Conjurer Tank — Dungeon Game

**Status:** Design decisions recorded from project conversations; not proof of Godot implementation. All unspecified details are TBD, not invented.

## Locked milestones — Golem
- **L9 Guardian Bond (passive):** Golem generates 2× normal damage-based threat; takes −15% incoming damage, then transfers 15% of remaining damage to Conjurer.
- **L10 Crushing Blow (active):** Golem single enemy 125% normal Golem damage, 3× threat; 20% stagger causing −15% enemy physical damage for 2 rounds. 5 Conjurer SP, 3-round cooldown.
- **L20 Mind-Body Link (passive):** Active Golem gains +5% max HP per positive Conjurer CON modifier, capped +30%; +2% damage reduction per positive INT modifier, capped +12%, multiplicative with Guardian Bond. Recalculate with stat changes. Global stat modifier formula TBD.
- **L30 Power Stomp (active):** Golem AoE 75% normal Golem damage each, 2× threat; each non-boss independently 40% chance knockdown for 1 round (loses next action); bosses instead −20% accuracy for 2 rounds. 10 Conjurer SP, 4-round cooldown.
- **L40 Fueled by Destruction (passive):** Golem killing blow grants +5% max HP and corresponding current HP, max 5 stacks (+25%) until combat ends; grants immediate extra action for normal Golem attack or available ability, subject to Conjurer SP/cooldown; extra action cannot chain another extra action.
- **L50 Destructive Charge (active):** Golem AoE 125% normal Golem damage each, 3× threat; each non-boss independently 50% chance knockdown for 1 round; bosses instead −20% accuracy for 2 rounds. 15 Conjurer SP, 6-round cooldown.
- **L60 Cataclysmic Impact (active):** Golem AoE 200% normal Golem damage each, 4× threat; guaranteed 1-round knockdown non-boss; bosses instead have next action interrupted. Golem takes −30% damage for 3 rounds. 30 Conjurer SP, 10-round cooldown. DR stacks multiplicatively with Guardian Bond and Mind-Body Link passives, not other active percentage defensive cooldowns.
