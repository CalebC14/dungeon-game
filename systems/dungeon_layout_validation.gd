class_name DungeonLayoutValidation
extends RefCounted

static func inside(map: Array, position: Variant) -> bool:
	return position is Vector2i and position.y >= 0 and position.y < map.size() and position.x >= 0 and position.x < map[position.y].length()

static func walkable(data: Dictionary, position: Vector2i, open_barriers: bool) -> bool:
	var map: Array = data.get("map", [])
	if not inside(map, position): return false
	var object: Dictionary = data.get("interactions", {}).get(position, {})
	if DungeonInteractions.is_barrier(object): return open_barriers
	return map[position.y][position.x] == "."

static func reachable(data: Dictionary, open_barriers: bool = false) -> Dictionary:
	var seen: Dictionary = {}
	var start = data.get("start_position")
	if not start is Vector2i or not walkable(data, start, open_barriers): return seen
	var queue = [start]
	seen[start] = true
	var cursor = 0
	while cursor < queue.size():
		var position = queue[cursor]
		cursor += 1
		for direction in DungeonSystem.DIRECTIONS:
			var next = position + direction
			if not seen.has(next) and walkable(data, next, open_barriers):
				seen[next] = true
				queue.append(next)
	return seen

static func accessible(seen: Dictionary, position: Vector2i, adjacent: bool) -> bool:
	if seen.has(position): return true
	if adjacent:
		for direction in DungeonSystem.DIRECTIONS:
			if seen.has(position + direction): return true
	return false

static func inspect(id: String, data: Dictionary, catalog: Dictionary) -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []
	var result = {"errors":errors, "warnings":warnings}
	var map = data.get("map")
	if not map is Array or map.is_empty():
		errors.append(id + ": map must be a nonempty array")
		return result
	var width = -1
	for row in map:
		if not row is String or row.is_empty():
			errors.append(id + ": map rows must be nonempty strings")
			return result
		if width == -1: width = row.length()
		if row.length() != width:
			errors.append(id + ": map must be rectangular")
			return result
		for tile in row:
			if tile not in ["#", "."]:
				errors.append(id + ": unsupported map tile " + tile)
				return result
	var start = data.get("start_position")
	if not start is Vector2i or not walkable(data, start, false):
		errors.append(id + ": start must be on initially walkable floor")
	var facing = data.get("start_facing", 0)
	if not facing is int or facing < 0 or facing > 3: errors.append(id + ": invalid start facing")
	var closed = reachable(data)
	var opened = reachable(data, true)
	for section in ["fixed_encounters", "events", "transitions", "rogue_objects", "exploration_objects", "interactions"]:
		for position in data.get(section, {}):
			var context = id + " " + section + " " + str(position)
			if not inside(map, position):
				errors.append(context + ": position outside map")
				continue
			var adjacent = section == "interactions"
			if not adjacent and not walkable(data, position, true):
				errors.append(context + ": requires walkable floor")
			elif not accessible(opened, position, adjacent):
				errors.append(context + ": unreachable even with barriers open")
			elif not accessible(closed, position, adjacent):
				warnings.append(context + ": requires an opened barrier")
			if section != "transitions": continue
			var transition: Dictionary = data[section][position]
			if transition.get("to_city", false) or transition.get("to_wilderness", false): continue
			var target_id = str(transition.get("target_dungeon", ""))
			if not catalog.has(target_id):
				errors.append(context + ": unknown destination " + target_id)
				continue
			var destination: Dictionary = catalog[target_id]
			# Validate destination map independently before indexing it.
			var target_map = destination.get("map", [])
			var rows_valid = target_map is Array and not target_map.is_empty()
			if rows_valid:
				for row in target_map:
					if not row is String: rows_valid = false
			var landing = transition.get("target_position", destination.get("start_position"))
			if not rows_valid or not landing is Vector2i or not walkable(destination, landing, false):
				errors.append(context + ": destination landing is not initially walkable")
			var target_facing = transition.get("target_facing", destination.get("start_facing", 0))
			if not target_facing is int or target_facing < 0 or target_facing > 3:
				errors.append(context + ": invalid destination facing")
	var isolated = 0
	for y in range(map.size()):
		for x in range(width):
			var position = Vector2i(x,y)
			if walkable(data, position, true) and not opened.has(position): isolated += 1
	if isolated > 0: warnings.append(id + ": %d disconnected floor tiles (may be decorative)" % isolated)
	return result

static func all_reports() -> Dictionary:
	var reports: Dictionary = {}
	for id in DungeonData.DUNGEONS:
		reports[id] = inspect(id, DungeonData.DUNGEONS[id], DungeonData.DUNGEONS)
	return reports
