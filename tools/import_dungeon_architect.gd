extends SceneTree
func _initialize():
	var args = OS.get_cmdline_user_args()
	if args.size() < 1 or args.size() > 2:
		print("Usage: Godot --headless --path PROJECT --script res://tools/import_dungeon_architect.gd -- INPUT.json [NEW_OUTPUT_DIRECTORY]")
		quit(1)
		return
	var file = FileAccess.open(args[0],FileAccess.READ)
	if file == null:
		print("ERROR Cannot read input JSON.")
		quit(1)
		return
	var json = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		print("ERROR Invalid JSON at line %d: %s" % [json.get_error_line(),json.get_error_message()])
		quit(1)
		return
	var result = DungeonArchitectImport.convert(json.data)
	for message in result["warnings"]: print("WARNING " + message)
	for message in result["errors"]: print("ERROR " + message)
	if not result["errors"].is_empty():
		print("Import rejected. No output written.")
		quit(1)
		return
	print("Validated %d preview floors." % result["dungeons"].size())
	if args.size() == 1:
		print("Dry run only. Provide a new output directory to write preview scripts.")
		quit(0)
		return
	var output = args[1]
	if DirAccess.dir_exists_absolute(output) or FileAccess.file_exists(output):
		print("ERROR Output already exists; refusing to overwrite.")
		quit(1)
		return
	if DirAccess.make_dir_recursive_absolute(output) != OK:
		print("ERROR Cannot create output directory.")
		quit(1)
		return
	for id in result["dungeons"]:
		var target = FileAccess.open(output.path_join(id + ".gd"),FileAccess.WRITE)
		if target == null:
			print("ERROR Cannot write preview file.")
			quit(1)
			return
		target.store_string("# Generated preview only; not registered as playable content.\nextends RefCounted\n\nconst DATA = " + var_to_str(result["dungeons"][id]) + "\n")
		target.flush()
		if target.get_error() != OK:
			print("ERROR Writing preview failed.")
			quit(1)
			return
	print("Preview scripts written to " + output + ". Existing game catalog unchanged.")
	quit(0)
