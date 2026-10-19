extends SceneTree
var failures: Array[String] = []
func check(ok: bool, label: String):
	if not ok:
		failures.append(label)
func actor(name_text: String, class_text: String) -> Dictionary:
	var result = CharacterFactory.make_blank_character()
	result.merge({"name":name_text, "class":class_text, "hp":2, "max_hp":20}, true)
	return result
func _initialize():
	var dungeon = DungeonSystem.new()
	var objects: Dictionary = dungeon.dungeon_data["rogue_objects"].duplicate()
	objects.merge(dungeon.dungeon_data["exploration_objects"])
	check(objects.size() == 7, "seven optional objects cover every implemented skill")
	for pos in objects:
		dungeon.player_pos = pos
		check(dungeon.can_move_to(pos), "test object is reachable floor")
		var object: Dictionary = objects[pos]
		var skill: String = object["skill"]
		var character_class: String = ExplorationSkills.SKILLS[skill]["class"]
		var model = PartySystem.new()
		var first = actor("First", character_class)
		var second = actor("Second", character_class)
		var wrong = actor("Wrong", "Magician")
		for member in [first, second, wrong]:
			model.register_character(member)
		for i in range(3):
			model.assign_member(model.roster[i]["character_id"], i, true)
		check(not ExplorationSkills.attempt(model, dungeon, wrong, skill)["attempted"], "class restriction: " + skill)
		check(not ExplorationSkills.attempt(model, dungeon, first, skill, true)["attempted"], "combat restriction: " + skill)
		var before_sp = first["sp"]
		var failure = ExplorationSkills.attempt(model, dungeon, first, skill, false, 71)
		check(failure["attempted"] and not failure["success"] and failure["gold"] == 0, "failure boundary: " + skill)
		check(first["sp"] == before_sp, "no new resource costs: " + skill)
		if int(object.get("failure_damage", 0)) > 0:
			check(first["hp"] == 0 and first["death_rounds_remaining"] == 3, "failure uses health and pauses countdown: " + skill)
		check(not ExplorationSkills.attempt(model, dungeon, first, skill, false, 1)["attempted"], "no retry: " + skill)
		var success = ExplorationSkills.attempt(model, dungeon, second, skill, false, 70)
		check(success["success"] and success["gold"] == int(object.get("reward_gold", 0)), "success boundary and reward: " + skill)
		if skill == "scout":
			check("northeast" in success["message"] and "13,1" in success["message"], "Scout reveals actual Warehouse danger clue")
		if skill == "track":
			check("hidden coin pouch" in success["message"] and success["gold"] == 10, "Track finds a cache")
		check(not ExplorationSkills.attempt(model, dungeon, second, skill, false, 1)["attempted"], "no duplicate reward: " + skill)
	check(ExplorationSkills.valid_records(dungeon.rogue_attempts), "shared record format supports all skills")
	check(ExplorationSkills.skills_for_class("Hunter") == ["scout", "track"], "Hunter has Scout and Track")
	check(ExplorationSkills.skills_for_class("Bard").is_empty(), "songs deferred")
	for class_name_text in ["Paladin", "Priest", "Shaman", "Conjurer", "Magician", "Druid", "Warlock"]:
		check(ExplorationSkills.menu_name(class_name_text) == "Cast Spell" and ExplorationSkills.skills_for_class(class_name_text).is_empty(), "spell menu without invented spells: " + class_name_text)
	check(not RogueSkills.SKILLS.has("scout"), "Rogue interface remains class specific")
	if failures.is_empty():
		print("PASS class-exclusive exploration skills, Hunter outcomes, and deferred magic")
		quit(0)
	else:
		for failure_text in failures:
			push_error(failure_text)
		quit(1)
