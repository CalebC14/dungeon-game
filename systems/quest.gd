class_name QuestSystem
extends RefCounted

const QuestDataScript = preload("res://data/quest_data.gd")
var quest_states: Dictionary = {}

func get_state(quest_id: String) -> String:
	return quest_states.get(quest_id, "not_started")
func set_state(quest_id: String, new_state: String) -> void:
	quest_states[quest_id] = new_state
func start_quest(quest_id: String) -> void:
	if get_state(quest_id) == "not_started":
		set_state(quest_id, "active")
func complete_quest(quest_id: String) -> void:
	set_state(quest_id, "completed")
func is_started(quest_id: String) -> bool:
	return get_state(quest_id) != "not_started"
func is_completed(quest_id: String) -> bool:
	return get_state(quest_id) == "completed"
func get_display_status(quest_id: String) -> String:
	if not QuestDataScript.QUESTS.has(quest_id):
		return "UNKNOWN"
	var quest = QuestDataScript.QUESTS[quest_id]
	var quest_name = quest["name"]
	var state = get_state(quest_id)
	match state:
		"not_started": return quest_name + " — NOT STARTED"
		"active": return quest_name + " — ACTIVE"
		"boss_defeated", "onika_defeated", "bristle_defeated": return quest_name + " — RETURN TO " + str(quest.get("giver", "QUEST GIVER")).to_upper()
		"katy_missing": return quest_name + " — RETURN TO THORNWAKE"
		"dreadmarch_unlocked": return quest_name + " — FIND FORT DREAD"
		"completed": return quest_name + " — COMPLETED"
	return quest_name + " — " + state.to_upper()
