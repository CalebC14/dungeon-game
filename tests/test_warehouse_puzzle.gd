extends SceneTree
const Game = preload("res://game.gd")
var failures: Array[String] = []
func check(ok: bool, label: String):
	if not ok: failures.append(label)
func press(game, x: int):
	game.dungeon.player_pos = Vector2i(x,11)
	game.dungeon.facing = 0
	var event = InputEventKey.new()
	event.keycode = KEY_ENTER
	event.pressed = true
	game._input(event)
func _initialize(): call_deferred("run_checks")
func run_checks():
	var game = Game.new()
	root.add_child(game)
	game.load_test_roster()
	game.enter_dungeon("abandoned_warehouse")
	var d = game.dungeon
	var gate = Vector2i(9,12)
	var gold = game.progression.get_party_gold()
	check(not d.can_move_to(gate), "gate starts closed")
	d.player_pos = Vector2i(8,11)
	d.facing = 0
	check("Sun before Moon" in DungeonInteractions.describe(d, {}), "clue available on switch")
	check(not DungeonInteractions.interact(d, {}, true)["handled"] and d.interaction_states.is_empty(), "combat cannot press switches")
	press(game, 10)
	check(not d.can_move_to(gate) and "reset" in d.message, "Moon first resets without opening")
	press(game, 8)
	check(not d.can_move_to(gate) and "One more" in d.message, "Sun starts sequence")
	press(game, 8)
	press(game, 10)
	check(not d.can_move_to(gate), "repeated Sun resets sequence")
	press(game, 8)
	check(game.restore_save(game.capture_save()), "partial puzzle saves")
	d = game.dungeon
	press(game, 10)
	check(d.can_move_to(gate) and "Puzzle solved" in d.message, "restored partial progress completes puzzle")
	check(d.map[12][9] == "#" and d.get_tile(gate) == ".", "overlay opens actual wall without map mutation")
	var states = d.interaction_states.duplicate(true)
	press(game, 8)
	press(game, 10)
	check(states == d.interaction_states and game.progression.get_party_gold() == gold, "solved puzzle is idempotent with no gold payout")
	d.player_pos = Vector2i(9,13)
	d.facing = 0
	check(d.move_forward() and d.player_pos == gate, "opened gate traversable from south")
	check(game.restore_save(game.capture_save()) and game.dungeon.player_pos == gate, "save on open gate restores")
	d = game.dungeon
	d.load_dungeon("abandoned_warehouse")
	d.begin_expedition()
	check(d.can_move_to(gate), "gate survives re-entry and expedition")
	check(not DungeonInteractions.valid_states({"bad":{"primed":1}}), "malformed puzzle state rejected")
	# Broken connections must not consume progress or open an unrelated barrier.
	d.dungeon_data = d.dungeon_data.duplicate(true)
	d.dungeon_data["interactions"][Vector2i(8,11)]["puzzle_id"] = "missing"
	states = d.interaction_states.duplicate(true)
	press(game, 8)
	check(d.interaction_states == states and "not connected" in d.message, "broken puzzle data cannot mutate state")
	game.queue_free()
	if failures.is_empty():
		print("PASS Warehouse puzzle order, retry, passage, persistence, and validation")
		quit(0)
	else:
		for label in failures: push_error(label)
		quit(1)
