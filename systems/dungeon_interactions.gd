class_name DungeonInteractions
extends RefCounted

# Data-only interactions: no object-defined scripts or expression evaluation.
static func state_key(dungeon, object: Dictionary) -> String:
	return dungeon.dungeon_id + ":" + str(object.get("id", ""))

static func is_barrier(object: Dictionary) -> bool:
	return object.get("type", "") in ["locked_door", "shortcut", "secret_door", "puzzle_door"]

static func is_open(dungeon, object: Dictionary) -> bool:
	return bool(dungeon.interaction_states.get(state_key(dungeon, object), {}).get("open", false))

static func is_hidden(dungeon, object: Dictionary) -> bool:
	return object.get("type", "") == "secret_door" and not is_open(dungeon, object)

static func facing_secret(dungeon) -> Dictionary:
	var object: Dictionary = dungeon.get_interaction_at(dungeon.player_pos + dungeon.get_forward_direction())
	return object if is_hidden(dungeon, object) else {}

static func trap_active(dungeon, object: Dictionary) -> bool:
	var state: Dictionary = dungeon.interaction_states.get(state_key(dungeon, object), {})
	return object.get("type", "") == "trap" and not bool(state.get("triggered", false)) and not bool(state.get("disarmed", false))

static func trigger_trap(dungeon, object: Dictionary, actor: Dictionary) -> Dictionary:
	if not trap_active(dungeon, object) or not CharacterHealth.conscious(actor):
		return {"triggered": false}
	dungeon.interaction_states[state_key(dungeon, object)] = {"triggered": true}
	var damage = CharacterHealth.damage(actor, int(object.get("damage", 4)))
	return {"triggered": true, "message": str(object.get("name", "Trap")) + " triggers! " + str(actor.get("name", "Adventurer")) + " loses %d HP." % damage}

static func available(dungeon, object: Dictionary) -> bool:
	if object.is_empty() or is_hidden(dungeon, object) or object.get("type", "") == "hidden_treasure":
		return false
	return object.get("type", "") != "key" or not bool(dungeon.interaction_states.get(state_key(dungeon, object), {}).get("collected", false))

static func target(dungeon) -> Dictionary:
	# Prefer what the player faces; fall back to the object underfoot.
	for position in [dungeon.player_pos + dungeon.get_forward_direction(), dungeon.player_pos]:
		var object: Dictionary = dungeon.get_interaction_at(position)
		if available(dungeon, object):
			return object
	return {}

static func treasure_target(dungeon) -> Dictionary:
	for position in [dungeon.player_pos + dungeon.get_forward_direction(), dungeon.player_pos]:
		var object: Dictionary = dungeon.get_interaction_at(position)
		if object.get("type", "") == "hidden_treasure":
			return object
	return {}

static func describe(dungeon, keys: Dictionary) -> String:
	var secret = facing_secret(dungeon)
	if not secret.is_empty():
		return str(secret.get("clue", "A faint draft slips through the wall.")) + " [Enter] Search wall."
	var treasure = treasure_target(dungeon)
	if not treasure.is_empty():
		if bool(dungeon.interaction_states.get(state_key(dungeon, treasure), {}).get("collected", false)):
			return "This hiding place has already been searched."
		return str(treasure.get("clue", "Something glints beneath the dust.")) + " [Enter] Search."
	var object = target(dungeon)
	if object.is_empty():
		return ""
	var name_text = str(object.get("name", "Object"))
	match object.get("type", ""):
		"puzzle_switch":
			var gate = dungeon.find_interaction(str(object.get("puzzle_id", "")))
			if is_open(dungeon, gate):
				return name_text + ". The puzzle is solved."
			return name_text + ". Sun before Moon. [Enter] Press switch."
		"puzzle_door":
			return name_text + (" is open." if is_open(dungeon, object) else " is shut. Inscription: Sun before Moon.")
		"trap":
			return name_text + (". [R] Disarm Trap, or walk around it." if trap_active(dungeon, object) else " is safe (disarmed or spent).")
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
		"secret_door":
			return name_text + " is open."
		"shortcut":
			return name_text + (" is open." if is_open(dungeon, object) else " is closed. Find its lever.")
	return name_text

static func interact(dungeon, keys: Dictionary, in_combat: bool = false) -> Dictionary:
	if in_combat:
		return {"handled": false, "message": "Interactions are unavailable during combat."}
	var secret = facing_secret(dungeon)
	if not secret.is_empty():
		dungeon.interaction_states[state_key(dungeon, secret)] = {"open": true}
		return {"handled": true, "message": str(secret.get("discovery_message", "You discover a secret door. The passage opens!"))}
	var treasure = treasure_target(dungeon)
	if not treasure.is_empty():
		var treasure_key = state_key(dungeon, treasure)
		if bool(dungeon.interaction_states.get(treasure_key, {}).get("collected", false)):
			return {"handled": true, "message": "This hiding place is empty. You already collected its treasure."}
		var gold = maxi(0, int(treasure.get("reward_gold", 0)))
		dungeon.interaction_states[treasure_key] = {"collected": true}
		return {"handled": true, "gold": gold, "message": "You discover " + str(treasure.get("name", "hidden treasure")) + ". +%d gold." % gold}
	var object = target(dungeon)
	if object.is_empty():
		return {"handled": false, "message": ""}
	var key = state_key(dungeon, object)
	var name_text = str(object.get("name", "Object"))
	match object.get("type", ""):
		"puzzle_switch":
			var gate = dungeon.find_interaction(str(object.get("puzzle_id", "")))
			if gate.get("type", "") != "puzzle_door" or object.get("step", 0) not in [1, 2]:
				return {"handled": true, "message": "The switch mechanism is not connected."}
			if is_open(dungeon, gate):
				return {"handled": true, "message": "The puzzle is already solved. The gate stays open."}
			var gate_key = state_key(dungeon, gate)
			var primed = bool(dungeon.interaction_states.get(gate_key, {}).get("primed", false))
			var expected = 2 if primed else 1
			if int(object["step"]) != expected:
				dungeon.interaction_states[gate_key] = {"primed": false}
				return {"handled": true, "message": "Wrong order. The switches reset. Try Sun before Moon."}
			if expected == 1:
				dungeon.interaction_states[gate_key] = {"primed": true}
				return {"handled": true, "message": "The Sun switch clicks. One more switch remains."}
			dungeon.interaction_states[gate_key] = {"open": true, "primed": false}
			return {"handled": true, "message": "The Moon switch clicks. Puzzle solved! The sorting gate opens permanently."}
		"puzzle_door":
			return {"handled": true, "message": describe(dungeon, keys)}
		"trap":
			return {"handled": true, "message": describe(dungeon, keys)}
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
		"secret_door":
			return {"handled": true, "message": name_text + " is already open."}
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
			if flag not in ["open", "collected", "used", "triggered", "disarmed", "primed"] or not state[flag] is bool:
				return false
	return true
