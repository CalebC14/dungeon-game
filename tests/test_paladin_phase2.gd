extends SceneTree
const Combat = preload("res://systems/combat.gd")

func _initialize() -> void:
	var combat = Combat.new()
	var paladin = {"name":"Aldren", "class":"Paladin", "specialization":"tank", "level":60, "hp":100, "sp":100, "equipment":{"weapon":null, "off_hand":"wooden_shield"}, "wis_mod":3}
	var ally = {"name":"Nyx", "class":"Rogue", "hp":100}
	var enemy = {"name":"Orc", "hp":1000, "max_hp":1000, "threat":{}}
	combat.enemies = [enemy]
	if combat.paladin_bulwark_duration(paladin) != 4:
		fail_test("bulwark duration")
		return
	if not combat.paladin_divine_bulwark(paladin, [paladin, ally]):
		fail_test("bulwark activation")
		return
	if combat.effects.mitigate(ally, 100) != 70 or int(paladin["sp"]) != 80:
		fail_test("bulwark mitigation/SP")
		return
	if combat.paladin_divine_bulwark(paladin, [paladin, ally]):
		fail_test("bulwark cooldown")
		return
	for i in range(4):
		combat.effects.tick(ally)
	if combat.effects.mitigate(ally, 100) != 100:
		fail_test("bulwark expiration")
		return
	if not combat.paladin_chivalrous_intervention(paladin, [paladin, ally]):
		fail_test("intervention activation")
		return
	if combat.effects.redirect_target(ally, [paladin, ally]) != paladin:
		fail_test("intervention redirect")
		return
	if int(paladin["sp"]) != 50 or combat.paladin_chivalrous_intervention(paladin, [paladin, ally]):
		fail_test("intervention SP/cooldown")
		return
	combat.effects.tick(ally)
	if combat.effects.redirect_target(ally, [paladin, ally]) != ally:
		fail_test("intervention expiration")
		return
	if combat.paladin_thorns_retribution(paladin, enemy, 100) != 20 or int(enemy["hp"]) != 980:
		fail_test("holy thorns damage")
		return
	print("PASS paladin tank phase 2")
	quit(0)

func fail_test(message: String) -> void:
	printerr("FAIL paladin tank phase 2: " + message)
	quit(1)
