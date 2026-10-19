# Party Mechanics — Implementation Pass 4

## Incapacitation and death

Reaching zero HP incapacitates a character. They cannot act or protect the front
line. Each character stores `dead`, `death_rounds_remaining`, and an
`incapacitation_generation` alongside their existing HP and equipment.

A new incapacitation starts with three complete combat rounds remaining. The
round in which the character falls does not count. At each later complete
round, a character who remained incapacitated for that entire round loses one
countdown tick. The third tick causes death. Healing above zero HP immediately
restores consciousness and cancels the countdown. Falling again starts a new
three-round countdown. A generation check prevents healing and falling again
within one round from accidentally ticking the previous countdown.

For example: falling in round 4 leaves three rounds. Completing round 5 leaves
two, round 6 leaves one, and round 7 causes death unless healed first.

Combat ending partway through a round does not advance the countdown. Victory
on the last scheduled turn does complete that round and counts for characters
already incapacitated at its start. A successful escape does not count; a
complete enemy retaliation round after a failed escape does. Exploration,
menus, Guild reserves, saving, and loading never advance countdowns. Entering
another encounter resumes the countdown on its next complete round.

`CharacterHealth` centralizes damage, healing, resurrection, and countdown
handling. Ordinary healing, potions, fountains, training recovery, and developer
healing cannot revive dead characters. Automatic combat healing now considers
incapacitated allies and excludes dead allies. A party with no conscious members
cannot leave the Guild for an adventure.

## Resurrection and conditions

Existing temple locations now offer resurrection. Left / Right selects an
active character; Enter resurrects a dead character at 1 HP. This first-pass
service is free, as approved. It does not replace ordinary healing for an
incapacitated character or remove unrelated conditions. Resurrection spell
costs, class unlocks, and temple pricing remain separate design work.

Effects marked `persistent: true` survive encounter cleanup and save/load.
Poison, curse, disease, paralysis, and petrification IDs default to persistent;
other effects default to encounter-local. Persistent effects without a duration
last until cleansed; explicitly timed effects lose duration only on completed
combat rounds. Exploration pauses their duration. Ordinary healing and
resurrection preserve conditions. The existing antidote removes poison only.
This pass does not invent new condition damage values or enemy condition attacks.

Encounter cleanup removes temporary effects, combat keys, passive event logs,
and cooldowns while preserving character health, countdowns, gear, and
persistent conditions. Class combat passives are re-established through the
existing combat paths.

## Saves and defeat recovery

- Guild departure creates a save before adventuring, including the quick test
  party route. Subsequent Guild departures replace the previous save.
- F5 saves outside combat and unfinished training. F9 loads outside combat.
- The single save is `user://dungeon-save.dat` in Godot's user data directory.
- Saves include the full Guild roster, individual gear, shared inventory,
  formation, HP/SP, death/countdown state, conditions, gold, quest states,
  quest items, locations/facing, defeated fixed encounters, and consumed dungeon
  events. Party schema versions 1 and 2 remain compatible with additive health
  fields.
- Writes use a temporary file and rename after successful completion. Loading
  decodes data without objects and validates staged systems before replacing
  the live game. Invalid or missing saves preserve current state.
- Full-party defeat is game over. Enter reloads the last save, restoring its
  exact state rather than granting a free heal. If no valid save exists, game
  over remains; N explicitly starts a new game.
- `DUNGEON_SAVE_PATH` can point tests to a temporary save so they do not touch
  the player's actual save.

## Validation

Godot 4.7.2: all 20 SceneTree tests pass, including the previous 17 regressions.
Three new suites cover exact death timing and re-incapacitation; real enemy
damage and healing; persistence, disk save/load, defeat recovery, and temple
resurrection. The Guild integration fixture now supplies living characters,
matching the new requirement that a departing party contain a conscious member.

Headless startup passes. The temple, character death details, and game-over
screens were rendered and visually checked with native Godot.

Run each test with:

`Godot --headless --path <project> --script res://tests/<test>.gd`
