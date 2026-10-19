class_name InventorySystem
extends RefCounted

# Only unbound legacy callers retain individual pack limits.
const MAX_INVENTORY_SLOTS = 12
const EQUIPMENT_SLOTS = ["weapon", "off_hand", "head", "body", "hands", "feet", "accessory_1", "accessory_2", "trinket"]
var party_model: PartySystem = null

func ensure_character_inventory(character: Dictionary):
	if not character.has("equipment"):
		character["equipment"] = CharacterFactory.make_empty_equipment()
	for slot in EQUIPMENT_SLOTS:
		if not character["equipment"].has(slot):
			character["equipment"][slot] = null
	if not character.has("inventory"):
		character["inventory"] = []

func get_inventory(character: Dictionary = {}) -> Array:
	if party_model != null:
		return party_model.inventory
	ensure_character_inventory(character)
	return character["inventory"]

func valid_target(character: Dictionary, at_guild: bool) -> bool:
	if party_model == null:
		return not character.is_empty()
	var id = str(character.get("character_id", ""))
	return not id.is_empty() and is_same(party_model.find_character(id), character) and (at_guild or party_model.slots.has(id))

func add_item(character: Dictionary, item_id: String) -> bool:
	if not ItemData.ITEMS.has(item_id):
		return false
	var bag = get_inventory(character)
	if party_model == null and bag.size() >= MAX_INVENTORY_SLOTS:
		return false
	bag.append(item_id)
	return true

func use_inventory_item(character: Dictionary, inventory_index: int, in_combat: bool = false, at_guild: bool = false) -> String:
	if in_combat:
		return "Inventory changes and consumables are unavailable during combat."
	if not valid_target(character, at_guild):
		return "Choose an active character, or visit the Guild to manage reserves."
	var bag = get_inventory(character)
	if inventory_index < 0 or inventory_index >= bag.size():
		return "That inventory slot is empty."
	var item: Dictionary = ItemData.ITEMS.get(bag[inventory_index], {})
	match item.get("type", ""):
		"equipment":
			return equip_item(character, inventory_index, in_combat, at_guild)
		"consumable":
			return use_consumable(character, inventory_index, in_combat, at_guild)
	return str(item.get("name", "This item")) + " cannot be used right now."

func equip_item(character: Dictionary, inventory_index: int, in_combat: bool = false, at_guild: bool = false) -> String:
	if in_combat or not valid_target(character, at_guild):
		return "Equipment changes are unavailable here."
	ensure_character_inventory(character)
	var bag = get_inventory(character)
	if inventory_index < 0 or inventory_index >= bag.size():
		return "That inventory slot is empty."
	var item_id = bag[inventory_index]
	var item: Dictionary = ItemData.ITEMS.get(item_id, {})
	if not can_equip(character, item):
		return str(character.get("name", "Character")) + " cannot equip " + str(item.get("name", "this item")) + "."
	var target_slot = get_target_slot(character, item)
	if target_slot not in EQUIPMENT_SLOTS:
		return "No equipment slot is available."
	var old_item = character["equipment"][target_slot]
	character["equipment"][target_slot] = item_id
	bag.remove_at(inventory_index)
	if old_item != null:
		bag.append(old_item)
	return str(character["name"]) + " equips " + str(item["name"]) + "."

func unequip_item(character: Dictionary, slot: String, in_combat: bool = false, at_guild: bool = false) -> String:
	if in_combat or not valid_target(character, at_guild):
		return "Equipment changes are unavailable here."
	ensure_character_inventory(character)
	if slot not in EQUIPMENT_SLOTS or character["equipment"][slot] == null:
		return "That equipment slot is empty."
	var item_id = character["equipment"][slot]
	var bag = get_inventory(character)
	if party_model == null and bag.size() >= MAX_INVENTORY_SLOTS:
		return "The pack is full."
	bag.append(item_id)
	character["equipment"][slot] = null
	return str(character["name"]) + " unequips " + str(ItemData.ITEMS.get(item_id, {}).get("name", item_id)) + "."

func can_equip(character: Dictionary, item: Dictionary) -> bool:
	if item.get("type", "") != "equipment":
		return false
	var allowed_classes = item.get("allowed_classes", [])
	return allowed_classes.is_empty() or character.get("class", "") in allowed_classes

func get_target_slot(character: Dictionary, item: Dictionary) -> String:
	var slot = item.get("slot", "")
	if slot != "accessory":
		return slot
	if character["equipment"]["accessory_1"] == null:
		return "accessory_1"
	if character["equipment"]["accessory_2"] == null:
		return "accessory_2"
	return "accessory_1"

func use_consumable(character: Dictionary, inventory_index: int, in_combat: bool = false, at_guild: bool = false) -> String:
	if in_combat or not valid_target(character, at_guild):
		return "Consumables are unavailable here."
	var bag = get_inventory(character)
	if inventory_index < 0 or inventory_index >= bag.size():
		return "That inventory slot is empty."
	var item: Dictionary = ItemData.ITEMS.get(bag[inventory_index], {})
	if item.get("type", "") != "consumable":
		return "That item is not a consumable."
	if bool(character.get("dead", false)):
		return "Ordinary consumables cannot revive the dead."
	match item.get("effect", ""):
		"heal":
			if character["hp"] >= character["max_hp"]:
				return str(character["name"]) + " is already at full health."
			var healed = CharacterHealth.heal(character, int(item["power"]))
			if healed <= 0:
				return "No healing was needed."
			bag.remove_at(inventory_index)
			return str(character["name"]) + " recovers " + str(healed) + " HP."
		"cure_poison":
			var remaining: Array = []
			var cured = false
			for effect in character.get("effects", []):
				if str(effect.get("id", "")) == "poison":
					cured = true
				else:
					remaining.append(effect)
			if not cured:
				return str(character["name"]) + " is not poisoned."
			character["effects"] = remaining
			bag.remove_at(inventory_index)
			return str(character["name"]) + " is cured of poison."
	return str(item.get("name", "This item")) + " has no usable effect."

func get_equipped_items(character: Dictionary) -> Array:
	ensure_character_inventory(character)
	var result: Array = []
	for slot in character["equipment"]:
		var item_id = character["equipment"][slot]
		if item_id == null:
			continue
		if not ItemData.ITEMS.has(item_id):
			continue
		result.append(ItemData.ITEMS[item_id])
	return result

func get_weapon(character: Dictionary) -> Dictionary:
	ensure_character_inventory(character)
	var weapon_id = character["equipment"]["weapon"]
	if weapon_id == null:
		return {}
	if not ItemData.ITEMS.has(weapon_id):
		return {}
	return ItemData.ITEMS[weapon_id]

func get_weapon_accuracy(character: Dictionary) -> float:
	var weapon = get_weapon(character)
	if weapon.is_empty():
		return 0.0
	return float(weapon.get("accuracy", 0.0))

func roll_weapon_damage(character: Dictionary) -> int:
	var weapon = get_weapon(character)
	if weapon.is_empty():
		return randi_range(0, 1)
	return randi_range(int(weapon.get("damage_min", 0)), int(weapon.get("damage_max", 1)))

func get_total_avoidance(character: Dictionary) -> float:
	var total: float = 0.0
	for item in get_equipped_items(character):
		total += float(item.get("avoidance", 0.0))
	return total

func get_total_absorption(character: Dictionary) -> int:
	var total: int = 0
	for item in get_equipped_items(character):
		total += int(item.get("absorption", 0))
	return total

func get_total_armor(character: Dictionary) -> int:
	return get_total_absorption(character)

func get_weapon_damage_text(character: Dictionary) -> String:
	var weapon = get_weapon(character)
	if weapon.is_empty():
		return "UNARMED +0-1"
	return weapon["name"] + " +" + str(weapon.get("damage_min", 0)) + "-" + str(weapon.get("damage_max", 1))

func get_combat_summary(character: Dictionary) -> String:
	var accuracy = int(get_weapon_accuracy(character) * 100.0)
	var avoidance = int(get_total_avoidance(character) * 100.0)
	return "Weapon Acc " + signed_percent(accuracy) + "   Avoid " + signed_percent(avoidance) + "   Absorb " + str(get_total_absorption(character))

func signed_percent(value: int) -> String:
	if value >= 0:
		return "+" + str(value) + "%"
	return str(value) + "%"
