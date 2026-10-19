extends SceneTree
var failures: Array[String] = []
func check(ok: bool, label: String):
	if not ok:
		failures.append(label)
func actor(name_text: String, class_text: String = "Rogue") -> Dictionary:
	var result = CharacterFactory.make_blank_character()
	result.merge({"name":name_text, "class":class_text, "hp":20, "max_hp":20}, true)
	return result
func _initialize():
	var model = PartySystem.new()
	var rogue = actor("First")
	var other = actor("Second")
	var warrior = actor("Warrior", "Warrior")
	var reserve = actor("Reserve")
	for member in [rogue, other, warrior, reserve]:
		model.register_character(member)
	for i in range(3):
		model.assign_member(model.roster[i]["character_id"], i, true)
	var dungeon = DungeonSystem.new()
	check(not dungeon.get_rogue_object().is_empty(), "lock is available at Warehouse entrance")
	check(not RogueSkills.attempt(model, dungeon, warrior, "pick_lock")["attempted"], "class exclusive")
	check(not RogueSkills.attempt(model, dungeon, reserve, "pick_lock")["attempted"], "Guild reserve cannot attempt")
	check(not RogueSkills.attempt(model, dungeon, rogue, "pick_lock", true)["attempted"], "combat disallows skill")
	check(not RogueSkills.attempt(model, dungeon, rogue, "disarm_trap")["attempted"], "wrong skill cannot affect object")
	check(dungeon.rogue_attempts.is_empty(), "invalid attempts do not consume tries")
	var failure = RogueSkills.attempt(model, dungeon, rogue, "pick_lock", false, 71)
	check(failure["attempted"] and not failure["success"] and rogue["hp"] == 20 and failure["gold"] == 0, "failed lock attempt has no damage or reward")
	check(not RogueSkills.attempt(model, dungeon, rogue, "pick_lock", false, 1)["attempted"], "same Rogue cannot reroll")
	var success = RogueSkills.attempt(model, dungeon, other, "pick_lock", false, 70)
	check(success["success"] and success["gold"] == 20, "another Rogue can succeed at seventy percent boundary")
	check(not RogueSkills.attempt(model, dungeon, rogue, "pick_lock", false, 1)["attempted"], "resolved object cannot reward twice")
	dungeon.load_dungeon("abandoned_warehouse")
	dungeon.begin_expedition()
	check(not RogueSkills.attempt(model, dungeon, other, "pick_lock")["attempted"], "leaving or starting expedition does not reset object")
	dungeon.player_pos = Vector2i(3,13)
	rogue["hp"] = 1
	var trap = RogueSkills.attempt(model, dungeon, rogue, "disarm_trap", false, 100)
	check(not trap["success"] and rogue["hp"] == 0 and rogue["death_rounds_remaining"] == 3, "failed disarm uses incapacitation without advancing countdown")
	check(not RogueSkills.attempt(model, dungeon, rogue, "disarm_trap")["attempted"], "incapacitated cannot act")
	var effects = preload("res://systems/combat_effects.gd").new()
	effects.apply(other, {"id":"paralysis", "kind":"control"})
	check(not RogueSkills.attempt(model, dungeon, other, "disarm_trap")["attempted"], "controlled Rogue cannot act")
	other["effects"] = []
	check(RogueSkills.attempt(model, dungeon, other, "disarm_trap", false, 1)["success"], "second Rogue can disarm trap")
	check(RogueSkills.valid_records(dungeon.rogue_attempts), "records can persist")
	check(not RogueSkills.valid_records({"bad":{"resolved":true,"attempts":[7]}}), "malformed records rejected")
	dungeon.player_pos = Vector2i(2,13)
	check(not RogueSkills.attempt(model, dungeon, other, "pick_lock")["attempted"], "no object tile is harmless")
	if failures.is_empty():
		print("PASS Rogue class skills, outcomes, eligibility, and repeat prevention")
		quit(0)
	else:
		for failure_text in failures:
			push_error(failure_text)
		quit(1)
