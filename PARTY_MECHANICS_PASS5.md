# Party Mechanics — Pass 5: class menus and exploration testing

All class menu categories are in place. Working physical exploration skills use
simple first-pass rules. Individual out-of-combat spells and Bard songs remain
deferred, as requested; their menus have no actionable entries or resource costs.
Existing combat spells and abilities remain unchanged.

## Menus

| Class | Menu | Working exploration entries |
| --- | --- | --- |
| Warrior | Warrior Skills | Force Obstacle |
| Berserker | Berserker Skills | Break Barricade |
| Rogue | Rogue Skills | Pick Lock, Disarm Trap |
| Hunter | Hunter Skills | Scout, Track |
| Monk | Monk Skills | Traverse Gap |
| Bard | Bard Songs | Songs to be defined |
| Paladin, Priest, Shaman, Conjurer, Magician, Druid, Warlock | Cast Spell | Spells to be defined |

Press **K** outside combat to open the class menu. Left / Right selects an
active character, with no leader or automatic choice of the best character.
Number keys select an ability; Enter attempts it; Escape returns to the original
screen. From party management, K opens the selected active character's menu.

The existing **R** shortcut still opens Rogue Skills in a dungeon. Enter on a
Rogue object opens that menu; Enter on other exploration objects opens the
shared class menu. The player must still choose the appropriate character.
Reserves cannot act, and free class menus cannot open during combat.

## Warehouse test interactions

All interactions are optional objects on walkable tiles along the southern
Warehouse corridor. They do not block movement or quest progress.

| Tile | Object | Skill | Success |
| --- | --- | --- | --- |
| `(1,13)` entrance | Padlocked supply chest | Pick Lock | 20 gold |
| `(3,13)` | Trapped coin box | Disarm Trap | 10 gold |
| `(5,13)` | Heavy storage gate | Force Obstacle | 10 gold |
| `(7,13)` | Brittle timber barricade | Break Barricade | 10 gold |
| `(9,13)` | Warehouse lookout | Scout | Clue identifying the rat nest at `(13,1)` |
| `(11,13)` | Tracks beneath the crates | Track | Finds a hidden coin pouch: 10 gold |
| `(13,13)` | Gap beside the loading ledge | Traverse Gap | Retrieves a coin pouch: 10 gold |

Scout and Track currently operate at these explicit test points. They do not yet
perform general fog-of-war discovery or dynamic trail generation. Likewise,
Force Obstacle, Break Barricade, and Traverse Gap resolve their optional object;
they do not rebuild the map or change pathfinding.

Use the Guild character creator and formation menu to add a Hunter or Monk for
testing. The existing quick test party already contains a Warrior, Berserker,
Rogue, Bard, Paladin, and Magician. It is not automatically replaced or expanded.

## Provisional mechanics

Every working entry uses a fixed 70% chance, without tools, SP costs, level
unlocks, or stat scaling. The menu previews the target, chance, and failure
consequence. Selection and cancellation never spend an attempt.

Each character may attempt each object once. Another eligible character of the
required class can try after a failure. Resolution and rewards occur once only.
A failed disarm deals 4 damage. Failed Force Obstacle, Break Barricade, and
Traverse Gap attempts deal 2 damage. Pick Lock, Scout, and Track failures deal
no damage, but the character loses their opportunity to resolve that object.
Damage uses the existing incapacitation/game-over flow and never advances the
paused exploration death countdown.

Only active, conscious characters of the required class, capable of acting,
may attempt skills. Inappropriate skills, empty tiles, other classes, controlled
characters, reserves, and combat are rejected without spending an attempt.
Exploration targets are currently dungeon-only, including access from the
inventory screen while exploring a dungeon. Class menus can be inspected from
other outside-combat screens without using a stale dungeon target.

Attempt history and resolution survive leaving, restarting an expedition, and
save/load. The shared resolver preserves the original Rogue API and legacy
`rogue_attempts` save field for compatibility; old saves without that field
still load, and malformed records are rejected before replacing live state.

## Validation

Godot 4.7.2: all 24 tests pass, including the prior 22 regressions. New suites
cover all class menu categories, empty spell/song menus, Hunter outcomes,
manual selection, class restrictions, failure damage, duplicate prevention,
management-screen access, save/load, older saves, and exploration defeat.
Headless startup passes. Hunter Skills, Bard Songs, Cast Spell, and Warrior
Skills screens were rendered and visually inspected in native Godot.
