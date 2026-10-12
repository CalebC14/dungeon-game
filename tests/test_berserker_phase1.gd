extends SceneTree
const Combat = preload("res://systems/combat.gd")

func _initialize() -> void:
	var combat = Combat.new()
	var berserker = {"name":"Rusk", "class":"Berserker", "specialization":"tank", "level":30, "hp":150, "sp":40, "dex":10, "str":18, "equipment":{"weapon":null, "off_hand":null}}
	var enemy = {"name":"Raider", "hp":1000, "threat":{}, "boss":false}
	var boss = {"name":"Chieftain", "hp":1000, "threat":{}, "is_boss":true}
	combat.enemies = [enemy, boss]
	if not combat.berserker_tank_unlocked(berserker, 9) or combat.berserker_tank_unlocked(berserker, 40):
		fail_test("level gates")
		return
	if absf(combat.get_character_avoidance(berserker) - 0.10) > 0.001:
		fail_test("Unyielding Fury dodge")
		return
	combat.ensure_berserker_tank_presence(berserker)
	combat.ensure_berserker_tank_presence(berserker)
	if combat.effects.threat_multiplier(berserker) != 2.0:
		fail_test("Unyielding Fury threat should not stack")
		return
	if not combat.berserker_lunatic_howl(berserker):
		fail_test("Lunatic Howl activation")
		return
	var key: String = combat.combatant_key(berserker)
	if float(enemy["threat"].get(key, 0.0)) <= 0.0 or float(boss["threat"].get(key, 0.0)) <= 0.0:
		fail_test("Lunatic Howl threat on each enemy")
		return
	if absf(combat.effects.total(enemy, "physical_damage_reduction") - 0.10) > 0.001 or absf(combat.effects.total(boss, "physical_damage_reduction") - 0.05) > 0.001:
		fail_test("Lunatic Howl debuff / boss exception")
		return
	if int(berserker["sp"]) != 32 or combat.berserker_lunatic_howl(berserker):
		fail_test("Lunatic Howl SP/cooldown")
		return
	combat.effects.tick(enemy)
	combat.effects.tick(enemy)
	if combat.effects.total(enemy, "physical_damage_reduction") != 0.0:
		fail_test("Lunatic Howl expiration")
		return
	for i in range(5):
		combat.berserker_brutal_challenge_on_hit(berserker)
	if absf(combat.effects.total(berserker, "berserker_physical_bonus") - 0.15) > 0.001:
		fail_test("Brutal Challenge stack cap")
		return
	if combat.berserker_brutal_challenge_damage(berserker, 100) != 115:
		fail_test("Brutal Challenge damage bonus")
		return
	combat.effects.tick(berserker)
	combat.effects.tick(berserker)
	combat.effects.tick(berserker)
	if combat.berserker_brutal_challenge_damage(berserker, 100) != 100:
		fail_test("Brutal Challenge expiration")
		return
	var ally = {"name":"Scout", "hp":100, "combat_key":"ally"}
	enemy["threat"]["ally"] = 100.0
	if not combat.berserker_taunt(berserker, enemy):
		fail_test("Taunt activation")
		return
	if float(enemy["threat"].get(key, 0.0)) < 110.0 or int(berserker["sp"]) != 27:
		fail_test("Taunt threat/SP")
		return
	if combat.berserker_taunt(berserker, enemy):
		fail_test("Taunt cooldown")
		return
	print("PASS berserker tank phase 1")
	quit(0)

func fail_test(message: String) -> void:
	printerr("FAIL berserker tank phase 1: " + message)
	quit(1)
