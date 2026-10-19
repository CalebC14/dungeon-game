extends SceneTree

class FixedLoot extends LootSystem:
	func roll_enemy_drop(_enemy_id: String) -> String:
		return "healing_potion"

var failures: Array[String] = []
func check(ok: bool, label: String):
	if not ok:
		failures.append(label)

func _initialize():
	var model = PartySystem.new()
	var inventory = InventorySystem.new()
	inventory.party_model = model
	var shop = ShopSystem.new()
	shop.inventory_system = inventory
	var gold = ProgressionSystem.new()
	shop.buy_item("general_store", {}, "iron_sword", gold)
	check(model.inventory.is_empty() and gold.get_party_gold() == 0, "unaffordable purchase is atomic")
	gold.add_gold(1000)
	for i in range(20):
		shop.buy_item("general_store", {}, "healing_potion", gold)
	check(model.inventory.size() == 20 and gold.get_party_gold() == 600, "purchases use shared bag beyond twelve items")
	shop.sell_item("general_store", {}, 19, gold)
	check(model.inventory.size() == 19 and gold.get_party_gold() == 610, "paged sale removes exactly one item and pays once")
	var before = gold.get_party_gold()
	shop.sell_item("general_store", {}, 999, gold)
	shop.buy_item("general_store", {}, "missing", gold)
	shop.buy_item("general_store", {}, "old_key", gold)
	check(gold.get_party_gold() == before and model.inventory.size() == 19, "invalid transactions do not change gold or items")
	inventory.add_item({}, "old_key")
	shop.sell_item("general_store", {}, 19, gold)
	check(model.inventory.back() == "old_key" and gold.get_party_gold() == before, "quest-like zero-value item cannot be sold")
	var loot = FixedLoot.new()
	loot.inventory_system = inventory
	var result = loot.roll_combat_loot([{"id":"skeleton"}, {"id":"skeleton"}, {"id":"skeleton"}], [])
	check(result["received"].size() == 2 and result["lost"].is_empty(), "loot goes directly to shared inventory with existing drop limit")
	check(model.inventory.size() == 22, "loot retains each dropped copy")
	check("Party inventory" in loot.get_result_text(result), "loot report identifies shared destination")
	if failures.is_empty():
		print("PASS shared shop transactions and loot")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
