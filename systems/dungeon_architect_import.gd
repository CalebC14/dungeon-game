class_name DungeonArchitectImport
extends RefCounted

const TILE_TYPES = ["wall","floor","stairs","entrance","door","secret","boss","treasure","event","trap"]

static func whole(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floor(float(value))

static func identifier(value: Variant) -> bool:
	if not value is String or value.is_empty(): return false
	for character in value:
		if character not in "abcdefghijklmnopqrstuvwxyz0123456789_": return false
	return true

static func convert(project: Variant) -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []
	var catalog: Dictionary = {}
	var result = {"errors":errors,"warnings":warnings,"dungeons":catalog}
	if not project is Dictionary or project.get("format") != "dungeon_architect_project" or project.get("schema_version") != "0.3.0":
		errors.append("Expected Dungeon Architect project schema 0.3.0.")
		return result
	if not identifier(project.get("dungeon_id")) or not project.get("floors") is Array or project["floors"].is_empty():
		errors.append("Project requires a safe dungeon_id and nonempty floors array.")
		return result
	var floors: Dictionary = {}
	var numbers: Dictionary = {}
	var tiles_by_floor: Dictionary = {}
	for source in project["floors"]:
		if not source is Dictionary or source.get("schema_version") != "0.1.0" or not identifier(source.get("floor_id")):
			errors.append("Floor requires schema 0.1.0 and a safe floor_id.")
			continue
		var id: String = source["floor_id"]
		if floors.has(id) or not whole(source.get("floor_number")) or source["floor_number"] < 1 or numbers.has(int(source["floor_number"])):
			errors.append(id + ": duplicate floor id/number or invalid floor number.")
			continue
		if source.get("dungeon_id") != project["dungeon_id"]:
			errors.append(id + ": dungeon_id differs from project.")
			continue
		if not whole(source.get("width")) or not whole(source.get("height")) or source["width"] < 1 or source["height"] < 1 or source["width"] > 256 or source["height"] > 256 or not source.get("tiles") is Array:
			errors.append(id + ": invalid dimensions or tiles.")
			continue
		var width = int(source["width"])
		var height = int(source["height"])
		var tiles: Dictionary = {}
		var rows: Array = []
		for y in range(height): rows.append("#".repeat(width))
		var markers: Dictionary = {}
		var entrances: Array = []
		for tile in source["tiles"]:
			if not tile is Dictionary or not whole(tile.get("x")) or not whole(tile.get("y")) or tile.get("type") not in TILE_TYPES:
				errors.append(id + ": invalid coordinate or unsupported tile type.")
				continue
			var position = Vector2i(int(tile["x"]),int(tile["y"]))
			if position.x < 0 or position.x >= width or position.y < 0 or position.y >= height or tiles.has(position):
				errors.append(id + ": duplicate/out-of-bounds tile " + str(position))
				continue
			tiles[position] = tile
			if tile["type"] != "wall": rows[position.y][position.x] = "."
			if tile["type"] == "entrance": entrances.append(position)
			if tile["type"] not in ["wall","floor"]: markers[position] = tile.duplicate(true)
		if tiles.size() != width * height: errors.append(id + ": incomplete tile grid.")
		if entrances.size() > 1: errors.append(id + ": multiple entrances need an explicit entry policy.")
		var key = "architect_" + project["dungeon_id"] + "_" + id
		catalog[key] = {"id":key,"name":str(source.get("name",id)),"map":rows,"start_facing":0,"transitions":{},"fixed_encounters":{},"architect_markers":markers,"architect_notes":str(source.get("notes","")),"architect_preview_only":true}
		if entrances.size() == 1: catalog[key]["start_position"] = entrances[0]
		floors[id] = key
		numbers[int(source["floor_number"])] = id
		tiles_by_floor[id] = tiles
	if not errors.is_empty():
		catalog.clear()
		return result
	if not project.get("connections") is Array:
		errors.append("Project connections must be an array.")
		catalog.clear()
		return result
	var connection_ids: Dictionary = {}
	var connected_tiles: Dictionary = {}
	for link in project["connections"]:
		if not link is Dictionary or not identifier(link.get("id")) or connection_ids.has(link.get("id")) or not link.get("one_way",false) is bool:
			errors.append("Invalid or duplicate connection id/one_way flag.")
			continue
		connection_ids[link["id"]] = true
		var endpoints: Array = []
		for side in ["from","to"]:
			var endpoint = link.get(side)
			if not endpoint is Dictionary or not floors.has(endpoint.get("floor_id")) or not whole(endpoint.get("x")) or not whole(endpoint.get("y")):
				errors.append(str(link["id"]) + ": invalid endpoint.")
				continue
			var floor_id: String = endpoint["floor_id"]
			var position = Vector2i(int(endpoint["x"]),int(endpoint["y"]))
			var tile: Dictionary = tiles_by_floor[floor_id].get(position,{})
			if tile.get("type") != "stairs" or tile.get("connection_id") != link["id"]:
				errors.append(str(link["id"]) + ": endpoint must match a stairs marker.")
				continue
			connected_tiles[floors[floor_id] + str(position)] = true
			endpoints.append({"id":floors[floor_id],"position":position,"tile":tile})
		if endpoints.size() != 2: continue
		for index in range(2):
			var origin: Dictionary = endpoints[index]
			var target: Dictionary = endpoints[1-index]
			var tile: Dictionary = origin["tile"]
			var target_floor = str(project["dungeon_id"]) # Floor number checked through numbers below.
			if not whole(tile.get("destination_floor")) or not numbers.has(int(tile["destination_floor"])):
				errors.append(str(link["id"]) + ": stairs destination floor missing.")
				continue
			target_floor = floors[numbers[int(tile["destination_floor"])]]
			if target_floor != target["id"] or not whole(tile.get("destination_x")) or not whole(tile.get("destination_y")) or Vector2i(int(tile["destination_x"]),int(tile["destination_y"])) != target["position"]:
				errors.append(str(link["id"]) + ": stairs marker disagrees with project connection.")
				continue
			if index == 1 and bool(link.get("one_way",false)): continue
			var dungeon: Dictionary = catalog[origin["id"]]
			if dungeon["transitions"].has(origin["position"]):
				errors.append(str(link["id"]) + ": overlapping stair links.")
				continue
			dungeon["transitions"][origin["position"]] = {"target_dungeon":target["id"],"target_position":target["position"],"requires_interact":true}
	# Floors without an entrance arrive from the preceding numbered floor.
	for number in numbers:
		var id: String = numbers[number]
		var dungeon: Dictionary = catalog[floors[id]]
		if not dungeon.has("start_position"):
			var candidates: Array = []
			for position in tiles_by_floor[id]:
				var tile: Dictionary = tiles_by_floor[id][position]
				if tile["type"] == "stairs" and whole(tile.get("destination_floor")) and int(tile["destination_floor"]) == number - 1:
					candidates.append(position)
			if candidates.size() != 1: errors.append(id + ": cannot infer a unique entry from the preceding floor.")
			else: dungeon["start_position"] = candidates[0]
		for position in tiles_by_floor[id]:
			var tile: Dictionary = tiles_by_floor[id][position]
			if tile["type"] == "stairs" and not connected_tiles.has(floors[id] + str(position)):
				errors.append(id + ": orphan stairs marker " + str(position))
		warnings.append(id + ": gameplay markers preserved as annotations only; doors/secrets are preview floor, with no rewards, enemies, traps, or boss gates activated.")
	if errors.is_empty():
		for id in catalog:
			var report = DungeonLayoutValidation.inspect(id,catalog[id],catalog)
			errors.append_array(report["errors"])
			warnings.append_array(report["warnings"])
	if not errors.is_empty(): catalog.clear()
	return result
