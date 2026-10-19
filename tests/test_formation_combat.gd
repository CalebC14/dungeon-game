extends SceneTree

const Combat = preload("res://systems/combat.gd")
const Party = preload("res://systems/party.gd")
var failures: Array[String] = []

func check(ok: bool, label: String):
	if not ok:
		failures.append(label)

func member(name_text: String, weapon = "iron_sword") -> Dictionary:
	var actor = CharacterFactory.make_blank_character()
	actor.merge({"name": name_text, "class": "Warrior", "hp": 100, "max_hp": 100, "dex": 20, "str": 20, "lck": 0}, true)
	actor["equipment"]["weapon"] = weapon
	return actor

func _initialize():
	seed(10)
	var model = Party.new()
	var front = member("Front")
	var rear = member("Rear")
	var reserve = member("Reserve")
	for actor in [front, rear, reserve]:
		model.register_character(actor)
	model.assign_member(front["character_id"], 0, true)
	model.assign_member(rear["character_id"], 3, true)
	var combat = Combat.new()
	combat.formation = model
	var enemy = combat.create_enemy_from_data(GameData.ENEMIES["skeleton"])
	enemy["hp"] = 10000
	combat.enemies = [enemy]
	combat.add_threat(enemy, rear, 100)
	combat.add_threat(enemy, front, 10)
	check(is_same(combat.select_enemy_target(enemy, model.active_members()), front), "front eligibility wins over rear threat")
	combat.apply_combat_effect(enemy, {"id": "test_taunt", "kind": "forced_target", "source_key": combat.combatant_key(rear), "duration": 3})
	check(is_same(combat.select_enemy_target(enemy, model.active_members()), front), "taunt cannot bypass protected rear")
	enemy["attack_range"] = "ranged"
	check(is_same(combat.select_enemy_target(enemy, model.active_members()), rear), "ranged taunt reaches rear")
	enemy["effects"] = []
	check(is_same(combat.select_enemy_target(enemy, model.active_members()), rear), "ranged threat reaches rear")
	enemy["attack_range"] = "melee"
	front["hp"] = 0
	check(is_same(combat.select_enemy_target(enemy, model.active_members()), rear), "fallen front exposes rear without moving slots")
	check(model.slots[3] == rear["character_id"], "collapse does not rearrange persistent positions")
	front["hp"] = 1
	check(is_same(combat.select_enemy_target(enemy, model.active_members()), front), "healing restores front protection")
	check(float(enemy["threat"][combat.combatant_key(rear)]) == 100.0, "ineligible threat retained")
	combat.apply_combat_effect(front, {"id": "stun", "kind": "control", "duration": 2})
	check(is_same(combat.select_enemy_target(enemy, model.active_members()), rear), "unable to defend front exposes rear")
	front["effects"] = []
	check(combat.reachable_targets(rear, combat.enemies).is_empty(), "rear ordinary melee cannot attack")
	var original_hp = enemy["hp"]
	combat.physical_attack(rear, enemy)
	check(enemy["hp"] == original_hp, "direct physical attack enforces own row")
	combat.power_attack(rear)
	check(enemy["hp"] == original_hp, "physical class skill cannot bypass row")
	rear["equipment"]["weapon"] = "quarterstaff"
	check(combat.reachable_targets(rear, combat.enemies).size() == 1, "reach weapon attacks from rear")
	var enemy_rear = enemy.duplicate(true)
	enemy_rear["name"] = "Rear enemy"
	enemy_rear["formation_slot"] = 3
	combat.enemies.append(enemy_rear)
	check(combat.reachable_targets(rear, combat.enemies).size() == 1, "reach still targets opposing front")
	rear["equipment"]["weapon"] = "short_bow"
	check(combat.reachable_targets(rear, combat.enemies).size() == 2, "bow bypasses row protection")
	check(combat.reachable_targets(rear, combat.enemies, "magic").size() == 2, "magic bypasses row protection")
	check(combat.resolve_reachable_target(front, enemy_rear).is_empty(), "illegal selected rear target rejected at resolution")
	enemy["hp"] = 0
	check(is_same(combat.resolve_reachable_target(front), enemy_rear), "opposing collapse exposes rear")
	check(not model.reposition(reserve["character_id"], 1), "free formation movement cannot recruit a reserve")
	check(not combat.reposition_actor(front, -1), "invalid combat destination rejected")
	check(not combat.reposition_actor(front, 6), "out of bounds combat destination rejected")
	check(model.reposition(rear["character_id"], 0), "active members may swap")
	check(model.slots[3] == front["character_id"], "swap retains displaced character")
	front["hp"] = 0
	check(not combat.reposition_actor(front, 2), "down character cannot move")
	front["hp"] = 100
	combat.apply_combat_effect(front, {"id": "stun", "kind": "control", "duration": 2})
	check(not combat.reposition_actor(front, 2), "stunned character cannot move")
	front["effects"] = []
	# Queued movement resolves in initiative and uses the canonical saved slots.
	combat.enemies = [enemy_rear]
	enemy_rear["dex"] = 0
	front["dex"] = 100
	var before_hp = enemy_rear["hp"]
	combat.queue_action(front, "Reposition", "", {}, 2)
	combat.queue_action(rear, "Defend")
	combat.resolve_round(model.active_members())
	check(model.slots[2] == front["character_id"] and model.slots[3] == "", "queued movement applied")
	check(enemy_rear["hp"] == before_hp, "reposition uses action instead of attacking")
	check(combat.party_actions.is_empty() and combat.round_number == 2, "movement completes normal combat round")
	var restored = Party.new()
	check(restored.restore(JSON.parse_string(JSON.stringify(model.to_data()))), "combat formation serializes")
	check(restored.slots == model.slots, "combat movement persists exactly")
	var archer = combat.create_enemy_from_data(GameData.ENEMIES["bandit_archer"])
	check(combat.attack_range(archer) == "ranged", "enemy range metadata survives creation")
	if failures.is_empty():
		print("PASS combat formation, reach, collapse, threat, and repositioning")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
