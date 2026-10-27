# Implementation differences and coverage

The ZIP-derived specialization files are authoritative designs. This document records code gaps; none changes a locked design. Inspection date: 2026-10-26. Local code: `7093dd73527df7a88e55b1f80c1c6746a7bdd1fc`; public baseline: `c3f9e092563b098537f2e366e116944b33a89634`. See [provenance](SOURCES.md) and [current behavior](implementation/current-behavior.md). Status is based on source inspection, not a new runtime conformance test.

## Specialization coverage

| Authoritative design | Observed implementation status |
| --- | --- |
| [Warrior Tank](warrior_tank.md) | Partial; functions/menu exist at L9–60, with differences below |
| [Paladin Tank](paladin_tank.md) | Partial; functions/menu exist at L9–60, with differences below |
| [Berserker Tank](berserker_tank.md) | Partial; functions/menu exist at L9–60, with differences below |
| [Warrior DPS](warrior_dps.md) | No specialization selection or milestone kit found; base Power Attack is not this DPS kit |
| [Paladin Healer](paladin_healer.md) | No specialization selection or milestone kit found; L60 design is provisional |
| [Berserker DPS](berserker_dps.md) | No specialization selection or Fury kit found; base Rage is not Blood Frenzy |
| [Hunter DPS](hunter_dps.md) | No specialization selection, Beast Bond or milestone kit found; base Aimed Shot is not this kit |
| [Hunter Support](hunter_support.md) | No specialization selection, traps or companion kit found |
| [Druid Tank](druid_tank.md) | No specialization selection, Bear Form or Tank kit found; base Regrowth is not this kit |
| [Conjurer Tank](conjurer_tank.md) | No specialization selection, Golem entity or Tank kit found; Conjure Flame is immediate damage |
| [Other specializations](other_specializations.md) | Source preserves pairings/partial names only; do not infer complete kits or implementation |

Training currently offers Tank to Warrior, Paladin and Berserker at level >=9. The authoritative package confirms L9 specialization milestones and L10 first active abilities, so the old recovery edition's concern about a presumed universal L10 entry is superseded. No complete code-conformance claim is made for any path.

## Confirmed Tank implementation gaps

| Mechanic | Authoritative design | Observed code / required reconciliation |
| --- | --- | --- |
| All three Tank Taunts | Force target for 2 rounds; threat at least 110% highest; 5 SP / CD4 | Functions set threat to `max(own,highest*1.10+1)` but apply no forced-target effect or 2-round duration. Opportunistic behavior can select another target. A forced-target effect helper exists but is unused by these Taunts. |
| Warrior Defender's Presence | +10 percentage points shield block | Code returns fixed 10% with shield, without a separate baseline block calculation. Confirm additive integration when a baseline block system exists. |
| Warrior Riposte | Successful melee block | Hook runs in enemy attack block path without an explicit melee-only condition. Scope needs enforcement as enemy attack types expand. |
| Warrior Disarm | Weapon-wielding enemy only; extra threat equivalent to one normal attack x2 | Function checks reachability but not enemy weapon eligibility and adds no activation threat. Reduction, duration, SP and cooldown match numerically. |
| Warrior Shield Wall | Threat equivalent to two normal attacks x2; excludes other active percentage defensive cooldown stacking | Function adds reduction but no activation threat; generic effect reduction adds with other effects up to 95%. |
| Warrior Unbreakable Guardian | One selected ally; single-target only; excludes AoE | Function ignores selected ally and marks every other conscious ally. Current enemy path has no explicit AoE exclusion contract. Generic interception's 30% reduction and 1.5x attacker-local extra threat are present. |
| Paladin Valiant Protector | Shield required | No shield check in passive function. 20% proc / 25% reduction are present. |
| Paladin Thorns of Retribution | 20% pre-mitigation incoming damage; direct hits only; Holy immunity; no retaliation chaining | Code receives final mitigated damage and directly subtracts HP without a Holy-immunity check. Current call is after a normal enemy hit; no general direct-hit/Holy/anti-chain event contract is established. Code function is named `paladin_thorns_retribution`. |
| Paladin Divine Bulwark | Does not stack with other percentage defensive cooldowns | Generic damage-reduction effects add together. Optional `wis_mod` defaults to 0; no WIS stat/modifier progression supplies it. Design's WIS modifier formula is still TBD; do not invent one. |
| Paladin Chivalrous Intervention | Attackers stunned 1 round; bosses' current attack interrupted | Nonboss code applies stun duration 2, subject to generic resistance. Boss flag skips its next action after the intercepted hit has already dealt damage; it does not interrupt the current attack. Redirect/mark duration 1 and 50% extra mitigation are present. |
| Berserker Unyielding Fury | Always 10% DR, rising to 20% below 50% HP; 2x threat | Code grants 2x threat and +5 percentage points avoidance; specified HP-dependent DR is absent. Avoidance is not a replacement design. |
| Berserker Brutal Challenge | Gain stack on taking direct damage | Stack hook runs after successful ordinary physical attacks; damage-taken path does not grant it. +5%, cap 3 and duration 3 are present. |
| Boss exceptions | Design specifies which bosses receive reduced debuffs/control substitutions | Disarm checks tags, while Howl and Chivalrous check boolean `boss`/`is_boss`. A boss represented by only one convention can receive the wrong branch. |

## Cross-cutting integration checks

- **Threat multiplier composition:** code adds a skill's nominal 2x/3x contributions and then applies presence/Untouchable multipliers. The package specifies individual threat multipliers but does not resolve every composition convention. Keep this as a shared-rule dependency rather than silently declaring current multiplication approved. Howl's one rolled attack amount x2 is reused for every enemy before passive multipliers.
- **Damage pipeline:** Shield Bashes, Riposte, Savage counter and Dance use direct `damage_enemy` calls, bypassing ordinary hit, absorption and critical processing. “Normal weapon damage” in the source is not permission to assume those bypasses are approved. Define shared accuracy/armor/rounding/crit rules where unspecified, then implement consistently.
- **Interception timing:** hit chance is rolled against the original ally before redirect. Savage is consumed before a later shield block and counters only if the guardian survives. Whether a blocked redirected attack consumes the designed “next direct attack” is not separately specified; preserve this as an integration question.
- **Effect timing:** code decrements durations/cooldowns at completed-round boundaries including the application round. Source documents say rounds but do not define all boundary semantics. No claim is made that a duration 1 must equal the current boundary-based implementation.
- **Active defense stacking:** generic code sums reduction effects; Warrior Wall, Paladin Bulwark and several supplied designs explicitly exclude other active percentage defensive cooldowns. These exclusions need implementation. Druid Ancient Guardian/Primal Roar overlap remains a design TBD, not a resolved stacking rule.
- **Targeting/direct attack types:** functions with “all enemies” currently often bypass row filtering. Shared melee AoE reach, direct versus periodic damage, Holy immunity, and attack-count systems need explicit integration to support the full package.
- **Shield Bash SP/cooldown:** code charges 0 SP and has no cooldown. Source explicitly says these values are unestablished; record them as design TBD, not a confirmed zero-cost locked skill.

## Design dependencies preserved from the ZIP

These are not defects to fix by guessing:

- Global raw-stat to CON/WIS/INT modifier formulas and normal Paladin healing power.
- Druid Ancient Guardian interaction with Primal Roar's temporary HP and active reduction.
- Hunter Support Pack Ambush +15-point crit interaction with Hunter's Insight +5; Bear Trap hit resolution and trigger classification; current attack-count integration.
- Paladin Healer L60 Seal of Triumph remains provisionally locked for balance review.
- Exact unprovided mechanics for the other specialization frameworks and Conjurer DPS milestone names.

## Validation scope

Documentation checks verify original specialization bytes, package hashes, index links and repository persistence. No game code was changed. Existing tests of the three Tank slices do not establish conformity to this package; future implementation should test the listed differences against the authoritative design documents.
