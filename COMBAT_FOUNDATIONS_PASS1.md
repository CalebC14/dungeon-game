# Combat foundations — audit follow-through

## Initiative

Actions resolve in descending Dexterity. Equal-Dexterity ties now use an
explicit sequence: party members in action-selection order, then enemies in
encounter order. This removes reliance on the sorting algorithm's behavior
for equal elements. Higher-Dexterity enemies still act before slower members.

## Action submission

Each character dictionary may submit one action per round. Duplicate
submissions are rejected and do not overwrite the first action. Incapacitated,
dead, or action-blocked characters cannot queue. When a canonical party is
bound, only its active canonical members can submit: Guild reserves and copied
records are rejected. Queue submission returns a boolean for callers.

Existing resolution still rechecks whether an actor can act on their turn.
This pass does not redesign the action-selection interface or class abilities.

## Effects and cooldowns

Existing behavior is retained and documented correctly: durations count
completed-round boundaries, including the round in which they are applied.
A duration of 1 expires at the next completed-round tick. A cooldown of 2 set
during a round becomes 1 at its completion, then 0 at the following completed
round. Incomplete rounds do not advance these counters. Permanent effects
retain their existing behavior. Death countdown timing is unchanged.

This is a clarification of current effect timing, not a new immunity or
resistance policy. Changing to full future-round durations would require a
separate class-ability balance pass.

## Validation

All 33 test suites pass, including the existing death timing, formation,
health, and class-ability suites. The added suite verifies actual round
resolution order, duplicate rejection, canonical actor checks, fresh effect
expiry, cooldown boundaries, and incomplete-round behavior. Headless startup
also passes.

## Next focused pass

Data-selected enemy targeting profiles, preserving threat-based behavior as
the default. Define the rat opportunism chance and taunt precedence before
implementing that behavior.
