# Party Mechanics — Implementation Pass 2

## Combat rules

- Normal melee attacks require the attacker in a front position.
- Quarterstaffs have reach: they can attack from the rear, but still target the
  opposing front while it protects the rear. Short bows are ranged and can
  target either row. Existing swords, axes, and unarmed attacks are melee.
- Shield Bash requires front position; other physical class attacks use their
  equipped weapon's reach. Spells, ranged abilities, and taunts can reach either
  row. Existing damage, resource costs, cooldowns, and threat multipliers remain.
- Any living front defender capable of defending protects all rear positions.
  Falling to zero HP or being stunned, paralyzed, or petrified removes that
  defender's protection. When no front defender can defend, rear characters
  become exposed without moving slots. Healing or recovery restores protection.
- Enemies select reachable targets first, then apply taunts and existing threat.
  A rear tank's threat is retained; a taunt does not let an ordinary melee enemy
  bypass front protection. Interception and retaliation retain their existing
  class-specific behavior.
- Bandit archers use ranged reach; existing caster-tagged enemies use magic
  reach. Other existing enemies default to melee and front position. Optional
  enemy `formation_slot` metadata supports rear placement without automatically
  rearranging encounters.
- Queued attacks recheck reach when executed, after any earlier movement or
  collapse. An invalid target consumes the queued action and produces a log
  message rather than attacking through a protected row.

## Controls

Outside combat, press F in the Guild, town, wilderness, dungeon, or a management
screen. Choose a character's position with 1–6, then a destination with 1–6.
Occupied destinations swap the two active characters. Empty destinations move
only the selected character. Escape returns to the underlying screen/location.
This is free and never recruits or removes a reserve character.

In combat, choose 5 (Reposition), then destination 1–6. The mover spends their
combat action and movement resolves in initiative order. Occupied positions
swap; the displaced character retains their own queued action. Escape cancels
before queuing. Down or controlled characters cannot execute movement. F cannot
open the free formation screen during combat.

Positions remain in the canonical party model across encounters, locations,
and the existing versioned party serialization. This pass does not add disk
saves, the death countdown, shared inventory, or exploration class abilities.

## Validation

Run SceneTree tests with Godot 4.7.2:

`Godot --headless --path <project> --script res://tests/<test>.gd`

- `test_formation_combat.gd`: reach, protected targets, retained threat, taunts,
  collapse and healing, weapon/enemy range metadata, invalid movements, action
  cost, initiative resolution, and serialized formation.
- `test_formation_controls.gd`: free exploration movement, cancellation, queued
  combat movement, context restrictions, and live formation binding.
- All twelve pre-existing tests pass, including Warrior, Paladin, Berserker,
  target selection, combat smoke, and Pass 1 roster/Guild tests.

Headless game startup also passes. Native visual playtesting remains manual.
