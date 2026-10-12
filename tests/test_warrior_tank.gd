extends SceneTree

const Combat = preload("res://systems/combat.gd")

func _initialize() -> void:
	var c = Combat.new()
	var tank = {"name": "Test Warrior", "class": "Warrior", "specialization": "tank", "level": 10, "hp": 100, "max_hp": 100, "sp": 20, "str": 15, "dex": 10, "equipment": CharacterFactory.make_empty_equipment(), "inventory": []}
	tank["equipment"]["off_hand"] = "wooden_shield"
	var other = {"name": "Ally", "class": "Rogue", "hp": 100}
	var enemy = {"name": "Test Enemy", "hp": 500, "max_hp": 500, "dex": 1, "attack": 1, "damage_min": 1, "damage_max": 1}
	c.enemies = [enemy]
	c.ensure_warrior_tank_presence(tank)
	if not is_equal_approx(c.effects.threat_multiplier(tank), 2.0):
		fail("Defender's Presence threat multiplier incorrect")
		return
	if not c.warrior_shield_bash(tank):
		fail("Shield Bash rejected a valid equipped shield")
		return
	var threat: Dictionary = enemy.get("threat", {})
	if float(threat.get(c.combatant_key(tank), 0.0)) <= 0.0:
		fail("Shield Bash did not generate threat")
		return
	if c.select_enemy_target(enemy, [other, tank]) != tank:
		fail("Enemy did not select the highest-threat target")
		return
	var old_hp: int = int(enemy["hp"])
	tank["equipment"]["off_hand"] = null
	if c.warrior_shield_bash(tank) or int(enemy["hp"]) != old_hp:
		fail("Shield Bash succeeded without a shield")
		return
	print("PASS warrior tank first slice")
	quit(0)

func fail(message: String) -> void:
	printerr("FAIL warrior tank: " + message)
	quit(1)
