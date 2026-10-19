extends SceneTree
const Game = preload("res://game.gd")
var failures: Array[String] = []
func check(ok: bool, label: String):
	if not ok: failures.append(label)
func _initialize():
	call_deferred("run_checks")
func step(game, action: String):
	var event = InputEventKey.new()
	event.keycode = KEY_UP if action == "ui_up" else KEY_DOWN
	event.pressed = true
	game.handle_dungeon_input(event)
func run_checks():
	var game = Game.new()
	root.add_child(game)
	game.load_test_roster()
	game.enter_dungeon("abandoned_warehouse")
	var d = game.dungeon
	var lead = game.party[0]
	var rogue = game.party[2]
	var hp = lead["hp"]
	d.player_pos = Vector2i(3,11)
	d.facing = 1
	check(d.get_skill_target().get("skill") == "disarm_trap", "facing trap offers disarm")
	step(game, "ui_up")
	check(d.player_pos == Vector2i(4,11) and lead["hp"] == hp - 4 and "triggers" in d.message, "forward movement triggers trap with feedback")
	DungeonInteractions.trigger_trap(d, d.get_interaction_at(d.player_pos), lead)
	check(lead["hp"] == hp - 4, "spent trap cannot deal damage twice")
	var saved = game.capture_save()
	check(game.restore_save(saved), "spent state save restores")
	d = game.dungeon
	check(not DungeonInteractions.trap_active(d, d.get_interaction_at(Vector2i(4,11))), "spent trap persists")
	d.interaction_states.clear()
	d.rogue_attempts.clear()
	d.player_pos = Vector2i(3,11)
	d.facing = 1
	rogue = game.party[2]
	var result = ExplorationSkills.attempt(game.party_system, d, rogue, "disarm_trap", false, 70)
	check(result["success"] and result["gold"] == 0, "successful disarm grants no reward")
	check(not DungeonInteractions.trap_active(d, d.get_interaction_at(Vector2i(4,11))), "successful disarm makes floor safe")
	check(game.restore_save(game.capture_save()), "disarmed state saves")
	d = game.dungeon
	rogue = game.party[2]
	check(not ExplorationSkills.attempt(game.party_system, d, rogue, "disarm_trap", false, 1)["attempted"], "safe trap cannot consume another attempt")
	d.interaction_states.clear()
	d.rogue_attempts.clear()
	rogue["hp"] = 1
	result = ExplorationSkills.attempt(game.party_system, d, rogue, "disarm_trap", false, 71)
	check(not result["success"] and rogue["hp"] == 0 and rogue["death_rounds_remaining"] == 3, "failed disarm triggers on Rogue without advancing death timer")
	check(not DungeonInteractions.trap_active(d, d.get_interaction_at(Vector2i(4,11))), "failed disarm expends trap")
	d.interaction_states.clear()
	d.player_pos = Vector2i(5,11)
	d.facing = 1
	lead = game.party[0]
	lead["hp"] = 0
	var next = game.party[1]
	hp = next["hp"]
	step(game, "ui_down")
	check(d.player_pos == Vector2i(4,11) and next["hp"] == hp - 4 and lead["hp"] == 0, "backward movement targets first conscious member")
	d.interaction_states.clear()
	for member in game.party: member["hp"] = 0
	game.party[1]["hp"] = 1
	game.check_dungeon_tile()
	check(game.game_state == game.GameState.COMBAT_RESULT and game.combat.party_defeated(game.party), "trap party defeat enters reload flow")
	check(not DungeonInteractions.valid_states({"trap":{"triggered":"yes"}}), "malformed trap flags rejected")
	game.queue_free()
	if failures.is_empty():
		print("PASS floor traps, movement, disarm, persistence, and defeat")
		quit(0)
	else:
		for label in failures: push_error(label)
		quit(1)
