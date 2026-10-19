class_name DungeonSystem
extends RefCounted

const DungeonDataScript = preload("res://data/dungeon_data.gd")

var dungeon_id: String = "abandoned_warehouse"
var dungeon_data: Dictionary = {}
var map: Array = []
var fixed_encounters: Dictionary = {}
var transitions: Dictionary = {}
var events: Dictionary = {}

# These survive leaving and returning to a dungeon during the same game.
var defeated_fixed_encounters: Dictionary = {}
var consumed_permanent_events: Dictionary = {}
var rogue_attempts: Dictionary = {}

# These reset when a new dungeon expedition begins.
var consumed_expedition_events: Dictionary = {}

var player_pos: Vector2i = Vector2i.ZERO
var facing: int = 0
var message: String = ""

const DIRECTIONS = [Vector2i(0,-1), Vector2i(1,0), Vector2i(0,1), Vector2i(-1,0)]
const DIRECTION_NAMES = ["NORTH", "EAST", "SOUTH", "WEST"]

func _init():
	load_dungeon(dungeon_id)

func load_dungeon(new_dungeon_id: String) -> bool:
	if not DungeonDataScript.DUNGEONS.has(new_dungeon_id):
		return false
	dungeon_id = new_dungeon_id
	dungeon_data = DungeonDataScript.DUNGEONS[dungeon_id]
	map = dungeon_data.get("map", [])
	fixed_encounters = dungeon_data.get("fixed_encounters", {})
	transitions = dungeon_data.get("transitions", {})
	events = dungeon_data.get("events", {})
	message = ""
	reset()
	return true

func reset() -> void:
	player_pos = dungeon_data.get("start_position", Vector2i(1,1))
	facing = dungeon_data.get("start_facing", 0)

func begin_expedition() -> void:
	consumed_expedition_events.clear()
	message = ""

func move_forward() -> bool:
	return move_to(player_pos + DIRECTIONS[facing])

func move_backward() -> bool:
	return move_to(player_pos - DIRECTIONS[facing])

func move_to(target: Vector2i) -> bool:
	if not can_move_to(target):
		return false
	player_pos = target
	message = ""
	return true

func turn_left() -> void:
	facing = (facing + 3) % 4

func turn_right() -> void:
	facing = (facing + 1) % 4

func can_move_to(pos: Vector2i) -> bool:
	return is_inside_map(pos) and not is_wall(pos)

func is_inside_map(pos: Vector2i) -> bool:
	if pos.y < 0 or pos.y >= map.size(): return false
	if pos.x < 0 or pos.x >= map[pos.y].length(): return false
	return true

func is_wall(pos: Vector2i) -> bool:
	if not is_inside_map(pos): return true
	return map[pos.y][pos.x] == "#"

func get_tile(pos: Vector2i) -> String:
	if not is_inside_map(pos): return "#"
	return map[pos.y][pos.x]

func get_dungeon_name() -> String:
	return dungeon_data.get("name", "Unknown Dungeon")

func get_facing_name() -> String:
	return DIRECTION_NAMES[facing]

func get_width() -> int:
	if map.is_empty(): return 0
	return map[0].length()

func get_height() -> int:
	return map.size()

func get_forward_direction() -> Vector2i:
	return DIRECTIONS[facing]

func get_right_direction() -> Vector2i:
	var forward = get_forward_direction()
	return Vector2i(-forward.y, forward.x)

func get_relative_position(forward: int, sideways: int = 0) -> Vector2i:
	return player_pos + get_forward_direction() * forward + get_right_direction() * sideways

func get_current_fixed_encounter() -> Dictionary:
	if not fixed_encounters.has(player_pos): return {}
	var encounter: Dictionary = fixed_encounters[player_pos]
	var encounter_id: String = encounter.get("id", "")
	if encounter_id == "": return encounter
	var encounter_key = dungeon_id + ":" + encounter_id
	if defeated_fixed_encounters.get(encounter_key, false): return {}
	return encounter

func mark_current_fixed_encounter_defeated() -> void:
	if not fixed_encounters.has(player_pos): return
	var encounter: Dictionary = fixed_encounters[player_pos]
	var encounter_id: String = encounter.get("id", "")
	if encounter_id == "": return
	defeated_fixed_encounters[dungeon_id + ":" + encounter_id] = true

func is_fixed_encounter_defeated(check_dungeon_id: String, encounter_id: String) -> bool:
	return defeated_fixed_encounters.get(check_dungeon_id + ":" + encounter_id, false)

func has_fixed_encounter(pos: Vector2i) -> bool:
	if not fixed_encounters.has(pos): return false
	var encounter: Dictionary = fixed_encounters[pos]
	var encounter_id: String = encounter.get("id", "")
	if encounter_id == "": return true
	return not defeated_fixed_encounters.get(dungeon_id + ":" + encounter_id, false)

func get_current_transition() -> Dictionary:
	return transitions.get(player_pos, {})

func has_transition(pos: Vector2i) -> bool:
	return transitions.has(pos)

func get_current_event() -> Dictionary:
	if not events.has(player_pos): return {}
	var event: Dictionary = events[player_pos]
	var event_id: String = event.get("id", "")
	if event_id == "": return event
	if event.get("type", "") == "fountain":
		if consumed_expedition_events.get(event_id, false): return {}
	else:
		if consumed_permanent_events.get(event_id, false): return {}
	return event

func consume_current_event(per_expedition: bool = false) -> void:
	if not events.has(player_pos): return
	var event: Dictionary = events[player_pos]
	var event_id: String = event.get("id", "")
	if event_id == "": return
	if per_expedition:
		consumed_expedition_events[event_id] = true
	else:
		consumed_permanent_events[event_id] = true

# Optional objects use current-tile interaction and never block movement.
func get_rogue_object() -> Dictionary:
	return dungeon_data.get("rogue_objects", {}).get(player_pos, {})
