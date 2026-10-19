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
	game.save_path = "/private/tmp/warehouse-interaction-controls.dat"
	game.enter_dungeon("abandoned_warehouse")
	game.dungeon.player_pos = Vector2i(7,11)
	game.dungeon.facing = 0
	key(game, KEY_ENTER)
	check("need" in game.dungeon.message and not game.dungeon.can_move_to(Vector2i(7,10)), "Enter reports locked door without key")
	game.dungeon.player_pos = Vector2i(2,11)
	key(game, KEY_ENTER)
	check(game.has_quest_item("warehouse_brass_key"), "Enter picks up party key")
	game.dungeon.player_pos = Vector2i(7,11)
	key(game, KEY_ENTER)
	check(game.dungeon.can_move_to(Vector2i(7,10)), "Enter opens door using shared keyring")
	game.dungeon.move_forward()
	check(game.dungeon.player_pos == Vector2i(7,10), "player can stand on opened door tile")
	key(game, KEY_F5)
	check(game.save_message == "Game saved.", "save on opened door succeeds")
	game.dungeon.interaction_states.clear()
	game.quest_items.clear()
	key(game, KEY_F9)
	check(game.dungeon.player_pos == Vector2i(7,10) and game.dungeon.can_move_to(Vector2i(7,10)) and game.has_quest_item("warehouse_brass_key"), "load restores overlay before validating position")
	key(game, KEY_ENTER)
	check(game.dungeon.can_move_to(Vector2i(6,9)), "Enter on adjacent lever opens shortcut")
	game.dungeon.player_pos = Vector2i(6,9)
	key(game, KEY_F5)
	var states = game.dungeon.interaction_states.duplicate(true)
	game.dungeon.interaction_states.clear()
	key(game, KEY_F9)
	check(game.dungeon.player_pos == Vector2i(6,9) and game.dungeon.interaction_states == states, "save/load on shortcut retains all interaction states")
	var invalid = game.capture_save()
	invalid["dungeon"]["interaction_states"] = {"bad":{"open":"yes"}}
	check(not game.restore_save(invalid) and game.dungeon.interaction_states == states, "invalid states rejected before live mutation")
	# Old saves omitted this new field and could only stand on original floor.
	var legacy = game.capture_save()
	legacy["dungeon"].erase("interaction_states")
	legacy["dungeon"]["position"] = Vector2i(1,13)
	check(game.restore_save(legacy) and game.dungeon.interaction_states.is_empty(), "older saves remain compatible")
	key(game, KEY_ENTER)
	check(game.rogue_skills_open, "existing Rogue object interaction still works")
	key(game, KEY_ESCAPE)
	game.dungeon.player_pos = Vector2i(5,13)
	key(game, KEY_ENTER)
	check(game.class_skills_open, "existing class skill interaction still works")
	key(game, KEY_ESCAPE)
	game.game_state = game.GameState.COMBAT
	game.dungeon.player_pos = Vector2i(2,11)
	var before = game.dungeon.interaction_states.duplicate(true)
	game.activate_dungeon_transition()
	check(game.dungeon.interaction_states == before, "direct interaction entry is blocked during combat")
	game.queue_free()
	if failures.is_empty():
		print("PASS interaction controls, opened-tile saves, old saves, and skill compatibility")
		quit(0)
	else:
		for failure_text in failures:
			push_error(failure_text)
		quit(1)
