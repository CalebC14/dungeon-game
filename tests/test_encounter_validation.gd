extends SceneTree
var failures: Array[String] = []
func check(ok: bool, label: String):
	if not ok: failures.append(label)
func _initialize():
	var errors = EncounterValidation.all_errors()
	check(errors.is_empty(), "content errors: " + str(errors))
	check(not EncounterValidation.table_errors([],GameData.ENEMIES,"empty").is_empty(), "empty table rejected")
	check(EncounterValidation.table_errors([{"enemy_id":"missing","min_group":0,"max_group":-1,"weight":0}],GameData.ENEMIES,"bad").size() == 3, "enemy reference, group range, and weight rejected")
	check(not EncounterValidation.table_errors(["bad"],GameData.ENEMIES,"bad").is_empty(), "malformed row rejected")
	check(EncounterValidation.reward_errors({"bad":{"xp":-1,"gold_min":9,"gold_max":2}}).size() == 2, "negative XP and inverted gold rejected")
	var data = {"map":["###","#.#","###"], "fixed_encounters":{Vector2i(0,0):{"id":"same","enemy_id":"giant_rat","count":1},Vector2i(1,1):{"id":"same","groups":[]}}}
	check(EncounterValidation.dungeon_errors("fixture",data,GameData.ENEMIES).size() == 3, "wall encounter, duplicate id, and empty mixed group rejected")
	if failures.is_empty():
		print("PASS all encounter/reward data and malformed content validation")
		quit(0)
	else:
		for label in failures: push_error(label)
		quit(1)
