# Imported dungeon random encounter pacing — first pass

All five imported test floors now use half the normal dungeon encounter chance.
With the existing 25% base chance, eligible movement rolls have a 12.5% chance.
Quiet areas remain free of random encounters. Other dungeons and wilderness
retain their previous rules.

## Four protected moves

Entering a floor or starting a random/fixed battle grants four successful tile
moves without a random battle. Combat itself does not consume those moves, so
protection remains after victory or escape. The fifth move can roll normally.

- Forward and backward movement consume one protected move each.
- Quiet-area, trap, and lore-event movement also consume a move, even though
  their existing priorities can suppress the random roll.
- Turning, wall bumps, same-position calls, menus, searches, door opening,
  lantern toggling, and saving/loading do not consume protection.
- Fixed encounters still trigger during protected moves. This is random-battle
  protection, not invulnerability or a way to bypass bosses or traps.
- Taking stairs grants fresh protection on the destination floor. This simple
  test policy permits stair re-entry to refresh it; no anti-farming rule is added.

The exploration footer shows how many upcoming moves are still protected.
Zero means the next move is eligible, unless it is quiet or a higher-priority
interaction prevents the random roll.

## Try it

Enter the test Nave with F12 → N. Watch `4 safe moves left` decrease as you
walk. The southern quiet area remains calm even after that value reaches zero.
Explore north or continue through the connected floors for eligible patrol rolls.
After a battle, verify that the counter returns to four and the next four moves
cannot trigger another random battle. Turning or opening a menu leaves it alone.
Save midway through protection, then load: the same remainder should be restored.

These are first-pass testing values. This does not establish final floor balance,
add enemy tiers, change fixed encounters, modify rewards, or change exploration
time and death-countdown rules.

## Data and saves

Each imported floor defines `random_encounter_multiplier: 0.5` and
`encounter_grace_steps: 4`. The runtime clamps the multiplied chance to 0–1.
The developer encounter validator reports invalid multipliers or grace counts.
Unconfigured dungeons default to multiplier 1 and zero grace.

Optional save fields `encounter_grace_remaining` and `encounter_grace_on_step`
preserve both the remainder and whether the current move was protected. This
avoids rolling early after loading the fourth protected step. Invalid negative
or noninteger counts and nonboolean flags reject the save before live mutation.
Older saves without these fields receive the current floor's fresh entry grace.
Rechecking a protected tile does not consume another move.

## Validation

All 47 test suites and headless startup pass, including the existing complete
five-floor journey. The new suite forces eligible rolls to 100% to prove the
four-safe/fifth-eligible boundary after entry and escape, checks victory/fixed
encounter priority, and uses seeded rolls on each side of 12.5% to verify the
reduced probability. It also covers free actions, quiet areas, save boundaries,
older and malformed saves, all five configurations, and unchanged Warehouse
behavior. Native Godot rendering checks the footer readout.

The full-chain smoke test still disables random encounters intentionally;
manual patrol frequency, party resources, and prolonged balance playtesting
remain pending. No claim of final difficulty balance is made by these tests.

## Full-chain test with patrols

The normal-rate seeded journey now completes all five floors with eleven random
battles and three fixed fights; see IMPORTED_CHAIN_RANDOM_TEST_PASS1.md. This
adds integration coverage for patrols without replacing manual balance testing.
Basic spell resource costs still need an audit before drawing endurance conclusions.
