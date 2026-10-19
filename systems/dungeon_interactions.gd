class_name DungeonInteractions
extends RefCounted

# Data-only interactions: no object-defined scripts or expression evaluation.
static func state_key(dungeon, object: Dictionary) -> String:
	return dungeon.dungeon_id + ":" + str(object.get("id", ""))

static func is_barrier(object: Dictionary) -> bool:
	return object.get("type", "") in ["locked_door", "shortcut"]

static func is_open(dungeon, object: Dictionary) -> bool:
	return bool(dungeon.interaction_states.get(state_key(dungeon, object), {}).get("open", false))

static func available(dungeon, object: Dictionary) -> bool:
	if object.is_empty():
		return false
	return object.get("type", "") != "key" or not bool(dungeon.interaction_states.get(state_key(dungeon, object), {}).get("collected", false))

static func target(dungeon) -> Dictionary:
	# Prefer what the player faces; fall back to the object underfoot.
	for position in [dungeon.player_pos + dungeon.get_forward_direction(), dungeon.player_pos]:
		var object: Dictionary = dungeon.get_interaction_at(position)
		if available(dungeon, object):
			return object
	return {}

static func describe(dungeon, keys: Dictionary) -> String:
	var object = target(dungeon)
	if object.is_empty():
		return ""
	var name_text = str(object.get("name", "Object"))
	match object.get("type", ""):
		"key":
			return name_text + ". [Enter] Take key."
		"locked_door":
			if is_open(dungeon, object):
				return name_text + " is open."
			var hint = name_text + (". [Enter] Unlock with key." if bool(keys.get(object.get("key_id", ""), false)) else " is locked. Find the " + str(object.get("key_name", "key")) + ".")
			return hint + (" [R] Pick Lock." if bool(object.get("pickable", false)) else "")
		"lever":
			if bool(dungeon.interaction_states.get(state_key(dungeon, object), {}).get("used", false)):
				return name_text + " is down. The shortcut is open."
			return name_text + ". [Enter] Pull lever."
		"shortcut":
			return name_text + (" is open." if is_open(dungeon, object) else " is closed. Find its lever.")
	return name_text

static func interact(dungeon, keys: Dictionary, in_combat: bool = false) -> Dictionary:
	if in_combat:
		return {"handled": false, "message": "Interactions are unavailable during combat."}
	var object = target(dungeon)
	if object.is_empty():
		return {"handled": false, "message": ""}
	var key = state_key(dungeon, object)
	var name_text = str(object.get("name", "Object"))
	match object.get("type", ""):
		"key":
			keys[str(object["key_id"])] = true
			dungeon.interaction_states[key] = {"collected": true}
			return {"handled": true, "message": "Picked up " + name_text + ". The key is reusable."}
		"locked_door":
			if is_open(dungeon, object):
				return {"handled": true, "message": name_text + " is already open."}
			if not bool(keys.get(object.get("key_id", ""), false)):
				return {"handled": true, "message": "Locked. You need the " + str(object.get("key_name", "key")) + "." + (" [R] Pick Lock is an alternative." if bool(object.get("pickable", false)) else "")}
			dungeon.interaction_states[key] = {"open": true}
			return {"handled": true, "message": "Unlocked " + name_text + ". The key remains in your keyring."}
		"lever":
			if bool(dungeon.interaction_states.get(key, {}).get("used", false)):
				return {"handled": true, "message": "The lever is already down. The shortcut stays open."}
			var targets: Array = []
			for id in object.get("opens", []):
				var destination: Dictionary = dungeon.find_interaction(str(id))
				if destination.is_empty() or not is_barrier(destination):
					return {"handled": true, "message": "The lever mechanism is not connected."}
				targets.append(destination)
			if targets.is_empty():
				return {"handled": true, "message": "The lever mechanism is not connected."}
			for destination in targets:
				dungeon.interaction_states[state_key(dungeon, destination)] = {"open": true}
			dungeon.interaction_states[key] = {"used": true}
			return {"handled": true, "message": str(object.get("message", "The lever opens a shortcut."))}
		"shortcut":
			return {"handled": true, "message": name_text + (" is open." if is_open(dungeon, object) else " is closed. Find its lever.")}
	return {"handled": false, "message": ""}

static func valid_states(states: Variant) -> bool:
	if not states is Dictionary:
		return false
	for key in states:
		var state = states[key]
		if not key is String or key.is_empty() or not state is Dictionary or state.is_empty():
			return false
		for flag in state:
			if flag not in ["open", "collected", "used"] or not state[flag] is bool:
				return false
	return true
