# Party Mechanics — Implementation Pass 3

## Shared inventory and ownership

All unequipped items belong to the party's shared inventory. Equipment remains
on individual characters, subject to existing class restrictions. A copy of an
item exists either in the shared bag or in one character's equipment slot.
Equipping removes that copy from the bag; replacing or unequipping returns the
old copy. Duplicate item IDs represent separate copies and are preserved.

Guild reserves retain equipped gear when leaving the active party. Their gear
can be inspected or changed at the Guild. Reserves cannot draw from the shared
bag elsewhere. Deleting a Guild character returns equipped items to the shared
inventory before removing the character.

The shared bag has no new weight or item-count limit. The previous twelve-slot
individual pack cap applies only to unbound legacy system callers. Shared items
are paged in the interface rather than cut off at nine entries.

## Management controls

- Press I outside combat to open party management, including from the Guild,
  town, wilderness, dungeon, shops, and service screens.
- Left / Right selects the recipient. At the Guild this includes reserves;
  elsewhere it includes active characters only.
- B: shared Bag. Page Up / Page Down browses nine items per page. Number keys
  1–9 equip or use the corresponding item on the selected character.
- E: Equipment. Number keys 1–9 unequip the displayed slot into the shared bag.
- D: Details. Shows attributes, combat equipment bonuses, class/specialization,
  HP/SP/XP, conditions, racial trait, and currently unlocked combat skills.
- F opens the existing formation overlay. Escape returns to party management;
  another Escape returns to the original location or service screen.
- All equipment and consumable operations are free outside combat. Combat
  blocks the inventory shortcut and the underlying mutation methods support
  an explicit combat restriction.

Healing potions consume exactly one copy after healing, including recovery from
zero HP. They do not consume at full HP or resurrect a character marked dead.
Antidotes remove existing effects with ID `poison`, preserve unrelated effects,
and consume only when poison is removed. This pass adds no poison damage ticks,
death countdown, resurrection system, or new conditions.

## Shops, loot, and treasure

Purchases enter the shared bag. Sales use the shared bag and cannot sell worn
items; unequip first. Buy/sell lists support Page Up / Page Down and number keys.
Prices, gold handling, class restrictions, drop chances, and the existing limit
of two loot drops per encounter remain unchanged. Combat loot and dungeon
item treasure enter the shared inventory directly.

## Serialized data

Party schema version 2 includes the shared `inventory` array. Registering an old
character or restoring version 1 party data transfers individual pack contents
to the pool and clears the old packs. Equipment, character IDs, duplicate item
quantities, and exact formation positions are preserved. Repeated version 2
round trips do not duplicate items. Restore validates data before replacing
live state. General disk save/load remains a future feature.

## Verification

Validated using Godot 4.7.2:

- All 17 SceneTree tests pass, including all 14 existing regression tests.
- New `test_shared_inventory.gd` covers ownership, class restrictions, combat
  restrictions, reserves, accessory replacement, consumables, and migration.
- New `test_shared_economy.gd` covers purchases, sales, invalid transactions,
  shared capacity, and deterministic loot delivery.
- New `test_party_management.gd` covers keyboard controls, paging, target
  selection, Guild reserves, shop integration, and dungeon item delivery.
- Headless startup passes. Bag, Equipment, Details, and Shop screens were
  rendered and visually inspected in the native Godot renderer.

Run tests with:

`Godot --headless --path <project> --script res://tests/<test>.gd`
