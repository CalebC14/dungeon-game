extends SceneTree
const Combat = preload("res://systems/combat.gd")
func _initialize() -> void:
	var combat = Combat.new()
	var a = {"name": "A", "hp": 30, "max_hp": 30, "threat": {}}
	var b = {"name": "B", "hp": 30, "max_hp": 30, "threat": {}}
	combat.enemies = [a, b]
	if combat.resolve_attack_target(b) != b:
		_fail("Selected living target")
		return
	b["hp"] = 0
	if not combat.resolve_attack_target(b).is_empty():
		_fail("Dead target rejected")
		return
	if combat.resolve_attack_target(a) != a:
		_fail("Living target retained")
		return
	var outsider = {"name": "Outsider", "hp": 100}
	if not combat.resolve_attack_target(outsider).is_empty():
		_fail("Non-encounter target rejected")
		return
	print("PASS target selection")
	quit(0)
func _fail(reason: String) -> void:
	printerr("FAIL target selection: " + reason)
	quit(1)
