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
func _initialize():
	call_deferred("run_checks")
func run_checks():
	var game = Game.new()
	root.add_child(game)
	game.load_test_roster()
	game.enter_dungeon("abandoned_warehouse")
	var d = game.dungeon
	var tile = Vector2i(5,12)
	var object = d.get_interaction_at(tile)
	d.player_pos = Vector2i(5,13)
	d.facing = 0
	check(d.is_wall(tile) and d.get_tile(tile) == "#" and not d.can_move_to(tile), "undiscovered door is a wall")
	check(not DungeonInteractions.available(d, object) and DungeonInteractions.target(d).is_empty(), "hidden door excluded from map and normal target")
	check("Scrape marks" in DungeonInteractions.describe(d, {}) and "Hidden storage passage" not in DungeonInteractions.describe(d, {}), "clue does not expose door name")
	check(not d.move_forward() and d.message == "A wall blocks the way.", "bumping wall does not reveal door")
	check(not DungeonInteractions.interact(d, {}, true)["handled"] and d.interaction_states.is_empty(), "combat cannot discover door")
	d.facing = 1
	DungeonInteractions.interact(d, {})
	check(d.interaction_states.is_empty(), "search cannot reveal door behind or beside party")
	d.player_pos = Vector2i(5,11)
	d.facing = 2
	var gold = game.progression.get_party_gold()
	key(game, KEY_ENTER)
	check(d.can_move_to(tile) and d.get_tile(tile) == "." and "secret door" in d.message, "Enter discovers from north side")
	check(DungeonInteractions.available(d, object) and DungeonInteractions.is_open(d, object), "discovered door appears on map")
	check(d.map[12][5] == "#", "base map remains unchanged")
	check(game.progression.get_party_gold() == gold and d.rogue_attempts.is_empty(), "discovery spends no gold or skill attempt")
	var states = d.interaction_states.duplicate(true)
	key(game, KEY_ENTER)
	check(states == d.interaction_states and "already open" in d.message, "repeated interaction is harmless")
	check(d.move_forward() and d.player_pos == tile, "can walk onto secret passage")
	var saved = game.capture_save()
	check(game.restore_save(saved) and game.dungeon.player_pos == tile and game.dungeon.can_move_to(tile), "save on discovered door restores overlay before location")
	d = game.dungeon
	d.load_dungeon("abandoned_warehouse")
	d.begin_expedition()
	check(d.can_move_to(tile), "discovery persists through re-entry and expedition")
	d.interaction_states.clear()
	d.player_pos = Vector2i(5,13)
	d.facing = 0
	key(game, KEY_ENTER)
	check(d.can_move_to(tile), "Enter also discovers from south side before optional skill object")
	var legacy = game.capture_save()
	legacy["dungeon"].erase("interaction_states")
	check(game.restore_save(legacy) and not game.dungeon.can_move_to(tile), "older saves leave secret door undiscovered")
	game.queue_free()
	if failures.is_empty():
		print("PASS secret doors, discovery, hidden presentation, passage, and saves")
		quit(0)
	else:
		for label in failures: push_error(label)
		quit(1)
