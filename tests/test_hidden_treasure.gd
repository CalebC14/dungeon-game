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
	var d = game.dungeon
	var tile = Vector2i(6,11)
	var object = d.get_interaction_at(tile)
	d.player_pos = Vector2i(5,11)
	d.facing = 1
	var gold = game.progression.get_party_gold()
	check(d.can_move_to(tile) and d.get_tile(tile) == ".", "cache never blocks floor")
	check(not DungeonInteractions.available(d, object) and DungeonInteractions.target(d).is_empty(), "hidden treasure has no normal target or map marker")
	check("loose floorboard" in DungeonInteractions.describe(d, {}) and "25" not in DungeonInteractions.describe(d, {}), "clue hints without revealing reward")
	check(not DungeonInteractions.interact(d, {}, true)["handled"] and d.interaction_states.is_empty(), "combat cannot collect treasure")
	d.facing = 3
	key(game, KEY_ENTER)
	check(game.progression.get_party_gold() == gold and d.interaction_states.is_empty(), "cannot search distant or behind cache")
	d.facing = 1
	key(game, KEY_ENTER)
	check(game.progression.get_party_gold() == gold + 25 and "+25 gold" in d.message, "Enter search pays gold through game controller")
	check(d.rogue_attempts.is_empty() and game.quest_items.is_empty(), "no skill attempt or quest item required")
	var states = d.interaction_states.duplicate(true)
	key(game, KEY_ENTER)
	check(game.progression.get_party_gold() == gold + 25 and states == d.interaction_states and "empty" in d.message, "repeat search cannot farm gold")
	check(not DungeonInteractions.available(d, object), "collected cache remains unmarked")
	var saved = game.capture_save()
	check(game.restore_save(saved), "collected cache save restores")
	d = game.dungeon
	key(game, KEY_ENTER)
	check(game.progression.get_party_gold() == gold + 25, "save restore prevents duplicate payout")
	d.load_dungeon("abandoned_warehouse")
	d.begin_expedition()
	d.player_pos = tile
	d.facing = 0
	key(game, KEY_ENTER)
	check(game.progression.get_party_gold() == gold + 25, "re-entry expedition and underfoot search cannot farm reward")
	# Fresh state can also be searched from underfoot, without a Rogue.
	d.interaction_states.clear()
	game.party[2]["class"] = "Warrior"
	key(game, KEY_ENTER)
	check(game.progression.get_party_gold() == gold + 50, "any party can search underfoot")
	var legacy = game.capture_save()
	legacy["dungeon"].erase("interaction_states")
	check(game.restore_save(legacy) and game.dungeon.interaction_states.is_empty(), "old saves without cache state remain valid")
	game.queue_free()
	if failures.is_empty():
		print("PASS hidden treasure search, one-time gold, targeting, and persistence")
		quit(0)
	else:
		for label in failures: push_error(label)
		quit(1)
