extends SceneTree
const Combat = preload("res://systems/combat.gd")
func _initialize() -> void:
	var c = Combat.new()
	var tank = {"name":"Tank","class":"Warrior","specialization":"tank","level":60,"hp":100,"sp":100,"equipment":{"weapon":null,"off_hand":"wooden_shield"}}
	var ally = {"name":"Ally","hp":100,"equipment":{"weapon":null,"off_hand":null}}
	var enemy = {"name":"Orc","hp":100,"tags":[],"threat":{}}
	c.enemies = [enemy]
	if not c.warrior_disarm(tank) or not is_equal_approx(c.effects.total(enemy,"physical_damage_reduction"),0.30):
		fail("Disarm")
		return
	if c.warrior_disarm(tank):
		fail("Disarm cooldown")
		return
	c.effects.tick(enemy)
	c.effects.tick(enemy)
	c.effects.tick(enemy)
	if c.effects.total(enemy,"physical_damage_reduction") != 0.0:
		fail("Disarm expiry")
		return
	if not c.warrior_shield_wall(tank) or c.effects.mitigate(tank,100) != 50:
		fail("Shield Wall mitigation")
		return
	if not c.warrior_unbreakable_guardian(tank,[tank,ally]):
		fail("Guardian activation")
		return
	if c.effects.redirect_target(ally,[tank,ally]) != tank:
		fail("Guardian redirection")
		return
	c.effects.tick(ally)
	c.effects.tick(ally)
	if c.effects.redirect_target(ally,[tank,ally]) != ally:
		fail("Guardian expiry")
		return
	if int(tank["sp"]) != 65:
		fail("SP costs")
		return
	print("PASS warrior tank phase 3")
	quit(0)
func fail(message: String) -> void:
	printerr("FAIL warrior tank phase 3: " + message)
	quit(1)
