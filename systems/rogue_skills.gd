class_name RogueSkills
extends RefCounted

# Preserve the existing Rogue menu and callers while sharing first-pass logic.
const SKILLS = {"pick_lock": "Pick Lock", "disarm_trap": "Disarm Trap"}
const SUCCESS_CHANCE = ExplorationSkills.SUCCESS_CHANCE

static func object_key(dungeon: DungeonSystem, object: Dictionary) -> String:
	return ExplorationSkills.object_key(dungeon, object)

static func unavailable_reason(party: PartySystem, dungeon: DungeonSystem, actor: Dictionary, skill: String, in_combat: bool = false) -> String:
	if not SKILLS.has(skill):
		return "Choose a Rogue skill."
	return ExplorationSkills.unavailable_reason(party, dungeon, actor, skill, in_combat)

static func attempt(party: PartySystem, dungeon: DungeonSystem, actor: Dictionary, skill: String, in_combat: bool = false, test_roll: int = 0) -> Dictionary:
	if not SKILLS.has(skill):
		return {"attempted": false, "message": "Choose a Rogue skill."}
	return ExplorationSkills.attempt(party, dungeon, actor, skill, in_combat, test_roll)

static func valid_records(records: Variant) -> bool:
	return ExplorationSkills.valid_records(records)
