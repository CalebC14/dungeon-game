extends SceneTree
const Game = preload("res://game.gd")
var failures: Array[String] = []
func check(ok: bool, label: String):
	if not ok: failures.append(label)
func key(game, code: int):
	var event = InputEventKey.new()
	event.keycode = code
	event.pressed = true
	game._input(event)
func roll_seed(low: float, high: float) -> int:
	for candidate in range(10000):
		seed(candidate)
		var roll = randf()
		if roll >= low and roll < high: return candidate
	return -1
func _initialize(): call_deferred("run_checks")
func run_checks():
	var game = Game.new()
	root.add_child(game)
	game.load_test_roster()
	for id in ["architect_test_church_nave","architect_test_archives","architect_test_catacombs_upper","architect_test_catacombs_lower","architect_test_black_warlock_chapel"]:
		game.enter_dungeon(id)
		check(game.dungeon.encounter_grace_remaining == 4 and game.dungeon.dungeon_data["random_encounter_multiplier"] == 0.5, "pacing configured on " + id)
	game.enter_dungeon("architect_test_church_nave")
	var d = game.dungeon
	d.player_pos = Vector2i(12,7)
	d.facing = 0
	game.encounter_chance = 2.0 # Multiplier makes a deterministic 100% eligible roll.
	for i in range(4):
		key(game,KEY_UP if i % 2 == 0 else KEY_DOWN)
		check(game.game_state == game.GameState.DUNGEON and d.encounter_grace_remaining == 3-i, "protected move %d cannot start random battle" % (i+1))
	check(d.encounter_grace_remaining == 0 and d.encounter_grace_on_step, "fourth protected move does not roll early")
	game.check_for_encounter()
	check(game.game_state == game.GameState.DUNGEON, "rechecking protected tile does not consume protection")
	check(game.restore_save(game.capture_save()), "last protected step saves")
	d = game.dungeon
	game.check_for_encounter()
	check(game.game_state == game.GameState.DUNGEON and d.encounter_grace_on_step, "load preserves last protected movement")
	key(game,KEY_UP)
	check(game.game_state == game.GameState.COMBAT and d.encounter_grace_remaining == 4, "fifth move can fight and resets protection")
	seed(roll_seed(0.0,0.60))
	game.attempt_party_escape()
	check(game.game_state == game.GameState.DUNGEON and d.encounter_grace_remaining == 4, "escape retains post-battle protection")
	key(game,KEY_RIGHT)
	d.player_pos = Vector2i(9,6)
	d.facing = 3
	key(game,KEY_UP) # Wall west of (9,6).
	check(d.encounter_grace_remaining == 4, "turn and wall bump do not consume protection")
	d.player_pos = Vector2i(12,6)
	key(game,KEY_RIGHT)
	key(game,KEY_L)
	key(game,KEY_I)
	key(game,KEY_ESCAPE)
	check(d.encounter_grace_remaining == 4, "light and menus do not consume protection")
	for i in range(4):
		key(game,KEY_DOWN if i % 2 == 0 else KEY_UP)
		check(game.game_state == game.GameState.DUNGEON, "post-battle protected step %d" % (i+1))
	key(game,KEY_DOWN)
	check(game.game_state == game.GameState.COMBAT, "post-battle fifth move can fight")
	game.enter_dungeon("architect_test_church_nave")
	d.player_pos = Vector2i(12,4)
	game.check_dungeon_tile()
	check(game.game_state == game.GameState.COMBAT and game.current_combat_tag == "architect_nave_guardian", "fixed encounter ignores random cooldown")
	for enemy in game.combat.enemies: enemy["hp"] = 0
	game.handle_combat_victory()
	key(game,KEY_ENTER)
	check(d.encounter_grace_remaining == 4, "victory retains post-battle protection")
	# Confirm the new default probability with rolls on either side of 12.5%.
	d.player_pos = Vector2i(12,7)
	d.facing = 0
	for i in range(5): d.move_to(Vector2i(12,6) if i % 2 == 0 else Vector2i(12,7))
	game.encounter_chance = 0.25
	seed(roll_seed(0.125,0.25))
	game.check_for_encounter()
	check(game.game_state == game.GameState.DUNGEON, "roll between 12.5% and 25% is now safe")
	seed(roll_seed(0.0,0.125))
	game.check_for_encounter()
	check(game.game_state == game.GameState.COMBAT, "roll below 12.5% can start random battle")
	game.enter_dungeon("architect_test_church_nave")
	d.player_pos = Vector2i(12,11)
	for i in range(6): d.move_to(Vector2i(13,11) if i % 2 == 0 else Vector2i(12,11))
	game.encounter_chance = 2.0
	game.check_for_encounter()
	check(game.game_state == game.GameState.DUNGEON and d.is_quiet_area(), "quiet areas stay quiet after cooldown expires")
	d.reset_encounter_grace()
	d.move_to(Vector2i(12,10))
	check(game.restore_save(game.capture_save()) and game.dungeon.encounter_grace_remaining == 3, "remaining grace saves")
	d = game.dungeon
	var bad = game.capture_save()
	bad["dungeon"]["encounter_grace_remaining"] = -1
	check(not game.restore_save(bad) and d.encounter_grace_remaining == 3, "invalid grace count rejected atomically")
	bad["dungeon"]["encounter_grace_remaining"] = 3
	bad["dungeon"]["encounter_grace_on_step"] = "yes"
	check(not game.restore_save(bad), "invalid grace flag rejected")
	var legacy = game.capture_save()
	legacy["dungeon"].erase("encounter_grace_remaining")
	legacy["dungeon"].erase("encounter_grace_on_step")
	check(game.restore_save(legacy) and game.dungeon.encounter_grace_remaining == 4, "older save gets fresh configured grace")
	game.enter_dungeon("abandoned_warehouse")
	d = game.dungeon
	d.player_pos = Vector2i(13,9)
	game.encounter_chance = 1.0
	game.check_for_encounter()
	check(game.game_state == game.GameState.COMBAT and d.encounter_grace_remaining == 0, "other dungeons retain prior pacing")
	var malformed = {"random_encounter_multiplier":-0.1,"encounter_grace_steps":1.5}
	check(EncounterValidation.dungeon_errors("bad",malformed,GameData.ENEMIES).size() == 2, "bad pacing configuration is reported")
	check(EncounterValidation.all_errors().is_empty(), "authored encounter configuration validates")
	game.queue_free()
	if failures.is_empty():
		print("PASS imported pacing probability, entry/battle grace, quiet/fixed priority, and saves")
		quit(0)
	else:
		for label in failures: push_error(label)
		quit(1)
