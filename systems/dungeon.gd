class_name DungeonSystem
extends RefCounted


const DungeonDataScript = preload(
	"res://data/dungeon_data.gd"
)


var dungeon_id: String = "abandoned_warehouse"
var dungeon_data: Dictionary = {}

var map: Array = []
var fixed_encounters: Dictionary = {}
var transitions: Dictionary = {}

var defeated_fixed_encounters: Dictionary = {}

var player_pos: Vector2i = Vector2i.ZERO
var facing: int = 0


const DIRECTIONS = [
	Vector2i(0, -1),
	Vector2i(1, 0),
	Vector2i(0, 1),
	Vector2i(-1, 0)
]

const DIRECTION_NAMES = [
	"NORTH",
	"EAST",
	"SOUTH",
	"WEST"
]


# ============================================================
# INITIALIZATION
# ============================================================

func _init():

	load_dungeon(
		dungeon_id
	)


# ============================================================
# DUNGEON LOADING
# ============================================================

func load_dungeon(
	new_dungeon_id: String
) -> bool:

	if not DungeonDataScript.DUNGEONS.has(
		new_dungeon_id
	):
		return false

	dungeon_id = new_dungeon_id

	dungeon_data = (
		DungeonDataScript.DUNGEONS[
			dungeon_id
		]
	)

	map = dungeon_data.get(
		"map",
		[]
	)

	fixed_encounters = dungeon_data.get(
		"fixed_encounters",
		{}
	)

	transitions = dungeon_data.get(
		"transitions",
		{}
	)

	reset()

	return true


# ============================================================
# RESET
# ============================================================

func reset() -> void:

	player_pos = dungeon_data.get(
		"start_position",
		Vector2i(1, 1)
	)

	facing = dungeon_data.get(
		"start_facing",
		0
	)


# ============================================================
# MOVEMENT
# ============================================================

func move_forward() -> bool:

	return move_to(
		player_pos
		+ DIRECTIONS[facing]
	)


func move_backward() -> bool:

	return move_to(
		player_pos
		- DIRECTIONS[facing]
	)


func move_to(
	target: Vector2i
) -> bool:

	if not can_move_to(
		target
	):
		return false

	player_pos = target

	return true


func turn_left() -> void:

	facing = (
		facing + 3
	) % 4


func turn_right() -> void:

	facing = (
		facing + 1
	) % 4


# ============================================================
# COLLISION
# ============================================================

func can_move_to(
	pos: Vector2i
) -> bool:

	return (
		is_inside_map(pos)
		and not is_wall(pos)
	)


func is_inside_map(
	pos: Vector2i
) -> bool:

	if pos.y < 0:
		return false

	if pos.y >= map.size():
		return false

	if pos.x < 0:
		return false

	if pos.x >= map[pos.y].length():
		return false

	return true


func is_wall(
	pos: Vector2i
) -> bool:

	if not is_inside_map(
		pos
	):
		return true

	return (
		map[pos.y][pos.x]
		== "#"
	)


func get_tile(
	pos: Vector2i
) -> String:

	if not is_inside_map(
		pos
	):
		return "#"

	return map[pos.y][pos.x]


# ============================================================
# DUNGEON INFORMATION
# ============================================================

func get_dungeon_name() -> String:

	return dungeon_data.get(
		"name",
		"Unknown Dungeon"
	)


func get_facing_name() -> String:

	return DIRECTION_NAMES[
		facing
	]


func get_width() -> int:

	if map.is_empty():
		return 0

	return map[0].length()


func get_height() -> int:

	return map.size()


# ============================================================
# RELATIVE POSITION HELPERS
# ============================================================

func get_forward_direction() -> Vector2i:

	return DIRECTIONS[
		facing
	]


func get_right_direction() -> Vector2i:

	var forward = (
		get_forward_direction()
	)

	return Vector2i(
		-forward.y,
		forward.x
	)


func get_relative_position(
	forward: int,
	sideways: int = 0
) -> Vector2i:

	return (
		player_pos
		+ get_forward_direction()
		* forward
		+ get_right_direction()
		* sideways
	)


# ============================================================
# FIXED ENCOUNTERS
# ============================================================

func get_current_fixed_encounter() -> Dictionary:

	if not fixed_encounters.has(
		player_pos
	):
		return {}

	var encounter: Dictionary = (
		fixed_encounters[
			player_pos
		]
	)

	var encounter_id: String = (
		encounter.get(
			"id",
			""
		)
	)

	if encounter_id == "":
		return encounter

	var encounter_key = (
		dungeon_id
		+ ":"
		+ encounter_id
	)

	if defeated_fixed_encounters.get(
		encounter_key,
		false
	):
		return {}

	return encounter


func mark_current_fixed_encounter_defeated() -> void:

	if not fixed_encounters.has(
		player_pos
	):
		return

	var encounter: Dictionary = (
		fixed_encounters[
			player_pos
		]
	)

	var encounter_id: String = (
		encounter.get(
			"id",
			""
		)
	)

	if encounter_id == "":
		return

	var encounter_key = (
		dungeon_id
		+ ":"
		+ encounter_id
	)

	defeated_fixed_encounters[
		encounter_key
	] = true


func has_fixed_encounter(
	pos: Vector2i
) -> bool:

	if not fixed_encounters.has(
		pos
	):
		return false

	var encounter: Dictionary = (
		fixed_encounters[
			pos
		]
	)

	var encounter_id: String = (
		encounter.get(
			"id",
			""
		)
	)

	if encounter_id == "":
		return true

	var encounter_key = (
		dungeon_id
		+ ":"
		+ encounter_id
	)

	return not defeated_fixed_encounters.get(
		encounter_key,
		false
	)


# ============================================================
# DUNGEON TRANSITIONS
# ============================================================

func get_current_transition() -> Dictionary:

	if not transitions.has(
		player_pos
	):
		return {}

	return transitions[
		player_pos
	]


func has_transition(
	pos: Vector2i
) -> bool:

	return transitions.has(
		pos
	)
