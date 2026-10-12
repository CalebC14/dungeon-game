extends SceneTree
const Combat = preload("res://systems/combat.gd")

func _initialize() -> void:
	var combat = Combat.new()
	var paladin = {"name": "Aldren", "class": "Paladin", "specialization": "tank", "level": 30, "hp": 100, "sp": 20, "str": 15, "dex": 10, "equipment": {"weapon": null, "off_hand": "wooden_shield"}}
	var ally = {"name": "Nyx", "class": "Rogue", "hp": 100}
	var enemy = {"name": "Orc", "hp": 1000, "max_hp": 1000, "attack": 1, "damage_min": 1, "damage_max": 1, "threat": {}}
	combat.enemies = [enemy]
	combat.ensure_paladin_tank_presence(paladin)
	if not is_equal_approx(combat.effects.threat_multiplier(paladin), 2.0):
		_fail("Sacred Guardian threat")
		return
	if combat.paladin_sacred_guardian_mitigate(paladin, 100) != 90:
		_fail("Sacred Guardian damage")
		return
	if combat.paladin_valiant_protector_mitigate(ally, 100, [paladin, ally], 0.0) != 75:
		_fail("Valiant Protector trigger")
		return
	if combat.paladin_valiant_protector_mitigate(ally, 100, [paladin, ally], 0.99) != 100:
		_fail("Valiant Protector no trigger")
		return
	if not combat.paladin_shield_bash(paladin, enemy):
		_fail("Shield Bash")
		return
	if not combat.paladin_taunt(paladin, enemy) or int(paladin["sp"]) != 15:
		_fail("Taunt SP")
		return
	if combat.paladin_taunt(paladin, enemy):
		_fail("Taunt cooldown")
		return
	print("PASS paladin tank phase 1")
	quit(0)

func _fail(message: String) -> void:
	printerr("FAIL paladin tank phase 1: " + message)
	quit(1)
