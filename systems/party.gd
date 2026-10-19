class_name PartySystem
extends RefCounted

const SLOT_NAMES = ["Front left", "Front center", "Front right", "Rear left", "Rear center", "Rear right"]
const SAVE_VERSION = 1
var roster: Array = []
var slots: Array = ["", "", "", "", "", ""]

func register_character(character: Dictionary) -> bool:
	var id = str(character.get("character_id", ""))
	if id.is_empty():
		id = Crypto.new().generate_random_bytes(16).hex_encode()
		character["character_id"] = id
	if not find_character(id).is_empty():
		return false
	roster.append(character)
	return true

func find_character(id: String) -> Dictionary:
	for character in roster:
		if str(character.get("character_id", "")) == id:
			return character
	return {}

func active_members() -> Array:
	var result: Array = []
	for id in slots:
		if id != "":
			result.append(find_character(id))
	return result

func can_adventure() -> bool:
	return active_members().size() >= 1 and active_members().size() <= 6

# The controller supplies its current Guild context; all membership changes
# pass through these methods, including development fixtures.
func assign_member(id: String, slot: int, at_guild: bool) -> bool:
	if not at_guild or slot < 0 or slot >= 6 or find_character(id).is_empty():
		return false
	var previous = slots.find(id)
	if previous >= 0:
		slots[previous] = slots[slot]
	slots[slot] = id
	return true

func remove_member(id: String, at_guild: bool) -> bool:
	if not at_guild or not slots.has(id):
		return false
	slots[slots.find(id)] = ""
	return true

func delete_character(id: String, at_guild: bool) -> bool:
	if not at_guild:
		return false
	for i in range(roster.size()):
		if roster[i].get("character_id", "") == id:
			remove_member(id, true)
			roster.remove_at(i)
			return true
	return false

func to_data() -> Dictionary:
	return {"version": SAVE_VERSION, "roster": roster.duplicate(true), "slots": slots.duplicate()}

# Validate before replacing live state. IDs, holes, and character state survive
# a JSON round trip without relying on shared dictionary references.
func restore(data: Dictionary) -> bool:
	if data.get("version") != SAVE_VERSION or not data.get("roster") is Array or not data.get("slots") is Array:
		return false
	var incoming: Array = data["slots"]
	if incoming.size() != 6:
		return false
	var ids: Array = []
	for character in data["roster"]:
		if not character is Dictionary or not character.get("character_id") is String:
			return false
		var id: String = character["character_id"]
		if id.is_empty() or ids.has(id):
			return false
		ids.append(id)
	var occupied: Array = []
	for id in incoming:
		if not id is String:
			return false
		if id != "":
			if not ids.has(id) or occupied.has(id):
				return false
			occupied.append(id)
	roster = data["roster"].duplicate(true)
	slots = incoming.duplicate()
	return true
