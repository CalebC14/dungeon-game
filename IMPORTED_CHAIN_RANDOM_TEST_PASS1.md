# Full imported chain with random encounters — first test pass

A second end-to-end test enables the normal random encounter rules while
reusing the existing five-floor walking route and combat controller. Gameplay,
party stats, enemy data, rates, and ability costs are unchanged.

## Setup

- Unmodified six-character test party; seed 123456, applied after game startup
  and party setup. Startup calls `randomize()`, so seeding before creating the
  game was ineffective. Both journey tests now seed after initialization.
  Two repeat runs produced identical battle/resource logs.
- Normal 25% base chance with the imported floors' 0.5 multiplier: 12.5% on
  eligible movement, plus existing quiet areas and four-move protection.
- Keyboard walking, turning, door opening, searches, and stair travel.
- Ordinary queued combat actions: front members attack, rear Magician/Priest
  use existing abilities, and the Bard defends. No forced enemy deaths, resource
  restoration, stat boosts, potion automation, or developer healing.
- Actual F5/F9 disk checkpoint midway through the journey, checking full saved
  state including pacing fields. The temporary save is removed afterward.

## Seeded result

The full journey completes and returns to Thornwake through the Chapel exit.

| Floor | Random battles | Fixed battles |
| --- | ---: | ---: |
| Church Nave | 0 | 1 |
| Archives | 2 | 1 |
| Upper Catacombs | 3 | 0 |
| Lower Catacombs | 5 | 0 |
| Chapel | 1 | 1 |
| Total | 11 | 3 |

The forward route walks 246 tiles and opens eight doors. It searches six caches,
checks each pays once, and accumulates ordinary combat rewards. The older
random-disabled smoke test additionally revisits the first cache afterward;
its 262-step total includes that extra visit, so the route totals differ.

Initial party totals: 136 HP, 60 SP, six conscious, zero dead. The party also
finishes with 136 HP, 60 SP, six conscious, zero dead. The test logs HP/SP and
conscious/dead counts after every battle, plus floor, movement step, and battle
type. It checks no random fight starts in a quiet area and that random fights
on the same floor respect movement protection after the preceding battle.
All three fixed encounters occur, victory rewards are claimed normally, the
live quest state remains unchanged, and the final exit works after save/load.

## Balance finding

This run demonstrates integration and pacing behavior, not meaningful resource
attrition or final difficulty. The basic Arcane Bolt and Mend implementations
used by this policy currently do not deduct SP, unlike resource-gated tank
abilities. Healing and fast victories can also leave the party at full HP.
Changing those costs or difficulty was deliberately not part of this testing
pass. Audit basic ability resource costs before using these outcomes to judge
long-dungeon endurance.

One seed and one simple action policy do not cover all encounter sequences,
party compositions, or player choices. Lower Catacombs had the most random
fights on this particular route; that is not a general encounter-rate estimate.

## Run and validation

```
Godot --headless --path /Users/caleb/dungeon-game --script res://tests/test_imported_chain_random.gd
```

Replace `Godot` with the installed executable. The new test subclasses the
existing random-disabled journey so both modes use the same navigation and
checkpoint logic. It fails on an incomplete journey, missing random/fixed
battles, protection/quiet-area violations, state mismatch, or invalid completion.
All 48 test suites and headless startup pass.

For manual testing, use F12 → N with a prepared active party and the per-floor
walkthroughs. Observe quiet areas and the safe-move readout; save midway and
continue. After the Chapel victory, stand at `(12,2)`, face north, and press
Enter. Compare party resources and battle frequency over several runs before
changing balance values.
