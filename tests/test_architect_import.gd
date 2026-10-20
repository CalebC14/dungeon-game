extends SceneTree
var failures: Array[String] = []
func check(ok: bool, label: String):
	if not ok: failures.append(label)
func fixture() -> Dictionary:
	var floors: Array = []
	for number in [1,2]:
		var tiles: Array = []
		for y in range(3):
			for x in range(5):
				var type = "floor" if y == 1 and x > 0 and x < 4 else "wall"
				var tile = {"x":x,"y":y,"type":type}
				if y == 1 and x == 1 and number == 1: tile["type"] = "entrance"
				if y == 1 and x == 3:
					tile.merge({"type":"stairs","connection_id":"link","destination_floor":3-number,"destination_x":3,"destination_y":1},true)
				tiles.append(tile)
		floors.append({"schema_version":"0.1.0","dungeon_id":"demo","floor_id":"f%d" % number,"floor_number":number,"width":5,"height":3,"tiles":tiles})
	return {"format":"dungeon_architect_project","schema_version":"0.3.0","dungeon_id":"demo","floors":floors,"connections":[{"id":"link","one_way":false,"from":{"floor_id":"f1","x":3,"y":1},"to":{"floor_id":"f2","x":3,"y":1}}]}
func _initialize():
	var input = fixture()
	var original = input.duplicate(true)
	var result = DungeonArchitectImport.convert(input)
	check(result["errors"].is_empty() and result["dungeons"].size() == 2, "valid project converts")
	check(input == original, "conversion does not mutate source")
	var a = result["dungeons"]["architect_demo_f1"]
	var b = result["dungeons"]["architect_demo_f2"]
	check(a["map"][1] == "#...#" and a["start_position"] == Vector2i(1,1) and b["start_position"] == Vector2i(3,1), "geometry and entry inference preserved")
	check(a["transitions"][Vector2i(3,1)]["target_dungeon"] == b["id"] and b["transitions"].size() == 1, "reciprocal links generated")
	check(a["architect_markers"].size() == 2 and a["fixed_encounters"].is_empty() and a["architect_preview_only"], "markers preserved without invented gameplay")
	var bad = fixture()
	bad["schema_version"] = "99"
	check(not DungeonArchitectImport.convert(bad)["errors"].is_empty(), "unsupported version rejected")
	bad = fixture()
	bad["floors"][0]["tiles"][0]["x"] = 0.5
	check(DungeonArchitectImport.convert(bad)["dungeons"].is_empty(), "fractional coordinates reject whole import")
	bad = fixture()
	bad["floors"][0]["tiles"][0] = bad["floors"][0]["tiles"][1].duplicate(true)
	check(not DungeonArchitectImport.convert(bad)["errors"].is_empty(), "duplicate grid tile rejected")
	bad = fixture()
	bad["floors"][0]["tiles"][0]["type"] = "unknown"
	check(not DungeonArchitectImport.convert(bad)["errors"].is_empty(), "unknown tile rejected")
	bad = fixture()
	bad["connections"][0]["to"]["floor_id"] = "missing"
	check(DungeonArchitectImport.convert(bad)["dungeons"].is_empty(), "missing link floor rejected")
	bad = fixture()
	bad["floors"][0]["tiles"][8]["destination_x"] = 2
	check(not DungeonArchitectImport.convert(bad)["errors"].is_empty(), "conflicting tile/project link rejected")
	bad = fixture()
	bad["connections"] = []
	check(not DungeonArchitectImport.convert(bad)["errors"].is_empty(), "orphan stairs rejected")
	bad = fixture()
	bad["floors"][0]["tiles"][7]["type"] = "wall"
	check(DungeonArchitectImport.convert(bad)["dungeons"].is_empty(), "unreachable stairs rejected by layout validator")
	bad = fixture()
	bad["floors"][0]["tiles"][7].merge({"type":"stairs","connection_id":"link","destination_floor":2,"destination_x":3,"destination_y":1},true)
	check(not DungeonArchitectImport.convert(bad)["errors"].is_empty(), "extra stairs cannot borrow another endpoint's link id")
	# JSON parses numeric fields as floats; integral values remain valid.
	result = DungeonArchitectImport.convert(JSON.parse_string(JSON.stringify(fixture())))
	check(result["errors"].is_empty(), "real JSON numeric decoding supported")
	if failures.is_empty():
		print("PASS Architect conversion, links, metadata, malformed data, and layout rejection")
		quit(0)
	else:
		for label in failures: push_error(label)
		quit(1)
