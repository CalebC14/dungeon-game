class_name RogueSkills
extends RefCounted

# Deliberately fixed for the first playable test; tune progression later.
const SKILLS = {"pick_lock": "Pick Lock", "disarm_trap": "Disarm Trap"}
const SUCCESS_CHANCE = 70

static func object_key(dungeon: DungeonSystem, object: Dictionary) -> String:
	return dungeon.dungeon_id + ":" + str(object.get("id", ""))

static func unavailable_reason(party: PartySystem, dungeon: DungeonSystem, actor: Dictionary, skill: String, in_combat: bool = false) -> String:
	if in_combat:
		return "Rogue Skills are unavailable during combat."
	if not SKILLS.has(skill):
		return "Choose a Rogue skill."
	var id = str(actor.get("character_id", ""))
	if id.is_empty() or not party.slots.has(id) or not is_same(party.find_character(id), actor) or actor.get("class", "") != "Rogue":
		return "Choose an active Rogue."
	if not CharacterHealth.conscious(actor):
		return "This Rogue is incapacitated or dead."
	for effect in actor.get("effects", []):
		if effect.get("kind", "") == "control" and effect.get("id", "") in ["stun", "paralysis", "petrify"]:
			return "This Rogue cannot act."
	var object = dungeon.get_rogue_object()
	if object.is_empty() or object.get("skill", "") != skill:
		return "No matching lock or trap on this tile."
	var state: Dictionary = dungeon.rogue_attempts.get(object_key(dungeon, object), {})
	if bool(state.get("resolved", false)):
		return "This object has already been resolved."
	if id in state.get("attempts", []):
		return "This Rogue has already attempted this object."
	return ""

static func attempt(party: PartySystem, dungeon: DungeonSystem, actor: Dictionary, skill: String, in_combat: bool = false, test_roll: int = 0) -> Dictionary:
	var reason = unavailable_reason(party, dungeon, actor, skill, in_combat)
	if not reason.is_empty():
		return {"attempted": false, "message": reason}
	if test_roll < 0 or test_roll > 100:
		return {"attempted": false, "message": "Invalid roll."}
	var object = dungeon.get_rogue_object()
	var key = object_key(dungeon, object)
	var state: Dictionary = dungeon.rogue_attempts.get(key, {"resolved": false, "attempts": []})
	state["attempts"].append(actor["character_id"])
	var success = (randi_range(1, 100) if test_roll == 0 else test_roll) <= SUCCESS_CHANCE
	state["resolved"] = success
	dungeon.rogue_attempts[key] = state
	if success:
		return {"attempted": true, "success": true, "gold": int(object.get("reward_gold", 0)), "message": str(actor["name"]) + " succeeds at " + str(SKILLS[skill]) + "."}
	var damage = 0
	if skill == "disarm_trap":
		damage = CharacterHealth.damage(actor, int(object.get("failure_damage", 4)))
	var message = "The lock stays shut." if skill == "pick_lock" else "The trap triggers: %d HP lost." % damage
	return {"attempted": true, "success": false, "gold": 0, "message": message + " This Rogue cannot retry this object."}

static func valid_records(records: Variant) -> bool:
	if not records is Dictionary:
		return false
	for key in records:
		var record = records[key]
		if not key is String or not record is Dictionary or not record.get("resolved") is bool or not record.get("attempts") is Array:
			return false
		for id in record["attempts"]:
			if not id is String:
				return false
	return true
