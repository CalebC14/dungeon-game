# Paladin Healer — Dungeon Game

**Status:** Design decisions recorded from project conversations; not proof of Godot implementation. All unspecified details are TBD, not invented.

## Locked milestones
- **L9 Divine Grace (passive):** +15% all healing performed. Whenever Paladin heals an ally, recipient gains 5% damage reduction for 2 rounds; repeated heals refresh, not stack; does not stack with other percentage defensive cooldowns.
- **L10 Lay on Hands (active):** Heal one living party member, including self, for 150% of normal Paladin healing power, enhanced by Divine Grace; applies Divine Grace protection. 5 SP, 2-round cooldown.
- **L20 Beacon of Restoration (passive):** Once per successful melee attack action (even if multi-target), heal living ally with lowest HP percentage (including self) for 20% of actual melee damage dealt, enhanced by Divine Grace +15%. A designated living Beacon (including self) additionally receives 30% of the already Divine-Grace-enhanced primary heal; do not apply +15% again to transfer. Both healed recipients gain Divine Grace's 5% damage reduction for 2 rounds. If same character is both targets, both portions heal that character. Beacon may be assigned freely outside combat; changing in combat costs one action, at most once per round; assignment ends when combat ends or Beacon dies. Misses do not heal; healing capped at max HP. No SP/cooldown.
- **L30 Consecrated Strike (active):** Single-target melee attack, 125% normal weapon damage converted to Holy; heals lowest-HP%-living party member for 50% actual damage dealt, enhanced by Divine Grace; Beacon receives 30% of enhanced primary heal; both recipients receive Divine Grace protection. Replaces, rather than stacks with, Beacon of Restoration's normal 20% trigger for this attack. 10 SP, 4-round cooldown; melee weapon required.
- **L40 Inspiring Victory (passive):** Paladin killing blow heals all living party members for 10% of each recipient's max HP, enhanced by Divine Grace (+15%); healed members receive Divine Grace protection. No SP/cooldown.
- **L50 Seal of Renewal (passive):** Each successful melee attack heals every living party member by recipient Max HP × (0.05 + 0.005 × C) × 1.15, where C = Paladin's Constitution modifier clamped to 0..10. At C=6, heals 9.2% max HP per hit; at C=10, 11.5%. Applies/refreshes Divine Grace protection; no SP/cooldown.
- **L60 Seal of Triumph (active; provisionally locked):** Three consecutive independently targetable melee attacks for 100% normal weapon damage each; independent crit rolls; each successful attack triggers Beacon of Restoration and Seal of Renewal; killing blows can also trigger Inspiring Victory. 30 SP, 10-round cooldown; melee weapon required.

## Locked interaction rules
- Normal melee hits trigger both Beacon of Restoration and Seal of Renewal.
- Consecrated Strike triggers Seal of Renewal but uses its own 50%-damage Beacon-style healing instead of Beacon's 20% trigger.
- Inspiring Victory triggers independently on killing blows.
- Seal of Triumph's three strikes each independently trigger the two passives and possible killing-blow healing.
- AoE attack actions trigger Seal of Renewal at most once per action, rather than once per enemy hit; Seal of Triumph explicitly comprises three separate attacks.
- Misses do not trigger healing; healing cannot exceed max HP; healing effects do not recursively trigger one another.
- Divine Grace's protection refreshes rather than stacking.

## Open implementation dependency
Shared raw-CON-to-CON-modifier formula is not yet defined. Seal of Triumph is provisional for future balance review.
