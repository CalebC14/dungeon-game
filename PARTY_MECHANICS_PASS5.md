# Party Mechanics — Pass 5: Rogue Skills first pass

This is a small playable test of class-exclusive exploration interactions.
Other classes' exploration abilities remain to be designed.

## Controls and test locations

In a dungeon, press R to open **Rogue Skills**:

- Left / Right selects an active Rogue; there is no party leader or automatic
  choice of the best character.
- 1 selects **Pick Lock**; 2 selects **Disarm Trap**.
- Enter attempts the selected skill on the object at the party's current tile.
- Escape returns to exploration without attempting anything.
- Enter on an object also opens the menu.

The existing quick test party contains Nyx, a Rogue. In the Abandoned Warehouse:

| Location | Object | Skill | Success reward |
| --- | --- | --- | --- |
| Entrance `(1,13)` | Padlocked supply chest | Pick Lock | 20 gold |
| Two tiles east `(3,13)` | Trapped coin box | Disarm Trap | 10 gold |

Both objects are optional and leave movement and quest routes unchanged. The
trap is already visible; detection and hidden-trap discovery are not part of
this test. The target appears in the menu, and nearby object text appears when
standing on its tile.

## Provisional test rules

Both skills use a fixed 70% chance. There are no tools, SP costs, level unlocks,
or stat scaling yet. The menu shows the chance and failure consequence before
confirmation. Selecting a skill or cancelling never spends an attempt.

Each Rogue may attempt each object once. Another eligible Rogue can try after
a failure. Successfully resolving an object ends all further attempts and pays
its reward only once. Failure at Pick Lock leaves the lock shut. Failure at
Disarm Trap deals 4 damage to the selected Rogue, using the shared health system.
It can incapacitate them but does not advance the paused death countdown. If
that leaves the entire active party down, the existing game-over/load flow runs.

Only active, conscious Rogues capable of acting may attempt a skill. Reserves,
other classes, dead/incapacitated characters, controlled characters, and combat
are excluded. Using the wrong skill or standing on an empty tile has no cost.

Attempt history and resolution are stored per dungeon/object and character ID.
They survive leaving, restarting an expedition, and save/load. Earlier saves
without these records remain compatible; malformed records are rejected before
replacing live state. This prevents repeated attempts or duplicate rewards.

## Validation

Godot 4.7.2: all 22 tests pass, including the previous 20 regression suites.
New tests cover skill eligibility, both outcomes, repeat prevention, damage,
menu confirmation/cancellation, one-time rewards, save compatibility, and
exploration defeat. Headless startup passes. Pick Lock, Disarm Trap, and failure
screens were rendered and visually checked in native Godot.
