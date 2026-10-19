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
	game.enter_dungeon("abandoned_warehouse")
	var rogue = game.party[2]
	var model = game.party_system
	var dungeon = game.dungeon
	dungeon.player_pos = Vector2i(7,11)
	dungeon.facing = 2
	check(not ExplorationSkills.attempt(model, dungeon, rogue, "pick_lock", false, 1)["attempted"], "cannot pick a door behind the party")
	dungeon.facing = 0
	key(game, KEY_R)
	check(game.rogue_skills_open and dungeon.get_skill_target().get("id") == "warehouse_store_door", "Rogue menu targets real door ahead")
	key(game, KEY_ESCAPE)
	var hp = rogue["hp"]
	var failed = ExplorationSkills.attempt(model, dungeon, rogue, "pick_lock", false, 71)
	check(failed["attempted"] and not failed["success"] and rogue["hp"] == hp and not dungeon.can_move_to(Vector2i(7,10)), "failure leaves door shut without damage")
	check(not ExplorationSkills.attempt(model, dungeon, rogue, "pick_lock", false, 1)["attempted"], "failed Rogue cannot retry")
	var saved = game.capture_save()
	check(game.restore_save(saved), "failed attempt save restores")
	model = game.party_system
	dungeon = game.dungeon
	rogue = game.party[2]
	check(not ExplorationSkills.attempt(model, dungeon, rogue, "pick_lock", false, 1)["attempted"], "failed attempt persists")
	var keys = {"warehouse_brass_key":true}
	DungeonInteractions.interact(dungeon, keys)
	check(dungeon.can_move_to(Vector2i(7,10)), "key still opens after failed pick")
	var records = dungeon.rogue_attempts.duplicate(true)
	check(not ExplorationSkills.attempt(model, dungeon, rogue, "pick_lock", false, 1)["attempted"] and records == dungeon.rogue_attempts, "open door spends no attempt")
	dungeon.interaction_states.clear()
	dungeon.rogue_attempts.clear()
	dungeon.dungeon_data = dungeon.dungeon_data.duplicate(true)
	var door = dungeon.get_interaction_at(Vector2i(7,10))
	door["pickable"] = false
	check(not ExplorationSkills.attempt(model, dungeon, rogue, "pick_lock", false, 1)["attempted"], "doors must explicitly allow picking")
	door["pickable"] = true
	var success = ExplorationSkills.attempt(model, dungeon, rogue, "pick_lock", false, 70)
	check(success["success"] and success["gold"] == 0 and dungeon.can_move_to(Vector2i(7,10)) and game.quest_items.is_empty(), "pick opens door without key or reward")
	dungeon.move_forward()
	saved = game.capture_save()
	check(game.restore_save(saved) and game.dungeon.player_pos == Vector2i(7,10) and game.dungeon.can_move_to(Vector2i(7,10)), "picked door and standing position survive save restore")
	check(not game.dungeon.rogue_attempts.is_empty(), "successful attempt persists")
	game.queue_free()
	if failures.is_empty():
		print("PASS real door picking, failure fallback, targeting, and persistence")
		quit(0)
	else:
		for label in failures:
			push_error(label)
		quit(1)
