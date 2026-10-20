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
func seen_floor(d: DungeonSystem) -> Dictionary:
	var queue = [d.player_pos]
	var seen = {d.player_pos:true}
	var cursor = 0
	while cursor < queue.size():
		var position = queue[cursor]
		cursor += 1
		for direction in DungeonSystem.DIRECTIONS:
			var next = position + direction
			if d.can_move_to(next) and not seen.has(next):
				seen[next] = true
				queue.append(next)
	return seen
func run_checks():
	var game = Game.new()
	root.add_child(game)
	game.load_test_roster()
	game.encounter_chance = 0.0
	game.enter_dungeon("architect_test_archives")
	var d = game.dungeon
	d.player_pos = Vector2i(12,2)
	key(game,KEY_ENTER)
	check(d.dungeon_id == "architect_test_catacombs_upper" and d.player_pos == Vector2i(12,16) and d.facing == 0, "Archives descent reaches matched Upper landing")
	check(d.map == preload("res://import_previews/broken_reliquary/architect_broken_reliquary_catacombs_upper.gd").DATA["map"], "imported geometry unchanged")
	var steps = d.exploration_steps
	key(game,KEY_ENTER)
	check(d.dungeon_id == "architect_test_archives" and d.player_pos == Vector2i(12,2) and d.facing == 2, "immediate return is available without auto bounce")
	key(game,KEY_ENTER)
	check(d.dungeon_id == "architect_test_catacombs_upper" and d.exploration_steps == steps, "floor travel preserves cumulative clock without charging movement")
	key(game,KEY_UP)
	check(d.player_pos == Vector2i(12,15) and d.exploration_steps == steps + 1 and "Upper Catacombs test" in d.message, "arrival walk advances clock and shows notice")
	d.player_pos = Vector2i(5,3)
	d.facing = 1
	check(not d.can_move_to(Vector2i(6,3)), "crypt door starts closed")
	key(game,KEY_ENTER)
	check(d.can_move_to(Vector2i(6,3)), "crypt door opens without key or skill")
	key(game,KEY_UP)
	check(d.player_pos == Vector2i(6,3), "opened door can be traversed")
	check(game.restore_save(game.capture_save()), "save on Upper door restores")
	d = game.dungeon
	check(d.can_move_to(Vector2i(6,3)), "opened Upper door persists")
	var gold = game.progression.get_party_gold()
	d.player_pos = Vector2i(22,16)
	d.facing = 0
	key(game,KEY_ENTER)
	key(game,KEY_ENTER)
	check(game.progression.get_party_gold() == gold + 25, "burial cache pays exactly once")
	check(game.restore_save(game.capture_save()), "Upper cache state saves")
	d = game.dungeon
	key(game,KEY_ENTER)
	check(game.progression.get_party_gold() == gold + 25, "saved cache cannot duplicate reward")
	for position in [Vector2i(3,1),Vector2i(20,1)]:
		d.player_pos = position
		check(game.handle_current_dungeon_event() and d.get_current_event().is_empty(), "lore consumed once " + str(position))
	d.player_pos = Vector2i(12,2)
	game.check_dungeon_tile()
	key(game,KEY_ENTER)
	check(d.dungeon_id == "architect_test_catacombs_lower", "Upper stair reaches playable Lower Catacombs")
	key(game,KEY_ENTER)
	check(d.dungeon_id == "architect_test_catacombs_upper" and d.player_pos == Vector2i(12,2), "Lower return reaches matched Upper landing")
	d.player_pos = Vector2i(12,16)
	key(game,KEY_ENTER)
	d.player_pos = Vector2i(12,16)
	key(game,KEY_ENTER)
	check(d.dungeon_id == "architect_test_church_nave", "return chain reaches Nave")
	d.player_pos = Vector2i(12,16)
	key(game,KEY_ENTER)
	check(game.game_state == game.GameState.CITY, "return chain reaches town")
	var layout = DungeonSystem.new()
	layout.load_dungeon("architect_test_catacombs_upper")
	for i in range(4):
		var seen = seen_floor(layout)
		for position in layout.dungeon_data["interactions"]:
			var object = layout.get_interaction_at(position)
			if object.get("type") == "door" and DungeonLayoutValidation.accessible(seen,position,true):
				layout.interaction_states[DungeonInteractions.state_key(layout,object)] = {"open":true}
	var seen = seen_floor(layout)
	for position in [Vector2i(22,16),Vector2i(3,1),Vector2i(20,1),Vector2i(12,2)]:
		check(seen.has(position), "content reachable after opening approachable doors " + str(position))
	check(EncounterValidation.all_errors().is_empty(), "encounter data validates")
	check(DungeonLayoutValidation.inspect(layout.dungeon_id,layout.dungeon_data,DungeonData.DUNGEONS)["errors"].is_empty(), "layout validates")
	check(not DungeonData.DUNGEONS.has("architect_broken_reliquary_black_warlock_chapel"), "generated Chapel preview remains unregistered")
	game.queue_free()
	if failures.is_empty():
		print("PASS imported Upper Catacombs stairs, doors, cache, lore, saves, and return chain")
		quit(0)
	else:
		for label in failures: push_error(label)
		quit(1)
