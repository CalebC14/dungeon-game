class_name PartySystem
extends RefCounted

const SLOT_NAMES = ["Front left", "Front center", "Front right", "Rear left", "Rear center", "Rear right"]
const SAVE_VERSION = 2
var roster: Array = []
var inventory: Array = []
var slots: Array = ["", "", "", "", "", ""]

func register_character(character: Dictionary) -> bool:
	var id = str(character.get("character_id", ""))
	if id.is_empty():
		id = Crypto.new().generate_random_bytes(16).hex_encode()
		character["character_id"] = id
	if not find_character(id).is_empty():
		return false
	CharacterHealth.ensure(character)
	collect_legacy_inventory(character)
	roster.append(character)
	return true

# Called once at registration or restore; equipped items remain individual.
func collect_legacy_inventory(character: Dictionary):
	inventory.append_array(character.get("inventory", []))
	character["inventory"] = []

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
	if active_members().is_empty() or active_members().size() > 6:
		return false
	for character in active_members():
		if CharacterHealth.conscious(character):
			return true
	return false

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

# Rearrangement never adds a reserve or changes active membership.
func reposition(id: String, slot: int) -> bool:
	var previous = slots.find(id)
	if id.is_empty() or previous < 0 or slot < 0 or slot >= 6 or previous == slot:
		return false
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
			for item in roster[i].get("equipment", {}).values():
				if item != null:
					inventory.append(item)
			roster.remove_at(i)
			return true
	return false

func to_data() -> Dictionary:
	return {"version": SAVE_VERSION, "roster": roster.duplicate(true), "slots": slots.duplicate(), "inventory": inventory.duplicate()}

# Validate before replacing live state. IDs, holes, and character state survive
# a JSON round trip without relying on shared dictionary references.
func restore(data: Dictionary) -> bool:
	if (data.get("version") != 1 and data.get("version") != SAVE_VERSION) or not data.get("roster") is Array or not data.get("slots") is Array:
		return false
	var incoming: Array = data["slots"]
	if incoming.size() != 6:
		return false
	var ids: Array = []
	for character in data["roster"]:
		if not character is Dictionary or not character.get("character_id") is String:
			return false
		if character.has("dead") and not character["dead"] is bool:
			return false
		for field in ["hp", "max_hp", "death_rounds_remaining", "incapacitation_generation"]:
			if character.has(field):
				var value = character[field]
				if (not value is int and not value is float) or value < 0 or value != int(value):
					return false
		if int(character.get("death_rounds_remaining", 3)) > 3:
			return false
		if not character.get("effects", []) is Array:
			return false
		for effect in character.get("effects", []):
			if not effect is Dictionary:
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
	var shared = data.get("inventory", [])
	if not shared is Array or (data.get("version") == SAVE_VERSION and not data.has("inventory")):
		return false
	for item in shared:
		if not item is String:
			return false
	for character in data["roster"]:
		if not character.get("inventory", []) is Array:
			return false
		for item in character.get("inventory", []):
			if not item is String:
				return false
	roster = data["roster"].duplicate(true)
	slots = incoming.duplicate()
	inventory = shared.duplicate()
	for character in roster:
		CharacterHealth.ensure(character)
		collect_legacy_inventory(character)
	return true
