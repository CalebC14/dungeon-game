extends SceneTree

const Party = preload("res://systems/party.gd")
var failures: Array[String] = []

func check(ok: bool, label: String):
	if not ok:
		failures.append(label)

func _initialize():
	var model = Party.new()
	check(not model.can_adventure(), "empty party stays in Guild")
	for i in range(30):
		check(model.register_character({"name": "Adventurer", "hp": 10}), "register beyond old roster cap")
	check(model.roster.size() == 30, "unlimited reserves")
	var first: String = model.roster[0]["character_id"]
	check(not model.register_character(model.roster[0]), "reject duplicate identity")
	check(not model.assign_member(first, 0, false), "reject assignment outside Guild")
	for i in range(6):
		check(model.assign_member(model.roster[i]["character_id"], i, true), "fill formation")
	check(model.active_members().size() == 6, "six active members")
	var reserve: String = model.roster[20]["character_id"]
	check(model.assign_member(reserve, 4, true), "select reserve beyond first nine")
	check(model.active_members().size() == 6, "replacement cannot create seventh member")
	check(model.roster.size() == 30, "replacement retains reserves")
	check(not model.remove_member(first, false), "reject removal outside Guild")
	check(not model.delete_character(first, false), "reject deletion outside Guild")
	check(model.assign_member(first, 4, true), "swap active positions")
	check(model.slots[0] == reserve and model.slots[4] == first, "active swap preserves displaced member")
	check(model.remove_member(first, true), "remove to reserves")
	check(model.slots[4] == "" and model.slots[5] != "", "empty slot does not compact formation")
	check(not model.assign_member(first, 6, true), "reject invalid position")
	check(not model.assign_member("unknown", 0, true), "reject unknown character")
	var restored = Party.new()
	var encoded = JSON.stringify(model.to_data())
	check(restored.restore(JSON.parse_string(encoded)), "JSON round trip")
	check(restored.slots == model.slots, "restore exact formation including gaps")
	check(restored.roster.size() == 30, "restore all reserves")
	restored.active_members()[0]["hp"] = 3
	check(restored.find_character(reserve)["hp"] == 3, "active state shares canonical roster character")
	var invalid = restored.to_data()
	invalid["slots"][1] = invalid["slots"][0]
	check(not restored.restore(invalid), "reject duplicate slot membership")
	check(restored.slots == model.slots, "failed restore preserves current state")
	check(restored.delete_character(reserve, true), "delete active character")
	check(restored.slots[0] == "", "delete clears only its slot")
	for id in restored.slots.duplicate():
		restored.remove_member(id, true)
	check(not restored.can_adventure(), "empty formation cannot adventure")
	check(restored.assign_member(first, 5, true) and restored.can_adventure(), "one member in rear can adventure")
	if failures.is_empty():
		print("PASS party roster and formation")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
