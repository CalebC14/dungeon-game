extends SceneTree

const Party = preload("res://systems/party.gd")
var failures: Array[String] = []

func check(ok: bool, label: String):
	if not ok:
		failures.append(label)

func character(name_text: String, class_text: String) -> Dictionary:
	var result = CharacterFactory.make_blank_character()
	result.merge({"name": name_text, "class": class_text, "hp": 10, "max_hp": 30}, true)
	return result

func count_items(model) -> int:
	var total = model.inventory.size()
	for member in model.roster:
		for item in member["equipment"].values():
			if item != null:
				total += 1
	return total

func _initialize():
	var model = Party.new()
	var warrior = character("Warrior", "Warrior")
	var mage = character("Mage", "Magician")
	warrior["inventory"] = ["iron_sword", "healing_potion", "silver_ring", "silver_ring", "sun_priest_ring"]
	warrior["equipment"]["off_hand"] = "wooden_shield"
	model.register_character(warrior)
	model.register_character(mage)
	model.assign_member(warrior["character_id"], 0, true)
	var inventory = InventorySystem.new()
	inventory.party_model = model
	check(model.inventory.size() == 5 and warrior["inventory"].is_empty(), "legacy pack pooled once")
	check(warrior["equipment"]["off_hand"] == "wooden_shield", "registration retains worn gear")
	check(not model.register_character(warrior) and model.inventory.size() == 5, "duplicate registration cannot duplicate items")
	var initial = count_items(model)
	inventory.equip_item(mage, 0, false, true)
	check(mage["equipment"]["weapon"] == null and count_items(model) == initial, "class restriction preserves item")
	inventory.equip_item(warrior, 0, true)
	check(warrior["equipment"]["weapon"] == null, "combat equip blocked")
	inventory.equip_item(warrior, 0)
	check(warrior["equipment"]["weapon"] == "iron_sword" and count_items(model) == initial, "shared equip conserves items")
	inventory.unequip_item(warrior, "weapon", true)
	check(warrior["equipment"]["weapon"] == "iron_sword", "combat unequip blocked")
	inventory.unequip_item(warrior, "weapon")
	check(warrior["equipment"]["weapon"] == null and count_items(model) == initial, "unequip returns exact item")
	inventory.equip_item(mage, model.inventory.find("silver_ring"))
	check(mage["equipment"]["accessory_1"] == null, "reserve cannot use shared bag away from Guild")
	inventory.equip_item(mage, model.inventory.find("silver_ring"), false, true)
	inventory.equip_item(mage, model.inventory.find("silver_ring"), false, true)
	inventory.equip_item(mage, model.inventory.find("sun_priest_ring"), false, true)
	check(mage["equipment"]["accessory_1"] == "sun_priest_ring" and mage["equipment"]["accessory_2"] == "silver_ring", "accessory fill and replacement")
	check(count_items(model) == initial and model.inventory.count("silver_ring") == 1, "replaced accessory returned once")
	inventory.use_consumable(warrior, model.inventory.find("healing_potion"), true)
	check(warrior["hp"] == 10 and model.inventory.has("healing_potion"), "combat consumption blocked")
	warrior["hp"] = 0
	inventory.use_consumable(warrior, model.inventory.find("healing_potion"))
	check(warrior["hp"] == 12 and not model.inventory.has("healing_potion"), "shared healing revives incapacitated target and consumes once")
	inventory.add_item({}, "healing_potion")
	warrior["hp"] = 30
	inventory.use_consumable(warrior, model.inventory.find("healing_potion"))
	check(model.inventory.has("healing_potion"), "full health does not waste potion")
	warrior["hp"] = 0
	warrior["dead"] = true
	inventory.use_consumable(warrior, model.inventory.find("healing_potion"))
	check(warrior["hp"] == 0 and model.inventory.has("healing_potion"), "ordinary potion cannot resurrect")
	warrior["dead"] = false
	inventory.add_item({}, "antidote")
	inventory.use_consumable(warrior, model.inventory.find("antidote"))
	check(model.inventory.has("antidote"), "no poison does not waste antidote")
	warrior["effects"] = [{"id": "poison", "duration": 5}, {"id": "curse", "duration": 10}]
	inventory.use_consumable(warrior, model.inventory.find("antidote"))
	check(not model.inventory.has("antidote") and warrior["effects"].size() == 1 and warrior["effects"][0]["id"] == "curse", "antidote removes only poison")
	for i in range(30):
		check(inventory.add_item({}, "healing_potion"), "shared bag exceeds old twelve-slot cap")
	check(not inventory.add_item({}, "unknown"), "unknown additions rejected")
	var before = count_items(model)
	inventory.equip_item(warrior, -1)
	inventory.unequip_item(warrior, "unknown")
	inventory.use_consumable(warrior, 999)
	check(count_items(model) == before, "invalid operations preserve items")
	model.remove_member(warrior["character_id"], true)
	check(warrior["equipment"]["off_hand"] == "wooden_shield", "Guild reserve retains equipment")
	model.delete_character(mage["character_id"], true)
	check(count_items(model) == before, "deleting character returns worn gear to shared pool")
	var restored = Party.new()
	check(restored.restore(JSON.parse_string(JSON.stringify(model.to_data()))), "v2 JSON restore")
	check(restored.inventory == model.inventory and restored.slots == model.slots, "save preserves duplicates and formation")
	var legacy = {"version": 1, "roster": [{"character_id": "old", "inventory": ["healing_potion", "healing_potion"], "equipment": {"weapon": "iron_sword"}}], "slots": ["old", "", "", "", "", ""]}
	check(restored.restore(JSON.parse_string(JSON.stringify(legacy))), "v1 migration supported")
	check(restored.inventory.size() == 2 and restored.roster[0]["inventory"].is_empty() and restored.roster[0]["equipment"]["weapon"] == "iron_sword", "migration preserves equipment and pooled quantities")
	check(restored.restore(restored.to_data()) and restored.inventory.size() == 2, "repeated restore does not duplicate inventory")
	var invalid = restored.to_data()
	invalid["inventory"] = [42]
	check(not restored.restore(invalid) and restored.inventory.size() == 2, "invalid restore leaves live inventory unchanged")
	if failures.is_empty():
		print("PASS shared inventory, equipment, consumables, and migration")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
