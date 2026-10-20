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
func _initialize(): call_deferred("run_checks")
func run_checks():
	var game = Game.new()
	root.add_child(game)
	game.load_test_roster()
	game.enter_dungeon("abandoned_warehouse")
	game.encounter_chance = 0.0
	var d = game.dungeon
	check(d.exploration_steps == 0, "new game starts at zero")
	key(game, KEY_UP)
	check(d.player_pos == Vector2i(1,12) and d.exploration_steps == 1, "forward input advances exactly once")
	key(game, KEY_DOWN)
	check(d.player_pos == Vector2i(1,13) and d.exploration_steps == 2, "backward input advances exactly once")
	key(game, KEY_LEFT)
	key(game, KEY_UP)
	check(d.exploration_steps == 2, "turning and wall bump are free")
	d.move_to(d.player_pos)
	check(d.exploration_steps == 2, "same-position move is free")
	key(game, KEY_L)
	key(game, KEY_I)
	key(game, KEY_ESCAPE)
	check(d.exploration_steps == 2, "light toggle and menu browsing are free")
	d.player_pos = Vector2i(5,13)
	d.facing = 0
	key(game, KEY_ENTER)
	check(d.exploration_steps == 2 and d.can_move_to(Vector2i(5,12)), "searching secret wall is free")
	key(game, KEY_UP)
	check(d.exploration_steps == 3, "moving through opened barrier advances once")
	var down = game.party[1]
	CharacterHealth.damage(down,10000)
	var remaining = down["death_rounds_remaining"]
	d.player_pos = Vector2i(3,11)
	d.facing = 1
	key(game, KEY_UP)
	check(d.exploration_steps == 4 and "triggers" in d.message, "trap step advances once")
	check(down["death_rounds_remaining"] == remaining, "exploration does not advance death countdown")
	check(game.restore_save(game.capture_save()) and game.dungeon.exploration_steps == 4, "clock persists in save")
	d = game.dungeon
	d.load_dungeon("wine_cellar")
	d.move_forward()
	check(d.exploration_steps == 4, "unconfigured dungeon does not tick test clock")
	d.load_dungeon("abandoned_warehouse")
	d.begin_expedition()
	check(d.exploration_steps == 4, "re-entry and expedition do not reset cumulative clock")
	var invalid = game.capture_save()
	invalid["dungeon"]["exploration_steps"] = -1
	check(not game.restore_save(invalid) and game.dungeon.exploration_steps == 4, "negative counter rejected atomically")
	invalid["dungeon"]["exploration_steps"] = 1.5
	check(not game.restore_save(invalid), "noninteger counter rejected")
	var legacy = game.capture_save()
	legacy["dungeon"].erase("exploration_steps")
	check(game.restore_save(legacy) and game.dungeon.exploration_steps == 0, "older saves default clock to zero")
	game.queue_free()
	if failures.is_empty():
		print("PASS exploration clock, movement costs, free actions, health, and persistence")
		quit(0)
	else:
		for label in failures: push_error(label)
		quit(1)
