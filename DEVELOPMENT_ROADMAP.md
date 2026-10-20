# Dungeon Game — development roadmap

Code audit: October 19, 2026. Current baseline: d795e7b. This records observed
implementation and proposed next work; proposals do not lock new design rules.

## Six workstreams

| Area | Current implementation | Remaining work |
| --- | --- | --- |
| 1. Party Mechanics | 1–6 active members, Guild reserves and roster swapping, persistent six-slot formation, combat repositioning, shared bag and individual equipment, incapacitation and resurrection | Confirm remaining hybrid-inventory requirements; balance and broader playtesting. Combat consumable access is not implemented by the current out-of-combat inventory UI. |
| 2. Combat Foundations | Queued party actions; Dexterity order; attacks, defense, class abilities, positioning, accuracy, armor, threat, taunts, effects and cooldowns | Define initiative ties, effect timing, shared magic/resistance policy, enemy behavior profiles, and combat item policy. Audit edge cases before balance changes. |
| 3. Encounter Framework | Weighted per-dungeon/floor tables; fixed encounters; mixed groups; encounter intros; persistent defeated encounters | Validate data and reachability; audit scripted encounter lifecycle, escape/retry behavior, and encounter pacing. |
| 4. Exploration & Interactions | Warehouse key/door/lever/shortcut, real lockpicking, floor trap/disarm, secret door, hidden gold, Sun/Moon puzzle, darkness/lantern; class skill menus and test objects | Exploration time; additional interaction types; actual spell/song design; class-skill integration beyond test objects; move prototypes into intentional dungeon layouts. |
| 5. Persistence & Rewards | Staged save restoration, safe variant decoding, temporary-file writes, persistent interactions/boss flags, party gold, combat XP and quest progression | Audit all victory/escape/defeat paths and reward-once behavior; decide XP eligibility and split rules; balance economy and progression. |
| 6. Dungeon Content & Tools | Hand-authored map/data files and a Warehouse test area | Define layout validation and pacing criteria; verify Dungeon Architect integration requirements. No integration was identified in the inspected gameplay files. |

Warehouse mechanics are first-pass prototypes, not completed content or balance.
Unlimited free lantern light and the guaranteed search mechanics remain testing
rules. No new design decisions are implied by this audit.

## Combat audit findings

Sources: systems/combat.gd, systems/combat_effects.gd, game.gd and combat tests.

- Party actions are queued before resolution. Both sides resolve in descending
  Dexterity order. The comparator has no explicit equal-Dexterity tie policy.
- Physical hit chance uses a 65% baseline plus class attack-stat and weapon
  accuracy, minus avoidance, clamped to 10–95%. Physical damage includes weapon
  damage/stat bonuses, armor absorption, and critical hits. This is existing
  behavior, not a newly approved balance formula.
- Formation filters reachable targets before threat selection. Reachable forced
  targets take priority; otherwise enemies select the highest threat. Equal
  threat currently favors the first eligible member encountered.
- Enemy action resolution currently performs a basic physical attack with shared
  defensive processing. Enemy definitions contain tags and statistics, but the
  inspected action path does not select distinct behavior profiles or spells.
- Effects support duration, stacking, resistance, mitigation, redirection, and
  cooldowns. Persistent conditions can survive encounter cleanup. Persistence
  alone does not establish poison damage or other exploration-time behavior.
- Effects and cooldowns tick at completed-round boundaries. The effect file's
  comment that a fresh effect survives its first tick needs reconciliation with
  the actual duration decrement. Decide intended timing before changing it.
- Falling characters retain the locked three-complete-round death countdown.
  Existing health tests cover this; exploration must continue to pause it.

## Recommended implementation order

1. **Combat audit follow-through.** Document explicit round and effect timing,
   tie behavior, and action validation; add focused regression tests where the
   agreed behavior lacks coverage. Preserve locked death/formation rules.
2. **Enemy behavior first pass.** Add a data-selected profile with existing
   threat behavior as the default. Proposed initial variation: opportunistic
   rats. Define chance, eligible targets, and taunt precedence before coding.
   Keep it limited to targeting; enemy spells and boss scripts can follow.
3. **Encounter and reward audit.** Validate floor-table references, group counts,
   weights, fixed encounter IDs, and completion paths. Check that repeated
   interaction/re-entry cannot duplicate permanent rewards.
4. **Exploration time design.** Decide which actions advance time before adding
   fuel, condition ticks, or timed encounters. Do not advance the death countdown
   outside combat. Keep the free lantern prototype until its replacement is set.
5. **Warehouse content pass and tools.** Arrange a short playable route rather
   than adding more isolated tests. Validate transitions, optional routes,
   mechanism reachability and save locations, then connect generation tools.

## Decisions to settle before dependent code

- Equal initiative: stable side/order, randomized tie, or secondary stat?
- Effects/cooldowns: does the application round count toward duration?
- Enemy profiles: target selection only initially; when can they override threat,
  and must every profile obey reachable taunts?
- XP: current implementation splits integer XP among members above 0 HP. Confirm
  incapacitated/dead eligibility and remainder handling before changing it.
- Exploration time: movement, turning, searching, menus, failed attempts?
- Dungeon Architect: intended tool/version, generated format, and editor workflow.

## Validation

All 32 existing test suites passed for this audit in an isolated copy.
These tests establish regression coverage, not full balance or content approval.
This roadmap does not modify gameplay.

## Follow-through: combat timing and action submission

The first combat follow-through establishes stable equal-Dexterity ordering
(party selection order, then enemy encounter order), rejects duplicate and
ineligible action submissions, and documents the existing effect/cooldown
boundary timing. See COMBAT_FOUNDATIONS_PASS1.md. These supersede the open tie
and effect-timing audit items above. Enemy profiles, shared magic policy,
combat items, and the remaining workstreams are still pending. The expanded
33-suite regression baseline passes.

## Follow-through: enemy behavior first pass

Giant Rats now use a data-selected opportunistic profile with a 30% test chance
to choose a different reachable living member. Reachable taunts override it;
formation/range rules remain enforced. Other enemies, including the Rat
Broodmother, retain threat targeting. See ENEMY_BEHAVIOR_PASS1.md. This
supersedes the proposal for an initial rat profile above. Broader enemy action
AI and balance remain pending. The regression baseline now has 34 passing
suites. Next recommended work: encounter-data and reward lifecycle validation.

## Follow-through: encounter and reward validation

The first developer validator checks current dungeon/wilderness/legacy encounter
tables, fixed encounters, enemy rewards, and dungeon treasure references and
gold fields. Current data passes. An encounter-local victory guard prevents
repeat XP/gold/loot payouts and rejects empty, unfinished, or mutual-defeat
victories. See ENCOUNTER_REWARD_VALIDATION_PASS1.md. The baseline now has 36
passing suites. Quest payout auditing, loot tables, reachability, and encounter
pacing remain separate work; exploration-time design is still pending.

## Follow-through: exploration clock first pass

The Warehouse opts into a cumulative saved exploration-step counter. Successful
tile movement costs one step; other actions are free for testing. It introduces
no fuel, condition ticks, extra encounter rolls, or exploration death countdown.
See EXPLORATION_TIME_PASS1.md. The baseline now has 37 passing suites. Time
units, broader action costs, and timed consequences remain design work.

## Follow-through: Warehouse layout and pacing first pass

A connector at (3,12) creates a small entrance loop. Data-defined quiet areas
cover the southern test aisles and door/lever area, with one-time entrance and
patrol warnings. Fixed encounters and traps remain active. Route tests confirm
boss and test-object access without optional mechanisms. See
WAREHOUSE_LAYOUT_PASS1.md. The baseline now has 38 passing suites. Broader
dungeon pacing and Dungeon Architect integration remain pending.

## Follow-through: dungeon layout validation first pass

A read-only layout validator checks map structure, starts, content access, and
transition landings with closed/open barrier floods. The 13 current dungeons
have no errors and two isolated-floor warnings (Church: 21 tiles; Archives:
5). No layouts were automatically repaired. See DUNGEON_LAYOUT_VALIDATION_PASS1.md.
The baseline now has 39 passing suites. Dungeon Architect is the user's design
tool; its version/export workflow must be identified before building an adapter.
Mechanism dependency checks and full pacing analysis remain pending.

## Follow-through: Dungeon Architect JSON preview adapter

The supplied Broken Reliquary export confirms project schema 0.3.0 and floor
schema 0.1.0. A first-pass adapter converts its five floors and stair links,
validates them as a separate catalog, and preserves gameplay markers as inert
annotations. All five preview floors pass; existing live dungeons are unchanged.
See DUNGEON_ARCHITECT_IMPORT_PASS1.md. The baseline now has 40 passing suites.
Enemy/reward bindings, boss gating, world registration, and save migration must
be resolved before replacing playable content.

## Follow-through: playable imported Church Nave

A separate test binding now makes the imported Church Nave playable through
F12 → N, using existing Skeletons, treasure/trap/secret/lore systems, safe
entrance return, and a guardian-gated completion exit to town. The imported
Archives and existing Reliquary remain unchanged. See PLAYABLE_CHURCH_NAVE_PASS1.md.
The baseline now has 41 passing suites. Balanced boss design, progression
hooks, and playable bindings for subsequent floors remain pending.

## Follow-through: playable connected imported Archives

The imported Archives now has a separate playable binding linked both ways to
the guardian-gated Nave trapdoor. Six keyless doors, two coin caches, lore, a
Skeleton guardian, and an unfinished-stairs notice provide first-pass content.
The Nave entrance still exits to town; later preview floors remain unavailable.
See PLAYABLE_ARCHIVES_PASS1.md. All 42 test suites pass. Original Reliquary
content and quests are unchanged.

## Follow-through: playable connected imported Upper Catacombs

The Upper Catacombs now connects both ways to the Archives, with three keyless
doors, one coin cache, two lore markers, small Skeleton encounters, and a calm
arrival area. No new boss gate is added; Lower Catacombs stairs remain inactive.
The return chain reaches the Nave's town exit. See
PLAYABLE_UPPER_CATACOMBS_PASS1.md. All 43 test suites pass; original Reliquary
content and generated previews remain unchanged.

## Follow-through: playable connected imported Lower Catacombs

The Lower Catacombs now connects both ways to the Upper Catacombs. Six keyless
doors, one coin cache, two lore markers, small Skeleton encounters, and a calm
arrival region provide simple test content. No new boss gate is added; the
Chapel remains unavailable. The return chain reaches the Nave's town exit.
See PLAYABLE_LOWER_CATACOMBS_PASS1.md. All 44 test suites pass; live Reliquary
content and generated previews remain unchanged.

## Follow-through: playable connected imported Chapel

The Chapel completes the five-floor imported test chain with twelve keyless
doors, two coin caches, a Black Acolyte stand-in boss, and a victory-revealed
town exit. The Lower Catacombs link is bidirectional and the full stair return
chain remains available. Test completion does not alter live Reliquary quests.
See PLAYABLE_CHAPEL_PASS1.md. All 45 test suites pass. Generated previews and
original campaign content remain unchanged; boss design and balance are pending.
