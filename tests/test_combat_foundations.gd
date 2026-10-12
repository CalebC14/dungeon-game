extends SceneTree

const Effects = preload("res://systems/combat_effects.gd")
const Combat = preload("res://systems/combat.gd")
var failures: Array[String] = []

func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _initialize() -> void:
	var fx = Effects.new()
	var combat = Combat.new()
	var a = {"name":"A", "hp":20, "sp":10}
	var b = {"name":"B", "hp":20, "sp":10}
	var enemy = {"hp":20, "threat":{}, "effects":[]}
	combat.add_threat(enemy, a, 10.0)
	combat.add_threat(enemy, b, 20.0)
	check(combat.select_enemy_target(enemy, [a,b]) == b, "highest threat")
	combat.apply_combat_effect(enemy, {"id":"taunt", "kind":"forced_target", "source_key":combat.combatant_key(a), "duration":2})
	check(combat.select_enemy_target(enemy, [a,b]) == a, "forced target")
	fx.tick(enemy)
	check(combat.select_enemy_target(enemy, [a,b]) == a, "duration persists")
	fx.tick(enemy)
	check(combat.select_enemy_target(enemy, [a,b]) == b, "duration expires")
	fx.apply(a, {"id":"shield", "kind":"damage_reduction", "value":0.1, "duration":3, "max_stacks":3})
	fx.apply(a, {"id":"shield", "kind":"damage_reduction", "value":0.1, "duration":3, "max_stacks":3})
	check(fx.mitigate(a, 20) == 16, "stacked mitigation")
	check(combat.use_combat_resource(a, "bash", 4, 2), "resource use")
	check(a["sp"] == 6 and not combat.use_combat_resource(a, "bash", 4, 2), "cooldown blocks")
	fx.tick(a)
	fx.tick(a)
	check(fx.cooldown_remaining(a, "bash") == 0, "cooldown expires")
	if failures.is_empty():
		print("PASS combat foundations")
		quit(0)
	else:
		for message in failures:
			push_error("FAIL: " + message)
		quit(1)
