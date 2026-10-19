class_name SaveGame
extends RefCounted

# Variant decoding forbids objects; saves contain only dictionaries, arrays,
# scalar values, and Vector2i locations. Replace only after a complete write.
static func write(path: String, data: Dictionary) -> bool:
	var file = FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		return false
	file.store_var(data, false)
	file.flush()
	var error = file.get_error()
	file.close()
	if error != OK:
		return false
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(path + ".tmp"), ProjectSettings.globalize_path(path)) == OK

static func read(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() == 0:
		return {}
	var data = file.get_var(false)
	return data if data is Dictionary else {}
