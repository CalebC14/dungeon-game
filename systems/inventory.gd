class_name InventorySystem
extends RefCounted

const MAX_INVENTORY_SLOTS = 12

func ensure_character_inventory(character: Dictionary):
	if not character.has("equipment"):
		character["equipment"] = CharacterFactory.make_empty_equipment()
	if not character.has("inventory"):
		character["inventory"] = []

func add_item(character: Dictionary, item_id: String) -> bool:
	ensure_character_inventory(character)
	if not ItemData.ITEMS.has(item_id):
		return false
	if character["inventory"].size() >= MAX_INVENTORY_SLOTS:
		return false
	character["inventory"].append(item_id)
	return true

func use_inventory_item(character: Dictionary, inventory_index: int) -> String:
	ensure_character_inventory(character)
	if inventory_index < 0:
		return "Invalid inventory slot."
	if inventory_index >= character["inventory"].size():
		return "That inventory slot is empty."
	var item_id = character["inventory"][inventory_index]
	if not ItemData.ITEMS.has(item_id):
		return "Unknown item."
	var item = ItemData.ITEMS[item_id]
	match item["type"]:
		"equipment":
			return equip_item(character, inventory_index)
		"consumable":
			return use_consumable(character, inventory_index)
		_:
			return item["name"] + " cannot be used right now."

func equip_item(character: Dictionary, inventory_index: int) -> String:
	var item_id = character["inventory"][inventory_index]
	var item = ItemData.ITEMS[item_id]
	if not can_equip(character, item):
		return character["name"] + " cannot equip " + item["name"] + "."
	var target_slot = get_target_slot(character, item)
	if target_slot == "":
		return "No equipment slot is available."
	var old_item = character["equipment"][target_slot]
	character["equipment"][target_slot] = item_id
	character["inventory"].remove_at(inventory_index)
	if old_item != null:
		character["inventory"].append(old_item)
	return character["name"] + " equips " + item["name"] + "."

func can_equip(character: Dictionary, item: Dictionary) -> bool:
	if item["type"] != "equipment":
		return false
	var allowed_classes = item.get("allowed_classes", [])
	if allowed_classes.is_empty():
		return true
	return character["class"] in allowed_classes

func get_target_slot(character: Dictionary, item: Dictionary) -> String:
	var slot = item["slot"]
	if slot != "accessory":
		return slot
	if character["equipment"]["accessory_1"] == null:
		return "accessory_1"
	if character["equipment"]["accessory_2"] == null:
		return "accessory_2"
	return "accessory_1"

func use_consumable(character: Dictionary, inventory_index: int) -> String:
	var item_id = character["inventory"][inventory_index]
	var item = ItemData.ITEMS[item_id]
	match item.get("effect", ""):
		"heal":
			if character["hp"] >= character["max_hp"]:
				return character["name"] + " is already at full health."
			var old_hp = character["hp"]
			character["hp"] = min(character["max_hp"], character["hp"] + item["power"])
			var healed = character["hp"] - old_hp
			character["inventory"].remove_at(inventory_index)
			return character["name"] + " drinks " + item["name"] + " and recovers " + str(healed) + " HP."
		"cure_poison":
			return "Poison is not implemented yet."
	return item["name"] + " has no usable effect."

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
