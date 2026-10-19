extends SceneTree
var failures: Array[String] = []
func check(ok: bool, label: String):
	if not ok:
		failures.append(label)
func distance(dungeon, start: Vector2i, goal: Vector2i) -> int:
	var queue: Array = [start]
	var distances: Dictionary = {start:0}
	while not queue.is_empty():
		var position: Vector2i = queue.pop_front()
		if position == goal:
			return distances[position]
		for direction in dungeon.DIRECTIONS:
			var next: Vector2i = position + direction
			if dungeon.can_move_to(next) and not distances.has(next):
				distances[next] = distances[position] + 1
				queue.append(next)
	return -1
func _initialize():
	var dungeon = DungeonSystem.new()
	var keys: Dictionary = {}
	var original_map: Array = dungeon.map.duplicate(true)
	var route_before = distance(dungeon, Vector2i(5,9), Vector2i(7,9))
	check(distance(dungeon, dungeon.player_pos, Vector2i(13,1)) >= 0, "boss remains accessible with locked door and shortcut")
	check(route_before > 2, "cross-passage starts with a real detour")
	check(not dungeon.can_move_to(Vector2i(7,10)) and not dungeon.can_move_to(Vector2i(6,9)), "closed barriers block movement")
	dungeon.player_pos = Vector2i(7,11)
	dungeon.facing = 0
	check(not dungeon.move_forward() and dungeon.player_pos == Vector2i(7,11), "cannot walk through locked door")
	var locked = DungeonInteractions.interact(dungeon, keys)
	check(locked["handled"] and "need" in locked["message"] and dungeon.interaction_states.is_empty(), "missing key leaves door locked")
	check(not DungeonInteractions.interact(dungeon, keys, true)["handled"], "combat cannot interact")
	dungeon.player_pos = Vector2i(2,11)
	dungeon.facing = 0
	var pickup = DungeonInteractions.interact(dungeon, keys)
	check(pickup["handled"] and keys.get("warehouse_brass_key", false), "key can be picked up underfoot")
	check(not DungeonInteractions.interact(dungeon, keys)["handled"], "key cannot be collected repeatedly")
	dungeon.player_pos = Vector2i(7,11)
	check(DungeonInteractions.interact(dungeon, keys)["handled"] and dungeon.can_move_to(Vector2i(7,10)), "correct key opens the door")
	check(keys.get("warehouse_brass_key", false), "key remains reusable")
	check(dungeon.move_forward() and dungeon.get_tile(dungeon.player_pos) == ".", "opened door becomes walkable floor")
	var lever = DungeonInteractions.interact(dungeon, keys)
	check(lever["handled"] and dungeon.can_move_to(Vector2i(6,9)), "facing adjacent lever opens shortcut")
	check(distance(dungeon, Vector2i(5,9), Vector2i(7,9)) == 2, "shortcut removes the detour")
	check(distance(dungeon, Vector2i(5,9), Vector2i(7,9)) < route_before, "shortcut genuinely reduces distance")
	var state_before = dungeon.interaction_states.duplicate(true)
	DungeonInteractions.interact(dungeon, keys)
	check(dungeon.interaction_states == state_before, "lever is idempotent and never recloses passage")
	dungeon.load_dungeon("abandoned_warehouse")
	dungeon.begin_expedition()
	check(dungeon.can_move_to(Vector2i(7,10)) and dungeon.can_move_to(Vector2i(6,9)), "door and shortcut persist across leaving and expeditions")
	check(dungeon.map == original_map, "opening passages never mutates reference map data")
	check(DungeonInteractions.valid_states(dungeon.interaction_states), "interaction state can be serialized")
	check(not DungeonInteractions.valid_states({"bad":{"open":1}}), "non-boolean state rejected")
	check(not DungeonInteractions.valid_states({"bad":{"unknown":true}}), "unknown state flags rejected")
	# Namespacing prevents a different dungeon from borrowing these openings.
	dungeon.load_dungeon("wine_cellar")
	check(dungeon.get_interaction_at(Vector2i(7,10)).is_empty(), "other dungeons do not inherit Warehouse objects")
	if failures.is_empty():
		print("PASS key, locked door, lever, real shortcut, and persistent map overlay")
		quit(0)
	else:
		for failure_text in failures:
			push_error(failure_text)
		quit(1)
