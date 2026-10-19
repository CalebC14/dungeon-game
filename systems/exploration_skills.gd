class_name ExplorationSkills
extends RefCounted

const SUCCESS_CHANCE = 70
const MENUS = {
	"Warrior": "Warrior Skills", "Berserker": "Berserker Skills",
	"Rogue": "Rogue Skills", "Hunter": "Hunter Skills", "Monk": "Monk Skills",
	"Bard": "Bard Songs", "Paladin": "Cast Spell", "Priest": "Cast Spell",
	"Shaman": "Cast Spell", "Conjurer": "Cast Spell", "Magician": "Cast Spell",
	"Druid": "Cast Spell", "Warlock": "Cast Spell"
}
const SKILLS = {
	"pick_lock": {"name": "Pick Lock", "class": "Rogue", "failure": "The lock stays shut."},
	"disarm_trap": {"name": "Disarm Trap", "class": "Rogue", "failure": "The trap triggers."},
	"force_obstacle": {"name": "Force Obstacle", "class": "Warrior", "failure": "The gate holds firm."},
	"break_barricade": {"name": "Break Barricade", "class": "Berserker", "failure": "The barricade holds."},
	"scout": {"name": "Scout", "class": "Hunter", "failure": "Scouting reveals no new information."},
	"track": {"name": "Track", "class": "Hunter", "failure": "The trail is lost."},
	"traverse_gap": {"name": "Traverse Gap", "class": "Monk", "failure": "The crossing fails."},
}

static func menu_name(character_class: String) -> String:
	return str(MENUS.get(character_class, "Class Skills"))

static func skills_for_class(character_class: String) -> Array[String]:
	var result: Array[String] = []
	for id in SKILLS:
		if SKILLS[id]["class"] == character_class:
			result.append(id)
	return result

static func object_key(dungeon: DungeonSystem, object: Dictionary) -> String:
	return dungeon.dungeon_id + ":" + str(object.get("id", ""))

static func unavailable_reason(party: PartySystem, dungeon: DungeonSystem, actor: Dictionary, skill: String, in_combat: bool = false) -> String:
	if in_combat:
		return "Class skills are unavailable during combat."
	if not SKILLS.has(skill):
		return "Choose a skill."
	var id = str(actor.get("character_id", ""))
	if id.is_empty() or not party.slots.has(id) or not is_same(party.find_character(id), actor) or actor.get("class", "") != SKILLS[skill]["class"]:
		return "Choose an active " + str(SKILLS[skill]["class"]) + "."
	if not CharacterHealth.conscious(actor):
		return "This character is incapacitated or dead."
	for effect in actor.get("effects", []):
		if effect.get("kind", "") == "control" and effect.get("id", "") in ["stun", "paralysis", "petrify"]:
			return "This character cannot act."
	var object = dungeon.get_skill_target()
	if object.is_empty() or object.get("skill", "") != skill:
		return "No matching exploration target on this tile."
	if object.get("type", "") == "locked_door" and DungeonInteractions.is_open(dungeon, object):
		return "This door is already open."
	if object.get("type", "") == "trap" and not DungeonInteractions.trap_active(dungeon, object):
		return "This trap is already safe."
	var state: Dictionary = dungeon.rogue_attempts.get(object_key(dungeon, object), {})
	if bool(state.get("resolved", false)):
		return "This object has already been resolved."
	if id in state.get("attempts", []):
		return "This character has already attempted this object."
	return ""

static func attempt(party: PartySystem, dungeon: DungeonSystem, actor: Dictionary, skill: String, in_combat: bool = false, test_roll: int = 0) -> Dictionary:
	var reason = unavailable_reason(party, dungeon, actor, skill, in_combat)
	if not reason.is_empty():
		return {"attempted": false, "message": reason}
	if test_roll < 0 or test_roll > 100:
		return {"attempted": false, "message": "Invalid roll."}
	var object = dungeon.get_skill_target()
	var key = object_key(dungeon, object)
	var state: Dictionary = dungeon.rogue_attempts.get(key, {"resolved": false, "attempts": []})
	state["attempts"].append(actor["character_id"])
	var success = (randi_range(1, 100) if test_roll == 0 else test_roll) <= SUCCESS_CHANCE
	state["resolved"] = success
	dungeon.rogue_attempts[key] = state
	if success:
		if object.get("type", "") == "trap":
			dungeon.interaction_states[DungeonInteractions.state_key(dungeon, object)] = {"disarmed": true}
		if object.get("type", "") == "locked_door":
			dungeon.interaction_states[DungeonInteractions.state_key(dungeon, object)] = {"open": true}
		return {"attempted": true, "success": true, "gold": int(object.get("reward_gold", 0)), "message": str(actor["name"]) + " succeeds at " + str(SKILLS[skill]["name"]) + ". " + str(object.get("success_message", "Object resolved."))}
	if object.get("type", "") == "trap":
		var triggered = DungeonInteractions.trigger_trap(dungeon, object, actor)
		return {"attempted": true, "success": false, "gold": 0, "message": str(triggered.get("message", "The trap is spent."))}
	var damage = 0
	var failure_damage = int(object.get("failure_damage", 4 if skill == "disarm_trap" else 0))
	if failure_damage > 0:
		damage = CharacterHealth.damage(actor, failure_damage)
	var message = str(SKILLS[skill]["failure"])
	if damage > 0:
		message += " %d HP lost." % damage
	return {"attempted": true, "success": false, "gold": 0, "message": message + " This character cannot retry this object."}

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
