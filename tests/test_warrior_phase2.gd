extends SceneTree

const Combat = preload("res://systems/combat.gd")

func _initialize() -> void:
	var combat = Combat.new()
	var warrior = {
		"name": "Brann", "class": "Warrior", "specialization": "tank",
		"level": 30, "hp": 100, "sp": 20, "str": 15, "dex": 10,
		"equipment": {"weapon": null, "off_hand": "wooden_shield"}
	}
	var enemy = {"name": "Orc", "hp": 1000, "max_hp": 1000, "attack": 1, "damage_min": 1, "damage_max": 1, "threat": {}}
	combat.enemies = [enemy]
	if not is_equal_approx(combat.warrior_block_chance(warrior), 0.10):
		_fail("Defender's Presence shield block")
		return
	if not combat.resolve_warrior_block(warrior, enemy, 0.05, 0.99):
		_fail("Guaranteed block")
		return
	if combat.resolve_warrior_block(warrior, enemy, 0.5, 0.0):
		_fail("Failed block roll")
		return
	var hp_before = int(enemy["hp"])
	if not combat.resolve_warrior_block(warrior, enemy, 0.0, 0.0):
		_fail("Riposte block")
		return
	if int(enemy["hp"]) >= hp_before:
		_fail("Riposte damage")
		return
	warrior["equipment"]["off_hand"] = null
	if combat.warrior_block_chance(warrior) != 0.0:
		_fail("Shield requirement")
		return
	warrior["equipment"]["off_hand"] = "wooden_shield"
	combat.add_threat(enemy, {"name": "Ally", "hp": 100}, 100.0)
	if not combat.warrior_taunt(warrior):
		_fail("Taunt activation")
		return
	if int(warrior["sp"]) != 15 or int(combat.effects.cooldown_remaining(warrior, "warrior_taunt")) != 4:
		_fail("Taunt resource cost")
		return
	if combat.warrior_taunt(warrior):
		_fail("Taunt cooldown")
		return
	print("PASS warrior tank phase 2")
	quit(0)

func _fail(message: String) -> void:
	printerr("FAIL warrior tank phase 2: " + message)
	quit(1)
