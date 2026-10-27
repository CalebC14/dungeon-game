# Current implementation reference — not locked design

Status: observed implementation only. The ZIP-derived specialization documents in the parent directory are authoritative for design, including where this reference differs. Code snapshot: local commit `7093dd73527df7a88e55b1f80c1c6746a7bdd1fc`; Tank ability function tail also matches GitHub baseline `c3f9e092563b098537f2e366e116944b33a89634`. Source: `systems/combat.gd`, `systems/combat_effects.gd`, `game.gd`; see [provenance](../SOURCES.md) and [differences](../implementation-differences.md).

## Actions, progression and targeting

One selected action per acting character per round; descending DEX resolution with stable ties. All listed active Tank skills take the Ability action; passives and counters do not select an additional action. Combat dispatcher checks `can_act` first. Tank checks require the exact class, `specialization == "tank"`, and the listed minimum level. Training offers these three paths at level >=9. Exploration versions of the Tank skills are not implemented.

Six formation slots: three front, three rear. Normal melee cannot attack from the rear, reach can attack from the rear while respecting protected enemy rows, ranged/magic can bypass front protection. Repositioning takes an action. An unbound legacy formation defaults to front. Shield Bashes explicitly resolve melee reachability. Warrior Disarm uses equipped attack range. Taunts resolve a selected living enemy without reach checks; empty selection falls back to first living enemy; a stale explicit selection fails. Howl and Dance use all living enemies without row filtering. Redirects require a living source in the party and choose the first matching redirect effect; they do not chain.

## Damage and threat notation

`D = max(1, random_integer(1,3) + floor((attack_stat-10)/3) + weapon_damage_roll + song_bonus)` is `roll_character_damage`. Song bonus is 2 while Song of Courage is active, otherwise 0. Tank classes use STR. Ordinary attacks subtract enemy absorption (minimum 1), apply Berserker multipliers, then independently crit for x2 with chance `0.05 + LCK*0.005`. Physical hit chance is `clamp(0.65 + (attack_stat-10)*0.02 + weapon_accuracy - enemy_base_avoidance, 0.10, 0.95)`; default enemy avoidance 0.05.

Shield Bashes, Riposte, Savage counterattack and Dance directly call `damage_enemy`: no ordinary hit roll, enemy absorption subtraction, or ordinary critical roll at that call site. Preserve this implementation distinction; whether it matches the locked design is unresolved. `damage_enemy` subtracts the supplied damage (HP floor 0), adds baseline threat, and fires a damage-dealt trigger. Threat uses supplied damage rather than HP actually lost to overkill.

`add_threat(enemy, actor, A, m)` adds `A*m*max(0, 1+sum(threat_multiplier effects))*(1+Untouchable threat bonus)` to that actor's enemy-local threat, clamped to nonnegative. The Tank presence effect has value 1.0, so the ordinary multiplier is 2. Baseline damage supplies 1x threat; Bash and Berserker counters/Dance add 2x more, Riposte adds 1x more. These are 3x/2x **before** presence and Untouchable. No fixed forced-target duration is implemented by the three Taunts: they set `own_threat = max(own_threat, highest_existing_threat*1.10+1)` directly, bypassing threat multipliers.

Enemy selection filters reachable allies first, honors a reachable forced-target effect, otherwise chooses highest threat (stable first on ties). Opportunistic enemies may choose another reachable target; a threat-only Taunt is not a guaranteed forced attack.

## SP, cooldowns, durations and stacking

`use_combat_resource` fails if cost/cooldown is negative, SP is insufficient, or remaining cooldown >0. Success subtracts the exact cost and sets the cooldown. Listed skill functions validate requirements/targets before spending. Shield Bash does not call this helper: 0 SP and no cooldown in current code; final design approval is unverified.

Effects and cooldowns decrement at completed-round boundaries **including the application round**. A duration 1 effect expires at the next boundary. A cooldown set to 4 during round R reaches 0 after boundaries R through R+3; first normal reuse is R+4. Durations are boundary counts, not guaranteed full actor turns.

Effects merge by `(id, source_key)`, increment stacks up to the incoming max (default 1) and retain the greater remaining duration. Values add by kind as `value*stacks`. Thus different effect IDs can combine. Generic damage reduction is additive then clamped to 95%; result is `max(1, ceil(damage*(1-reduction))-flat_reduction)`. Control resistance is clamped to [0,1] from general plus effect-specific resistance, checked on application. Nonpersistent effects and all cooldowns clear on encounter end; HP/SP persist. Presence effects use duration 999999, but still clear on encounter end. Multiple identical presence IDs do not add stacks.

## Incoming physical attack order and interactions

1. Roll hit against original target: `clamp(enemy_accuracy - avoidance, 0.10, 0.95)`. Avoidance is `clamp(0.05+(DEX-10)*0.01+equipment_avoidance+(0.10 if Defending else 0)+(0.05 if Tank Berserker else 0)+Dance bonus,0,0.60)`; interpret the Defending term as conditional addition.
2. A miss invokes Untouchable for the original target. A hit resolves redirect, consuming Savage Intervention if selected.
3. Warrior shield block on the final defender can cancel all damage and trigger Riposte.
4. Apply enemy physical damage reduction to raw damage using ceil/minimum 1, subtract defender armor/minimum 1, halve for Defend and then Guarded (ceil/minimum 1 each), subtract 2 if Warded/minimum 1.
5. Apply generic effect mitigation, then shield-conditioned Sacred Guardian, then Valiant Protector (checks original target and party).
6. Savage interception adds no extra mitigation. Chivalrous marked interception halves remaining damage and controls attacker. Other redirects multiply remaining damage by 0.70, ceil/minimum 1, and add attacker-local threat at 1.5x (then presence/Untouchable).
7. Apply HP damage, Paladin thorns, surviving Savage counterattack, and damage-taken triggers.

Hit chance is tested against the original ally before redirect; armor/block/most mitigation use the guardian. Savage is consumed before block, so a subsequently blocked hit spends its one interception and returns before its counter. Valiant Protector can mitigate redirected damage by checking the original ally. Generic redirects have 30% additional reduction; do not attribute that reduction to Savage or Chivalrous.

## Boss convention mismatch

Warrior Disarm recognizes `"boss" in tags`. Berserker Howl and Paladin Chivalrous Intervention recognize boolean `boss` or `is_boss`, not tags. This is observed inconsistent implementation behavior; apply the source designs when implementing corrections. No other special boss exceptions are present in the recovered Tank functions.
