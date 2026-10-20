extends SceneTree
const Game = preload("res://game.gd")
var failures: Array[String] = []
func check(ok: bool, label: String):
	if not ok: failures.append(label)
func reachable(d: DungeonSystem) -> Dictionary:
	var visited = {d.player_pos:true}
	var pending = [d.player_pos]
	var cursor = 0
	while cursor < pending.size():
		var position = pending[cursor]
		cursor += 1
		for direction in DungeonSystem.DIRECTIONS:
			var next = position + direction
			if d.can_move_to(next) and not visited.has(next):
				visited[next] = true
				pending.append(next)
	return visited
func _initialize(): call_deferred("run_checks")
func run_checks():
	var game = Game.new()
	root.add_child(game)
	game.load_test_roster()
	game.enter_dungeon("abandoned_warehouse")
	game.encounter_chance = 1.0
	var d = game.dungeon
	var seen = reachable(d)
	check(seen.has(Vector2i(13,1)), "boss reachable with all mechanisms closed")
	check(d.can_move_to(Vector2i(3,12)) and seen.has(Vector2i(3,11)), "new loading aisle connector opens a loop")
	for section in ["rogue_objects","exploration_objects","interactions"]:
		for position in d.dungeon_data.get(section, {}):
			var accessible = seen.has(position)
			for direction in DungeonSystem.DIRECTIONS:
				accessible = accessible or seen.has(position + direction)
			check(accessible, "test object accessible: " + str(position))
	for position in [Vector2i(1,13),Vector2i(3,12),Vector2i(8,11),Vector2i(7,10),Vector2i(7,9)]:
		d.player_pos = position
		game.check_for_encounter()
		check(d.is_quiet_area() and game.game_state == game.GameState.DUNGEON, "quiet tile suppresses guaranteed random encounter " + str(position))
	d.player_pos = Vector2i(13,9)
	game.check_for_encounter()
	check(not d.is_quiet_area() and game.game_state == game.GameState.COMBAT, "deeper area retains random battles")
	game.game_state = game.GameState.DUNGEON
	d.player_pos = Vector2i(1,12)
	game.check_dungeon_tile()
	check("Loading aisles" in d.message and d.get_current_event().is_empty(), "entrance notice displays and consumes once")
	d.player_pos = Vector2i(13,10)
	game.check_dungeon_tile()
	check("Rat tracks" in d.message and game.game_state == game.GameState.DUNGEON, "warning gives one calm step before patrol area")
	d.player_pos = Vector2i(4,11)
	var hp = game.party[0]["hp"]
	game.check_dungeon_tile()
	check(game.party[0]["hp"] == hp - 4, "quiet aisles do not disable traps")
	# Fixed encounters take precedence even on a quiet tile.
	d.fixed_encounters = {Vector2i(2,13):{"id":"quiet_fixture","enemy_id":"giant_rat","count":1}}
	d.player_pos = Vector2i(2,13)
	game.check_dungeon_tile()
	check(game.game_state == game.GameState.COMBAT, "quiet area does not suppress fixed encounters")
	game.game_state = game.GameState.DUNGEON
	d.player_pos = Vector2i(1,12)
	check(game.restore_save(game.capture_save()) and game.dungeon.get_current_event().is_empty(), "notice consumption persists")
	game.dungeon.load_dungeon("wine_cellar")
	check(not game.dungeon.is_quiet_area(), "other dungeons retain existing pacing")
	game.queue_free()
	if failures.is_empty():
		print("PASS Warehouse connectivity, quiet aisles, warnings, traps, and encounters")
		quit(0)
	else:
		for label in failures: push_error(label)
		quit(1)
