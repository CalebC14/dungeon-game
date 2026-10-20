extends SceneTree
class RecordingCombat extends CombatSystem:
	var turns: Array[String] = []
	func resolve_party_action(action: Dictionary, _party: Array) -> void:
		turns.append(action["actor"]["name"])
		if action["action"] == "Timed":
			effects.apply(action["actor"], {"id":"brief", "kind":"damage_reduction", "duration":1})
			effects.set_cooldown(action["actor"], "test", 2)
	func resolve_enemy_action(enemy: Dictionary, _party: Array) -> void:
		turns.append(enemy["name"])
var failures: Array[String] = []
func check(ok: bool, label: String):
	if not ok: failures.append(label)
func member(label: String, dexterity: int) -> Dictionary:
	var actor = CharacterFactory.make_blank_character()
	actor.merge({"name":label, "class":"Warrior", "hp":20, "max_hp":20, "dex":dexterity}, true)
	return actor
func _initialize():
	var combat = RecordingCombat.new()
	var a = member("A", 10)
	var b = member("B", 10)
	var faster = member("Fast", 15)
	combat.enemies = [member("E1",10), member("E2",10)]
	check(combat.queue_action(b,"Timed") and combat.queue_action(a,"Defend") and combat.queue_action(faster,"Defend"), "eligible actions accepted")
	check(not combat.queue_action(b,"Defend") and combat.party_actions.size() == 3, "duplicate actor cannot queue extra turn")
	combat.resolve_round([a,b,faster])
	check(combat.turns == ["Fast","B","A","E1","E2"], "Dexterity wins then stable party selection and encounter order")
	check(b["effects"].is_empty() and combat.effects.cooldown_remaining(b,"test") == 1, "new duration-one effect expires and cooldown ticks in application round")
	combat.queue_action(a,"Defend")
	combat.resolve_round([a,b,faster])
	check(combat.effects.cooldown_remaining(b,"test") == 0, "cooldown clears at second completed boundary")
	combat.effects.apply(a, {"id":"long", "kind":"damage_reduction", "duration":2})
	combat.finish_round([a], [], false)
	check(a["effects"][0]["duration"] == 2, "incomplete round does not tick effects")
	combat.finish_round([a], [], true)
	check(a["effects"][0]["duration"] == 1, "complete round decrements once")
	combat.finish_round([a], [], true)
	check(a["effects"].is_empty(), "effect expires after configured boundaries")
	a["hp"] = 0
	check(not combat.queue_action(a,"Defend"), "incapacitated actor cannot queue")
	a["hp"] = 20
	combat.effects.apply(a, {"id":"paralysis", "kind":"control"})
	check(not combat.queue_action(a,"Defend"), "controlled actor cannot queue")
	var model = PartySystem.new()
	var active = member("Active",10)
	var reserve = member("Reserve",10)
	model.register_character(active)
	model.register_character(reserve)
	model.assign_member(active["character_id"],0,true)
	combat.formation = model
	check(not combat.queue_action(reserve,"Defend"), "reserve cannot queue combat action")
	check(not combat.queue_action(active.duplicate(true),"Defend"), "copied actor cannot impersonate canonical member")
	check(combat.queue_action(active,"Defend"), "canonical active member can queue")
	if failures.is_empty():
		print("PASS deterministic initiative, single actions, and round-boundary timing")
		quit(0)
	else:
		for label in failures: push_error(label)
		quit(1)
