class_name CitySystem
extends RefCounted

const CityDataScript = preload("res://data/city_data.gd")

var city_id: String = "thornwake"
var city_data: Dictionary = {}
var map: Array = []
var locations: Dictionary = {}
var player_pos: Vector2i = Vector2i.ZERO
var facing: int = 0
var message: String = ""

const DIRECTIONS = [Vector2i(0,-1), Vector2i(1,0), Vector2i(0,1), Vector2i(-1,0)]
const DIRECTION_NAMES = ["NORTH","EAST","SOUTH","WEST"]

func _init():
	load_city(city_id)

func load_city(new_city_id: String) -> bool:
	if not CityDataScript.CITIES.has(new_city_id):
		return false
	city_id = new_city_id
	city_data = CityDataScript.CITIES[city_id]
	map = city_data.get("map", [])
	locations = city_data.get("locations", {})
	reset()
	return true

func reset():
	player_pos = city_data.get("start_position", Vector2i(1,1))
	facing = city_data.get("start_facing", 0)
	message = ""

func set_entry(position: Vector2i, new_facing: int, new_message: String = ""):
	player_pos = position
	facing = new_facing
	message = new_message

func move_forward() -> bool: return move_to(player_pos + DIRECTIONS[facing])
func move_backward() -> bool: return move_to(player_pos - DIRECTIONS[facing])
func move_to(target: Vector2i) -> bool:
	if not can_move_to(target): return false
	player_pos = target
	message = ""
	return true
func turn_left(): facing = (facing + 3) % 4; message = ""
func turn_right(): facing = (facing + 1) % 4; message = ""
func can_move_to(pos: Vector2i) -> bool: return is_inside_map(pos) and not is_wall(pos)
func is_inside_map(pos: Vector2i) -> bool:
	return pos.y >= 0 and pos.y < map.size() and pos.x >= 0 and pos.x < map[pos.y].length()
func is_wall(pos: Vector2i) -> bool: return not is_inside_map(pos) or map[pos.y][pos.x] == "#"
func get_facing_name() -> String: return DIRECTION_NAMES[facing]
func get_forward_direction() -> Vector2i: return DIRECTIONS[facing]
func get_right_direction() -> Vector2i:
	var forward = get_forward_direction()
	return Vector2i(-forward.y, forward.x)
func get_relative_position(forward: int, sideways: int = 0) -> Vector2i:
	return player_pos + get_forward_direction() * forward + get_right_direction() * sideways
func get_current_location() -> Dictionary: return locations.get(player_pos, {})
func has_location(pos: Vector2i) -> bool: return locations.has(pos)
func get_city_name() -> String: return city_data.get("name", "Unknown City")
func get_width() -> int: return map[0].length() if not map.is_empty() else 0
func get_height() -> int: return map.size()
func set_message(new_message: String): message = new_message
