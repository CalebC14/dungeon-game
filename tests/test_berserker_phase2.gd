extends SceneTree
const Combat = preload("res://systems/combat.gd")

func _initialize() -> void:
	var combat = Combat.new()
	var tank: Dictionary = {"name":"Rusk", "class":"Berserker", "specialization":"tank", "level":60, "hp":200, "sp":100, "str":18, "dex":10, "lck":0, "equipment":{"weapon":"battle_axe", "off_hand":null}}
	var ally: Dictionary = {"name":"Scout", "class":"Rogue", "hp":100, "dex":10, "equipment":{"weapon":null}}
	var enemy: Dictionary = {"name":"Raider", "hp":2000, "attack":10, "damage_min":10, "damage_max":10, "threat":{}, "base_accuracy":0.95}
	var other: Dictionary = {"name":"Guard", "hp":2000, "attack":10, "threat":{}}
	combat.enemies = [enemy, other]
	var party: Array = [tank, ally]
	if not combat.berserker_has_melee_weapon(tank):
		fail_test("melee weapon recognition")
		return
	if not combat.berserker_savage_intervention(tank, party, ally):
		fail_test("Savage Intervention activation")
		return
	if int(tank["sp"]) != 90 or combat.berserker_savage_intervention(tank, party, ally):
		fail_test("Savage Intervention cost/cooldown")
		return
	if not combat.berserker_consume_savage_intervention(ally, tank) or combat.berserker_consume_savage_intervention(ally, tank):
		fail_test("Savage Intervention one-hit consumption")
		return
	var before_hp: int = int(enemy["hp"])
	combat.ensure_berserker_tank_presence(tank)
	combat.berserker_savage_counterattack(tank, enemy)
	if int(enemy["hp"]) >= before_hp or float(enemy["threat"].get(combat.combatant_key(tank), 0.0)) <= 0.0:
		fail_test("Savage counterattack damage/threat")
		return
	for i in range(5):
		combat.berserker_untouchable_on_dodge(tank)
	if absf(combat.effects.total(tank, "berserker_untouchable_damage") - 0.30) > 0.001 or absf(combat.effects.total(tank, "berserker_untouchable_threat") - 0.75) > 0.001:
		fail_test("Untouchable stack caps")
		return
	if combat.berserker_untouchable_damage(tank, 100) != 130:
		fail_test("Untouchable damage")
		return
	var old_avoid: float = combat.get_character_avoidance(tank)
	if not combat.berserker_dance_of_carnage(tank):
		fail_test("Dance of Carnage activation")
		return
	if int(tank["sp"]) != 65 or combat.berserker_dance_of_carnage(tank):
		fail_test("Dance of Carnage cost/cooldown")
		return
	if combat.get_character_avoidance(tank) < old_avoid + 0.19 or int(other["hp"]) >= 2000:
		fail_test("Dance of Carnage AOE/dodge")
		return
	combat.effects.tick(tank)
	combat.effects.tick(tank)
	combat.effects.tick(tank)
	if combat.effects.total(tank, "berserker_dodge_bonus") != 0.0 or combat.effects.total(tank, "berserker_untouchable_damage") != 0.0:
		fail_test("effect expiration")
		return
	print("PASS berserker tank phase 2")
	quit(0)

func fail_test(message: String) -> void:
	printerr("FAIL berserker tank phase 2: " + message)
	quit(1)
