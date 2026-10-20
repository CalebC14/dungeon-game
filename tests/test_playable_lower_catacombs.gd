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
	game.enter_dungeon("architect_test_catacombs_upper")
	var d = game.dungeon
	d.player_pos = Vector2i(12,2)
	key(game,KEY_ENTER)
	check(d.dungeon_id == "architect_test_catacombs_lower" and d.player_pos == Vector2i(12,16) and d.facing == 0, "Upper descent reaches matched Lower landing")
	check(d.map == preload("res://import_previews/broken_reliquary/architect_broken_reliquary_catacombs_lower.gd").DATA["map"], "Lower imported geometry unchanged")
	var steps = d.exploration_steps
	key(game,KEY_ENTER)
	check(d.dungeon_id == "architect_test_catacombs_upper" and d.player_pos == Vector2i(12,2) and d.facing == 2, "immediate return is available without auto bounce")
	key(game,KEY_ENTER)
	check(d.dungeon_id == "architect_test_catacombs_lower" and d.exploration_steps == steps, "floor travel is free and preserves shared clock")
	key(game,KEY_UP)
	check(d.player_pos == Vector2i(12,15) and d.exploration_steps == steps + 1 and "Lower Catacombs test" in d.message, "arrival walk shows notice and advances clock")
	d.player_pos = Vector2i(4,3)
	d.facing = 3
	check(not d.can_move_to(Vector2i(3,3)), "ossuary door starts closed")
	key(game,KEY_ENTER)
	check(d.can_move_to(Vector2i(3,3)), "keyless door opens")
	var states = d.interaction_states.duplicate(true)
	key(game,KEY_ENTER)
	check(states == d.interaction_states, "repeat door opening is harmless")
	key(game,KEY_UP)
	check(d.player_pos == Vector2i(3,3), "opened door can be traversed")
	check(game.restore_save(game.capture_save()), "save on Lower door restores")
	d = game.dungeon
	check(d.can_move_to(Vector2i(3,3)), "opened Lower door persists")
	var gold = game.progression.get_party_gold()
	d.player_pos = Vector2i(18,16)
	d.facing = 0
	key(game,KEY_ENTER)
	key(game,KEY_ENTER)
	check(game.progression.get_party_gold() == gold + 25, "ossuary cache pays once")
	check(game.restore_save(game.capture_save()), "Lower cache state saves")
	d = game.dungeon
	key(game,KEY_ENTER)
	check(game.progression.get_party_gold() == gold + 25, "saved cache cannot repeat reward")
	for position in [Vector2i(2,2),Vector2i(21,11)]:
		d.player_pos = position
		check(game.handle_current_dungeon_event() and d.get_current_event().is_empty(), "lore consumed once " + str(position))
	d.player_pos = Vector2i(22,2)
	game.check_dungeon_tile()
	key(game,KEY_ENTER)
	check(d.dungeon_id == "architect_test_catacombs_lower" and "not playable" in d.message and d.get_current_transition().is_empty(), "Chapel remains closed")
	for id in ["architect_test_catacombs_upper","architect_test_archives","architect_test_church_nave"]:
		d.player_pos = Vector2i(12,16)
		key(game,KEY_ENTER)
		check(d.dungeon_id == id, "return chain reaches " + id)
	d.player_pos = Vector2i(12,16)
	key(game,KEY_ENTER)
	check(game.game_state == game.GameState.CITY, "return chain reaches town")
	game.enter_dungeon("architect_test_catacombs_lower")
	check(d.can_move_to(Vector2i(3,3)), "door survives re-entry")
	d.player_pos = Vector2i(18,16)
	d.facing = 0
	key(game,KEY_ENTER)
	check(game.progression.get_party_gold() == gold + 25, "cache survives re-entry")
	var layout = DungeonSystem.new()
	layout.load_dungeon("architect_test_catacombs_lower")
	for iteration in range(7):
		var seen = seen_floor(layout)
		for position in layout.dungeon_data["interactions"]:
			var object = layout.get_interaction_at(position)
			if object.get("type") == "door" and DungeonLayoutValidation.accessible(seen,position,true):
				layout.interaction_states[DungeonInteractions.state_key(layout,object)] = {"open":true}
	var seen = seen_floor(layout)
	for position in [Vector2i(18,16),Vector2i(2,2),Vector2i(21,11),Vector2i(22,2)]:
		check(seen.has(position), "content accessible after opening approachable doors " + str(position))
	check(EncounterValidation.all_errors().is_empty(), "encounter data validates")
	check(DungeonLayoutValidation.inspect(layout.dungeon_id,layout.dungeon_data,DungeonData.DUNGEONS)["errors"].is_empty(), "Lower layout validates")
	check(not DungeonData.DUNGEONS.has("architect_test_black_warlock_chapel"), "unfinished Chapel not registered")
	game.queue_free()
	if failures.is_empty():
		print("PASS imported Lower Catacombs stairs, doors, cache, lore, saves, and return chain")
		quit(0)
	else:
		for label in failures: push_error(label)
		quit(1)
