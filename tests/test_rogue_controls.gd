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
func _initialize():
	call_deferred("run_checks")
func run_checks():
	var game = Game.new()
	root.add_child(game)
	game.load_test_roster()
	game.save_path = "/private/tmp/pass5-controls-save.dat"
	game.enter_dungeon("abandoned_warehouse")
	var rogues = game.get_active_rogues()
	check(not rogues.is_empty(), "existing test party contains Rogue")
	key(game, KEY_R)
	check(game.rogue_skills_open, "R opens Rogue Skills")
	key(game, KEY_2)
	key(game, KEY_ENTER)
	check(game.dungeon.rogue_attempts.is_empty(), "mismatched skill consumes no attempt")
	key(game, KEY_1)
	check(game.dungeon.rogue_attempts.is_empty(), "selecting skill does not attempt")
	key(game, KEY_ESCAPE)
	check(not game.rogue_skills_open and game.game_state == game.GameState.DUNGEON, "cancel preserves exploration state")
	key(game, KEY_ENTER)
	check(game.rogue_skills_open, "Enter on object opens menu")
	# Select a deterministic successful roll through the real UI path.
	for value in range(100):
		seed(value)
		if randi_range(1, 100) <= RogueSkills.SUCCESS_CHANCE:
			seed(value)
			break
	var gold = game.progression.get_party_gold()
	key(game, KEY_ENTER)
	check(game.progression.get_party_gold() == gold + 20, "successful menu action pays reward exactly once")
	key(game, KEY_ENTER)
	check(game.progression.get_party_gold() == gold + 20, "repeated confirm cannot duplicate gold")
	key(game, KEY_F5)
	var records = game.dungeon.rogue_attempts.duplicate(true)
	game.dungeon.rogue_attempts.clear()
	key(game, KEY_F9)
	check(not game.rogue_skills_open and game.dungeon.rogue_attempts == records, "save restores object state and closes menu")
	var old_save = game.capture_save()
	old_save["dungeon"].erase("rogue_attempts")
	check(game.restore_save(old_save) and game.dungeon.rogue_attempts.is_empty(), "Pass 4 save remains compatible")
	var invalid = game.capture_save()
	invalid["dungeon"]["rogue_attempts"] = {"bad":{"resolved":false,"attempts":[9]}}
	check(not game.restore_save(invalid), "malformed object records rejected")
	game.game_state = game.GameState.COMBAT
	key(game, KEY_R)
	game.open_rogue_skills()
	check(not game.rogue_skills_open, "combat cannot open free Rogue Skills")
	game.game_state = game.GameState.DUNGEON
	game.dungeon.player_pos = Vector2i(3,13)
	# Only the Rogue remains conscious, so a failed trap causes game over.
	for member in game.party:
		if member.get("class", "") != "Rogue":
			CharacterHealth.damage(member, 9999)
	game.get_active_rogues()[0]["hp"] = 1
	key(game, KEY_R)
	key(game, KEY_2)
	for value in range(100):
		seed(value)
		if randi_range(1, 100) > RogueSkills.SUCCESS_CHANCE:
			seed(value)
			break
	key(game, KEY_ENTER)
	check(game.game_state == game.GameState.COMBAT_RESULT and not game.rogue_skills_open, "fatal exploration failure uses game-over flow")
	check(game.get_active_rogues()[0]["death_rounds_remaining"] == 3, "exploration failure does not tick death countdown")
	game.queue_free()
	if failures.is_empty():
		print("PASS Rogue menu, rewards, save compatibility, and exploration defeat")
		quit(0)
	else:
		for failure_text in failures:
			push_error(failure_text)
		quit(1)
