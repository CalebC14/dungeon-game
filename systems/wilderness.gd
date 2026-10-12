class_name WildernessSystem
extends RefCounted

const WildernessDataScript = preload("res://data/wilderness_data.gd")
const DIRECTIONS = [Vector2i(0,-1), Vector2i(1,0), Vector2i(0,1), Vector2i(-1,0)]
const DIRECTION_NAMES = ["NORTH", "EAST", "SOUTH", "WEST"]

var wilderness_id = "ashenwood_wilderness"
var data: Dictionary = {}
var map: Array = []
var locations: Dictionary = {}
var player_pos = Vector2i.ZERO
var facing = 1
var message = ""

func _init():
	load_wilderness(wilderness_id)

func load_wilderness(id: String) -> bool:
	if not WildernessDataScript.WILDERNESSES.has(id):
		return false
	wilderness_id = id
	data = WildernessDataScript.WILDERNESSES[id]
	map = data.get("map", [])
	locations = data.get("locations", {})
	reset_to_start()
	return true

func reset_to_start():
	player_pos = data.get("start_position", Vector2i(1,1))
	facing = data.get("start_facing", 1)
	message = data.get("start_message", "You enter the wilderness.")

func reset_to_thornwake():
	if wilderness_id != "ashenwood_wilderness":
		load_wilderness("ashenwood_wilderness")
	player_pos = Vector2i(2, 4)
	facing = 1
	message = "You step beyond Thornwake's walls into Ashenwood."

func reset_to_grayhaven():
	if wilderness_id != "ashenwood_wilderness":
		load_wilderness("ashenwood_wilderness")
	player_pos = Vector2i(19, 19)
	facing = 3
	message = "You leave Grayhaven through the west gate and return to Ashenwood."

func reset_to_ashenwood_east_gate():
	load_wilderness("ashenwood_wilderness")
	player_pos = Vector2i(20, 19)
	facing = 3
	message = "You leave the Dreadmarch behind and return beneath Ashenwood's gray trees."

func reset_to_dreadmarch_west_gate():
	load_wilderness("dreadmarch_wilderness")
	player_pos = Vector2i(0, 10)
	facing = 1
	message = "The trees fall away behind you. The Dreadmarch opens ahead: stone, brittle grass, and a hard eastern wind."

func reset_to_oldroot():
	if wilderness_id != "dreadmarch_wilderness":
		load_wilderness("dreadmarch_wilderness")
	player_pos = Vector2i(2, 10)
	facing = 1
	message = "You leave Oldroot and step onto the wind-scoured Dreadmarch."

func reset_to_ironreach():
	if wilderness_id != "dreadmarch_wilderness":
		load_wilderness("dreadmarch_wilderness")
	player_pos = Vector2i(21, 17)
	facing = 3
	message = "You leave Ironreach for the open Dreadmarch."

func move_forward() -> bool:
	return move_to(player_pos + DIRECTIONS[facing])
func move_backward() -> bool:
	return move_to(player_pos - DIRECTIONS[facing])
func move_to(pos: Vector2i) -> bool:
	if is_blocked(pos):
		return false
	player_pos = pos
	message = ""
	return true
func turn_left():
	facing = (facing + 3) % 4
func turn_right():
	facing = (facing + 1) % 4
func get_facing_name() -> String:
	return DIRECTION_NAMES[facing]
func get_name() -> String:
	return data.get("name", "Wilderness")
func get_width() -> int:
	return map[0].length() if not map.is_empty() else 0
func get_height() -> int:
	return map.size()
func is_inside(pos: Vector2i) -> bool:
	return pos.y >= 0 and pos.y < map.size() and pos.x >= 0 and pos.x < map[pos.y].length()
func get_tile(pos: Vector2i) -> String:
	return map[pos.y][pos.x] if is_inside(pos) else "^"
func is_blocked(pos: Vector2i) -> bool:
	return not is_inside(pos) or get_tile(pos) in ["T", "~", "^", "R"]
func get_relative_position(forward: int, sideways: int = 0) -> Vector2i:
	var f = DIRECTIONS[facing]
	var r = Vector2i(-f.y, f.x)
	return player_pos + f * forward + r * sideways
func get_current_location() -> Dictionary:
	return locations.get(player_pos, {})
func has_location(pos: Vector2i) -> bool:
	return locations.has(pos)
func get_encounter_chance() -> float:
	var tile = get_tile(player_pos)
	if tile == "=":
		return 0.08
	if tile == "f":
		return 0.22
	if tile == ",":
		return 0.16
	return 0.14
