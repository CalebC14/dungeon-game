extends SceneTree
const Game = preload("res://game.gd")
var failures: Array[String] = []
func check(ok: bool, label: String):
	if not ok:
		failures.append(label)
func key(game, code: int):
	var event = InputEventKey.new()
	event.keycode = code
	event.pressed = true
	game._input(event)
func successful_roll():
	for value in range(100):
		seed(value)
		if randi_range(1,100) <= 70:
			seed(value)
			return
func _initialize():
	call_deferred("run_checks")
func run_checks():
	var game = Game.new()
	root.add_child(game)
	game.party_system = PartySystem.new()
	game.bind_party_services()
	game.save_path = "/private/tmp/pass5-class-menus-save.dat"
	var characters: Dictionary = {}
	for data in ClassData.CLASSES:
		var member = CharacterFactory.make_blank_character()
		member.merge({"name":str(data["name"]) + " Tester", "class":data["name"], "hp":20, "max_hp":20}, true)
		game.party_system.register_character(member)
		characters[data["name"]] = member
		game.party_system.assign_member(member["character_id"], 0, true)
		game.game_state = game.GameState.CITY
		key(game, KEY_K)
		check(game.class_skills_open and game.game_state == game.GameState.CITY, "class menu opens without leaving location: " + str(data["name"]))
		var before = member.duplicate(true)
		key(game, KEY_ENTER)
		check(member == before and game.dungeon.rogue_attempts.is_empty(), "town action and empty menus cause no mutations: " + str(data["name"]))
		key(game, KEY_ESCAPE)
		check(not game.class_skills_open, "class menu cancels")
	game.party_system.assign_member(characters["Warrior"]["character_id"], 0, true)
	game.party_system.assign_member(characters["Hunter"]["character_id"], 1, true)
	game.game_state = game.GameState.DUNGEON
	game.dungeon.player_pos = Vector2i(9,13)
	game.dungeon.facing = 1 # Face away from the puzzle gate to use the Scout object.
	key(game, KEY_ENTER)
	check(game.class_skills_open and game.class_character_index == 0, "object opens menu without auto-selecting best actor")
	key(game, KEY_ENTER)
	check(game.dungeon.rogue_attempts.is_empty(), "wrong class cannot scout")
	key(game, KEY_RIGHT)
	key(game, KEY_1)
	check(game.dungeon.rogue_attempts.is_empty(), "selecting Scout does not attempt")
	successful_roll()
	key(game, KEY_ENTER)
	check("northeast" in game.class_skill_message and game.dungeon.rogue_attempts.size() == 1, "Scout menu reveals danger clue")
	key(game, KEY_ESCAPE)
	game.dungeon.player_pos = Vector2i(11,13)
	key(game, KEY_I)
	game.inventory_character_index = 1
	key(game, KEY_K)
	check(game.class_character_index == 1, "management opens selected active character's class menu")
	key(game, KEY_2)
	successful_roll()
	key(game, KEY_ENTER)
	check(game.progression.get_party_gold() == 10 and "hidden coin pouch" in game.class_skill_message, "Track menu finds one cache")
	key(game, KEY_ENTER)
	check(game.progression.get_party_gold() == 10, "Track cannot duplicate reward")
	key(game, KEY_F5)
	var records = game.dungeon.rogue_attempts.duplicate(true)
	game.dungeon.rogue_attempts.clear()
	key(game, KEY_F9)
	check(not game.class_skills_open and game.dungeon.rogue_attempts == records, "general class records survive save/load and close overlay")
	var old_save = game.capture_save()
	old_save["dungeon"].erase("rogue_attempts")
	check(game.restore_save(old_save), "older saves without exploration records stay compatible")
	game.game_state = game.GameState.COMBAT
	key(game, KEY_K)
	game.open_class_skills()
	check(not game.class_skills_open, "combat cannot open free class menus")
	game.game_state = game.GameState.DUNGEON
	game.dungeon.player_pos = Vector2i(13,13)
	game.party_system.assign_member(characters["Monk"]["character_id"], 0, true)
	game.party_system.remove_member(characters["Hunter"]["character_id"], true)
	var active_monk = game.party_system.find_character(characters["Monk"]["character_id"])
	active_monk["hp"] = 1
	key(game, KEY_K)
	for value in range(100):
		seed(value)
		if randi_range(1,100) > 70:
			seed(value)
			break
	key(game, KEY_ENTER)
	check(game.game_state == game.GameState.COMBAT_RESULT and not game.class_skills_open, "failed crossing uses existing defeat flow")
	check(active_monk["death_rounds_remaining"] == 3, "exploration damage does not advance death timer")
	game.queue_free()
	if failures.is_empty():
		print("PASS all class menus, Scout/Track controls, compatibility, and defeat")
		quit(0)
	else:
		for failure_text in failures:
			push_error(failure_text)
		quit(1)
