extends SceneTree

const Combat = preload("res://systems/combat.gd")
const TestPartyData = preload("res://dev/test_party.gd")
var failures: Array[String] = []

func check(ok: bool, description: String) -> void:
	if not ok:
		failures.append(description)

func _initialize() -> void:
	seed(123456)
	var party: Array = TestPartyData.create()
	var combat = Combat.new()
	check(party.size() == 6, "test party has six characters")
	for member in party:
		check(int(member.get("hp", 0)) > 0, "living member: " + str(member.get("name", "")))
	# Create a deterministic encounter from the project's existing enemy data.
	var enemy_data: Dictionary = GameData.ENEMIES.get("skeleton", {})
	if enemy_data.is_empty():
		failures.append("skeleton fixture not present in GameData.ENEMIES")
	else:
		var first: Dictionary = combat.create_enemy_from_data(enemy_data)
		var second: Dictionary = combat.create_enemy_from_data(enemy_data)
		combat.enemies = [first, second]
		var warrior: Dictionary = party[0]
		var paladin: Dictionary = party[1]
		combat.add_threat(first, warrior, 30.0)
		combat.add_threat(first, paladin, 10.0)
		combat.add_threat(second, warrior, 10.0)
		combat.add_threat(second, paladin, 30.0)
		check(combat.select_enemy_target(first, party) == warrior, "first enemy chooses warrior")
		check(combat.select_enemy_target(second, party) == paladin, "second enemy chooses paladin")
		combat.damage_enemy(warrior, first, 5, "strikes")
		check(float(first["threat"].get(combat.combatant_key(warrior), 0.0)) == 35.0, "damage adds threat to attacked enemy")
		check(float(second["threat"].get(combat.combatant_key(warrior), 0.0)) == 10.0, "damage does not add threat to other enemies")
		for member in party:
			combat.queue_action(member, "Defend")
		combat.resolve_round(party)
		check(combat.round_number == 2, "full combat round resolves")
		check(combat.party_actions.is_empty(), "actions cleared after round")
		check(combat.combat_log.size() > 0, "combat log populated")
	if failures.is_empty():
		print("PASS test party combat smoke")
		quit(0)
	else:
		for failure in failures:
			push_error("FAIL: " + failure)
		quit(1)
