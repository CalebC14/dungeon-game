extends SceneTree
func _initialize():
	var errors = 0
	var warnings = 0
	var reports = DungeonLayoutValidation.all_reports()
	for id in reports:
		for message in reports[id]["errors"]:
			print("ERROR " + message)
			errors += 1
		for message in reports[id]["warnings"]:
			print("WARNING " + message)
			warnings += 1
	print("Layout validation: %d dungeons, %d errors, %d warnings." % [reports.size(),errors,warnings])
	quit(1 if errors > 0 else 0)
