extends SceneTree
var failures: Array[String] = []
func check(ok: bool, label: String):
	if not ok:
		failures.append(label)

func _initialize():
	seed(99)
	var combat = CombatSystem.new()
	var victim = CharacterFactory.make_blank_character()
	victim.merge({"name":"Victim", "class":"Warrior", "hp":1, "max_hp":30, "dex":1}, true)
	var healer = CharacterFactory.make_blank_character()
	healer.merge({"name":"Healer", "class":"Priest", "hp":30, "max_hp":30, "int":18, "dex":1}, true)
	var enemy = combat.create_enemy_from_data(GameData.ENEMIES["skeleton"])
	enemy["base_accuracy"] = 1.0
	enemy["damage_min"] = 1000
	enemy["damage_max"] = 1000
	combat.enemies = [enemy]
	combat.add_threat(enemy, victim, 100)
	for i in range(10):
		combat.resolve_enemy_action(enemy, [victim, healer])
		if victim["hp"] == 0:
			break
	check(victim["hp"] == 0 and victim.get("death_rounds_remaining") == 3 and victim.get("incapacitation_generation") == 1, "real enemy damage starts incapacitation exactly once")
	combat.mend(healer, [healer, victim])
	check(victim["hp"] > 0 and victim["death_rounds_remaining"] == 3, "real Priest healing revives incapacitated target")
	CharacterHealth.damage(victim, 1000)
	for i in range(3):
		CharacterHealth.complete_round(CharacterHealth.countdown_snapshot([victim]))
	combat.heal_character(healer, victim, 100, "heals")
	check(victim["dead"] and victim["hp"] == 0 and victim["death_rounds_remaining"] == 0, "combat healing cannot bypass death")
	var snapshot = CharacterHealth.countdown_snapshot([healer])
	CharacterHealth.damage(healer, 1000)
	CharacterHealth.complete_round(snapshot)
	check(healer["death_rounds_remaining"] == 3, "new fall is excluded from round start snapshot")
	check(combat.party_defeated([victim, healer]), "dead plus incapacitated party is defeated")
	var model = PartySystem.new()
	model.register_character(victim)
	model.assign_member(victim["character_id"], 0, true)
	check(not model.can_adventure(), "all dead party cannot leave Guild")
	var invalid = model.to_data()
	invalid["roster"][0]["death_rounds_remaining"] = "invalid"
	check(not model.restore(invalid) and model.roster[0]["dead"], "malformed health save rejected atomically")
	if failures.is_empty():
		print("PASS real combat damage, healing, defeat, and health validation")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
