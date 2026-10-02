class_name ProgressionSystem
extends RefCounted

var party_gold: int = 0

func award_combat_rewards(party: Array, enemies: Array) -> Dictionary:
	var total_xp = 0
	var gold_found = 0

	for enemy in enemies:
		total_xp += int(enemy.get("xp", 0))
		gold_found += randi_range(
			int(enemy.get("gold_min", 0)),
			int(enemy.get("gold_max", 0))
		)

	var living_party: Array = []
	for member in party:
		if member["hp"] > 0:
			living_party.append(member)

	var xp_each = 0
	if not living_party.is_empty():
		xp_each = int(total_xp / living_party.size())
		for member in living_party:
			member["xp"] += xp_each

	party_gold += gold_found

	return {
		"total_xp": total_xp,
		"xp_each": xp_each,
		"gold": gold_found
	}

func get_party_gold() -> int:
	return party_gold

func can_afford(amount: int) -> bool:
	return party_gold >= max(0, amount)

func spend_gold(amount: int) -> bool:
	amount = max(0, amount)
	if party_gold < amount:
		return false
	party_gold -= amount
	return true

func add_gold(amount: int) -> void:
	party_gold += max(0, amount)
