extends SceneTree
const Game = preload("res://game.gd")
var failures: Array[String] = []
func check(ok: bool, label: String):
	if not ok: failures.append(label)
func key(game, code: int, echo_event: bool = false):
	var event = InputEventKey.new()
	event.keycode = code
	event.pressed = true
	event.echo = echo_event
	game._input(event)
func _initialize(): call_deferred("run_checks")
func run_checks():
	var game = Game.new()
	root.add_child(game)
	game.load_test_roster()
	game.enter_dungeon("abandoned_warehouse")
	var d = game.dungeon
	check(not d.is_dark() and not d.visibility_limited() and d.map_tile_visible(Vector2i(13,1)), "ordinary tiles retain normal visibility")
	d.player_pos = Vector2i(8,11)
	d.facing = 0
	check(d.is_dark() and d.visibility_limited(), "dark area limits visibility without lantern")
	check(d.map_tile_visible(d.player_pos) and d.map_tile_visible(Vector2i(9,12)) and not d.map_tile_visible(Vector2i(13,1)), "map limited to immediate neighbors")
	var gold = game.progression.get_party_gold()
	var health = game.party[0]["hp"]
	key(game, KEY_ENTER)
	check("One more" in d.message, "adjacent interactions remain usable in darkness")
	key(game, KEY_L)
	check(d.lantern_on and not d.visibility_limited() and d.map_tile_visible(Vector2i(13,1)), "L restores normal visibility")
	check(game.progression.get_party_gold() == gold and game.party[0]["hp"] == health, "lantern has no resource cost")
	key(game, KEY_L, true)
	check(d.lantern_on, "held key does not repeatedly toggle")
	check(game.restore_save(game.capture_save()) and game.dungeon.lantern_on, "lit lantern saves")
	d = game.dungeon
	key(game, KEY_L)
	check(not d.lantern_on and d.visibility_limited(), "lantern can be extinguished")
	check(game.restore_save(game.capture_save()) and game.dungeon.visibility_limited(), "unlit dark-area save restores")
	d = game.dungeon
	d.player_pos = Vector2i(7,11)
	check(not d.visibility_limited(), "leaving dark zone restores normal visibility")
	d.lantern_on = true
	d.load_dungeon("abandoned_warehouse")
	d.begin_expedition()
	check(d.lantern_on, "lantern persists across expedition")
	var malformed = game.capture_save()
	malformed["dungeon"]["lantern_on"] = "yes"
	check(not game.restore_save(malformed) and d.lantern_on, "invalid lantern state rejected without mutation")
	var legacy = game.capture_save()
	legacy["dungeon"].erase("lantern_on")
	check(game.restore_save(legacy) and not game.dungeon.lantern_on, "older saves default lantern off")
	game.game_state = game.GameState.COMBAT
	key(game, KEY_L)
	check(not game.dungeon.lantern_on, "combat cannot toggle exploration lantern")
	game.queue_free()
	if failures.is_empty():
		print("PASS darkness, visibility, lantern controls, and save compatibility")
		quit(0)
	else:
		for label in failures: push_error(label)
		quit(1)
