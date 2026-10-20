class_name EncounterValidation
extends RefCounted

static func nonnegative(value: Variant) -> bool:
	return value is int and value >= 0

static func group_errors(entry: Variant, enemies: Dictionary, weighted: bool, context: String) -> Array[String]:
	var errors: Array[String] = []
	if not entry is Dictionary:
		return [context + ": expected an encounter dictionary"]
	if not entry.get("enemy_id") is String or not enemies.has(entry.get("enemy_id")):
		errors.append(context + ": unknown enemy_id")
	var low = entry.get("min_group") if weighted else entry.get("count", 1)
	var high = entry.get("max_group") if weighted else low
	if not low is int or not high is int or low < 1 or high < low:
		errors.append(context + ": invalid group count/range")
	if weighted and (not entry.get("weight") is int or entry.get("weight", 0) <= 0):
		errors.append(context + ": weight must be a positive integer")
	return errors

static func table_errors(table: Variant, enemies: Dictionary, context: String) -> Array[String]:
	var errors: Array[String] = []
	if not table is Array or table.is_empty():
		return [context + ": expected a nonempty encounter table"]
	for i in range(table.size()):
		errors.append_array(group_errors(table[i], enemies, true, context + "[%d]" % i))
	return errors

static func reward_errors(enemies: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	for id in enemies:
		var enemy = enemies[id]
		if not enemy is Dictionary:
			errors.append(str(id) + ": expected enemy dictionary")
			continue
		if not nonnegative(enemy.get("xp")):
			errors.append(str(id) + ": XP must be a nonnegative integer")
		var low = enemy.get("gold_min")
		var high = enemy.get("gold_max")
		if not nonnegative(low) or not nonnegative(high) or high < low:
			errors.append(str(id) + ": invalid gold reward range")
	return errors

static func dungeon_errors(id: String, data: Dictionary, enemies: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var ids: Array[String] = []
	for position in data.get("fixed_encounters", {}):
		var entry = data["fixed_encounters"][position]
		var context = id + " fixed " + str(position)
		if not entry is Dictionary:
			errors.append(context + ": expected encounter dictionary")
			continue
		var encounter_id = entry.get("id", "")
		if not encounter_id is String or encounter_id.is_empty() or encounter_id in ids:
			errors.append(context + ": missing or duplicate fixed encounter id")
		else:
			ids.append(encounter_id)
		var map: Array = data.get("map", [])
		if not position is Vector2i or position.y < 0 or position.y >= map.size() or position.x < 0 or position.x >= map[position.y].length() or map[position.y][position.x] == "#":
			errors.append(context + ": fixed encounter must be on a floor tile")
		if entry.has("groups"):
			if not entry["groups"] is Array or entry["groups"].is_empty():
				errors.append(context + ": mixed groups must be nonempty")
			else:
				for group in entry["groups"]:
					errors.append_array(group_errors(group, enemies, false, context))
		else:
			errors.append_array(group_errors(entry, enemies, false, context))
	for section in ["events", "interactions", "rogue_objects", "exploration_objects"]:
		for object in data.get(section, {}).values():
			for field in ["gold", "reward_gold"]:
				if object.has(field) and not nonnegative(object[field]):
					errors.append(id + " " + str(object.get("id", "?")) + ": invalid " + field)
			if object.has("item_id") and not ItemData.ITEMS.has(object["item_id"]):
				errors.append(id + ": unknown treasure item_id " + str(object["item_id"]))
	return errors

static func all_errors() -> Array[String]:
	var errors = reward_errors(GameData.ENEMIES)
	for id in DungeonEncounterData.TABLES:
		if not DungeonData.DUNGEONS.has(id): errors.append(str(id) + ": unknown dungeon table owner")
		errors.append_array(table_errors(DungeonEncounterData.TABLES[id], GameData.ENEMIES, str(id)))
	for id in WildernessEncounterData.TABLES:
		errors.append_array(table_errors(WildernessEncounterData.TABLES[id], GameData.ENEMIES, str(id)))
	errors.append_array(table_errors(EncounterData.DUNGEON_1, GameData.ENEMIES, "legacy floor 1"))
	for id in DungeonData.DUNGEONS:
		errors.append_array(dungeon_errors(id, DungeonData.DUNGEONS[id], GameData.ENEMIES))
	return errors
