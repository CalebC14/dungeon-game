# Enemy behavior — first pass

Giant Rats now use an `opportunistic` targeting profile. After finding the
highest-threat reachable member, they have a 30% chance to choose uniformly
from the other reachable living party members. With no alternative, they
keep the threat target. A reachable forced target from a taunt always wins
before any profile roll. Dead and incapacitated members remain excluded.

This retains formation and range rules: a melee rat cannot bypass a standing
front line to attack the rear. If the front collapses, existing exposure rules
apply. A switch adds a combat-log line such as “Giant Rat darts toward Nyx!”
The attack itself uses unchanged accuracy, damage, defense, and health rules.

## Try it

Fight Giant Rats in the Warehouse with at least two conscious front-row
members. Build threat with one member and watch for occasional switches in
the combat log. Test a tank taunt: a reachable taunter should retain its forced
targeting while the effect lasts. With only one reachable member, no switch
is possible. Rear-only parties still use the existing formation-collapse rules.

The Rat Broodmother and every other unconfigured enemy keep threat targeting.
Because Giant Rat data is shared, rats encountered outside the Warehouse also
use this behavior. This is a testing value, not a completed balance decision.

## Data

Enemy definitions accept `behavior` (default `threat`) and
`opportunism_chance` (default 0.30, clamped to 0–1). The encounter constructor
copies both into the enemy instance. Unknown profiles fall back to threat.
Only `opportunistic` currently adds a variation. The profile alters target
preference, not enemy action type; healing, spells, coordination, and scripted
boss actions remain future work. Threat values are retained when a rat switches.

## Validation

All 34 test suites and headless startup pass. New coverage verifies profile
data, zero/guaranteed opportunism, normal mixed behavior, taunt precedence,
front/rear protection and collapse, empty targets, default and unknown profiles,
combat-log feedback, and damage from actual alternate-target attacks.
