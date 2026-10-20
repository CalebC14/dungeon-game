extends SceneTree
var failures: Array[String] = []
func check(ok: bool, label: String):
	if not ok: failures.append(label)
func fixture() -> Dictionary:
	return {"map":["#####","#...#","#####"],"start_position":Vector2i(1,1),"start_facing":0}
func report(data: Dictionary, catalog: Dictionary = {}) -> Dictionary:
	return DungeonLayoutValidation.inspect("fixture",data,catalog)
func _initialize():
	var base = fixture()
	check(report(base)["errors"].is_empty(), "simple connected layout passes")
	for map in [[],["###","#.#","##"],["###",42],["###","#x#","###"]]:
		var bad = fixture()
		bad["map"] = map
		check(not report(bad)["errors"].is_empty(), "bad map shape or tiles rejected: " + str(map))
	var bad = fixture()
	bad["start_position"] = Vector2i(0,0)
	bad["start_facing"] = 4
	check(report(bad)["errors"].size() == 2, "wall start and invalid facing rejected")
	bad = fixture()
	bad["events"] = {Vector2i(0,0):{},Vector2i(-1,1):{}}
	check(report(bad)["errors"].size() == 2, "wall event and out-of-bounds point rejected")
	bad = fixture()
	bad["transitions"] = {Vector2i(3,1):{"target_dungeon":"missing"}}
	check(report(bad)["errors"].size() == 1, "missing destination rejected")
	bad["transitions"][Vector2i(3,1)] = {"target_dungeon":"next","target_position":Vector2i(0,0),"target_facing":-1}
	check(report(bad,{"next":fixture()})["errors"].size() == 2, "bad landing and facing rejected")
	bad["transitions"][Vector2i(3,1)] = {"target_dungeon":"next"}
	check(report(bad,{"next":fixture()})["errors"].is_empty(), "destination defaults use dungeon start")
	bad["transitions"][Vector2i(3,1)] = {"to_city":true}
	check(report(bad)["errors"].is_empty(), "city exit does not need dungeon destination")
	var gated = fixture()
	gated["interactions"] = {Vector2i(2,1):{"id":"gate","type":"locked_door"}}
	gated["fixed_encounters"] = {Vector2i(3,1):{}}
	var result = report(gated)
	check(result["errors"].is_empty() and result["warnings"].size() == 1, "barrier-dependent encounter gets warning rather than impossible-route error")
	check(not DungeonLayoutValidation.reachable(gated).has(Vector2i(3,1)) and DungeonLayoutValidation.reachable(gated,true).has(Vector2i(3,1)), "closed and optimistic open floods differ")
	var isolated = {"map":["#######","#.#...#","#######"],"start_position":Vector2i(1,1),"events":{Vector2i(5,1):{}}}
	result = report(isolated)
	check(result["errors"].size() == 1 and result["warnings"].size() == 1, "stranded content errors while isolated floor warns")
	var adjacent = fixture()
	adjacent["interactions"] = {Vector2i(1,0):{"id":"wall_object","type":"lever"}}
	check(report(adjacent)["errors"].is_empty(), "wall interaction can be operated from adjacent floor")
	var reports = DungeonLayoutValidation.all_reports()
	for id in reports:
		check(reports[id]["errors"].is_empty(), "current dungeon errors " + str(id) + ": " + str(reports[id]["errors"]))
	if failures.is_empty():
		print("PASS reusable layout validation, malformed fixtures, barriers, and current dungeons")
		quit(0)
	else:
		for label in failures: push_error(label)
		quit(1)
