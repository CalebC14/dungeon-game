class_name LootSystem
extends RefCounted

var inventory_system = InventorySystem.new()

const MAX_DROPS_PER_COMBAT = 2

func roll_combat_loot(enemies: Array, party: Array) -> Dictionary:
	var dropped: Array = []
	var received: Array = []
	var lost: Array = []

	for enemy in enemies:
		if dropped.size() >= MAX_DROPS_PER_COMBAT:
			break

		var item_id = roll_enemy_drop(str(enemy.get("id", "")))
		if item_id == "":
			continue
		dropped.append(item_id)

		var receiver = find_receiver(party)
		if receiver.is_empty():
			lost.append(item_id)
			continue

		if inventory_system.add_item(receiver, item_id):
			received.append({"item_id": item_id, "character": receiver["name"]})
		else:
			lost.append(item_id)

	return {"dropped": dropped, "received": received, "lost": lost}

func roll_enemy_drop(enemy_id: String) -> String:
	if not LootData.LOOT_TABLES.has(enemy_id):
		return ""

	var table = LootData.LOOT_TABLES[enemy_id]
	if randf() > float(table.get("chance", 0.0)):
		return ""

	var entries: Array = table.get("items", [])
	if entries.is_empty():
		return ""

	var total_weight = 0
	for entry in entries:
		total_weight += int(entry.get("weight", 0))
	if total_weight <= 0:
		return ""

	var roll = randi_range(1, total_weight)
	var running = 0
	for entry in entries:
		running += int(entry.get("weight", 0))
		if roll <= running:
			return str(entry["item_id"])

	return ""

func find_receiver(party: Array) -> Dictionary:
	for member in party:
		if member["hp"] <= 0:
			continue
		inventory_system.ensure_character_inventory(member)
		if member["inventory"].size() < InventorySystem.MAX_INVENTORY_SLOTS:
			return member
	return {}

func get_result_text(result: Dictionary) -> String:
	var lines: Array[String] = []

	for entry in result.get("received", []):
		var item_id = entry["item_id"]
		lines.append(
			ItemData.ITEMS[item_id]["name"]
			+ " -> " + entry["character"]
		)

	for item_id in result.get("lost", []):
		lines.append(ItemData.ITEMS[item_id]["name"] + " (left behind: packs full)")

	if lines.is_empty():
		return ""

	return "\nLOOT:\n" + "\n".join(lines)
