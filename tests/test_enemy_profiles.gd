extends SceneTree
var failures: Array[String] = []
func check(ok: bool, label: String):
	if not ok: failures.append(label)
func actor(label: String) -> Dictionary:
	var member = CharacterFactory.make_blank_character()
	member.merge({"name":label,"class":"Warrior","hp":100,"max_hp":100}, true)
	return member
func _initialize():
	var combat = CombatSystem.new()
	var model = PartySystem.new()
	var tank = actor("Tank")
	var ally = actor("Ally")
	var rear = actor("Rear")
	for member in [tank,ally,rear]: model.register_character(member)
	model.assign_member(tank["character_id"],0,true)
	model.assign_member(ally["character_id"],1,true)
	model.assign_member(rear["character_id"],3,true)
	combat.formation = model
	var party = model.active_members()
	var rat = combat.create_enemy_from_data(GameData.ENEMIES["giant_rat"])
	check(rat["behavior"] == "opportunistic" and rat["opportunism_chance"] == 0.30, "rat data selects configured profile")
	combat.add_threat(rat,tank,100)
	rat["opportunism_chance"] = 0.0
	check(is_same(combat.select_enemy_target(rat,party),tank), "zero chance follows threat")
	rat["opportunism_chance"] = 1.0
	check(is_same(combat.select_enemy_target(rat,party),ally) and "darts toward Ally" in combat.combat_log[-1], "opportunism switches to another reachable front with feedback")
	combat.apply_combat_effect(rat,{"id":"taunt","kind":"forced_target","source_key":combat.combatant_key(tank),"duration":2})
	check(is_same(combat.select_enemy_target(rat,party),tank), "reachable taunt overrides guaranteed opportunism")
	rat["effects"] = []
	ally["hp"] = 0
	check(is_same(combat.select_enemy_target(rat,party),tank), "only reachable member cannot be bypassed for rear target")
	tank["hp"] = 0
	check(is_same(combat.select_enemy_target(rat,party),rear), "rear exposed when front collapses")
	rear["hp"] = 0
	check(combat.select_enemy_target(rat,party).is_empty(), "no living targets returns empty")
	for member in party: member["hp"] = 100
	var boss = combat.create_enemy_from_data(GameData.ENEMIES["rat_broodmother"])
	combat.add_threat(boss,tank,100)
	check(boss["behavior"] == "threat" and is_same(combat.select_enemy_target(boss,party),tank), "unconfigured boss preserves threat default")
	boss["behavior"] = "unknown_future_profile"
	check(is_same(combat.select_enemy_target(boss,party),tank), "unknown profile safely uses threat")
	rat["opportunism_chance"] = 0.30
	seed(1234)
	var switches = 0
	for i in range(100):
		if is_same(combat.select_enemy_target(rat,party),ally): switches += 1
	check(switches > 0 and switches < 100, "configured rat behavior takes both paths")
	# Exercise actual attack resolution with the selected alternate target.
	rat["opportunism_chance"] = 1.0
	rat["base_accuracy"] = 1.0
	rat["damage_min"] = 10
	rat["damage_max"] = 10
	for i in range(10):
		combat.resolve_enemy_action(rat,party)
		if ally["hp"] < 100: break
	check(ally["hp"] < 100 and tank["hp"] == 100 and rear["hp"] == 100, "actual rat attack damages alternate reachable member only")
	if failures.is_empty():
		print("PASS enemy profiles, threat defaults, taunts, formation, and real attacks")
		quit(0)
	else:
		for label in failures: push_error(label)
		quit(1)
