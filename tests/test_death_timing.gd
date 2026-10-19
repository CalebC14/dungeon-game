extends SceneTree

class FixedCombat extends CombatSystem:
	var victim: Dictionary = {}
	var hit: int = 0
	func resolve_enemy_action(enemy: Dictionary, _party: Array):
		if can_act(enemy) and not victim.is_empty():
			CharacterHealth.damage(victim, hit)
	func resolve_party_action(action: Dictionary, party: Array):
		if action["action"] == "Win":
			enemies[0]["hp"] = 0
		else:
			super.resolve_party_action(action, party)

var failures: Array[String] = []
func check(ok: bool, label: String):
	if not ok:
		failures.append(label)

func member(name_text: String) -> Dictionary:
	var result = CharacterFactory.make_blank_character()
	result.merge({"name": name_text, "class": "Warrior", "hp": 1000, "max_hp": 1000, "dex": 20}, true)
	return result

func _initialize():
	var survivor = member("Survivor")
	var fallen = member("Fallen")
	fallen["hp"] = 1
	var combat = FixedCombat.new()
	combat.enemies = [{"name":"Enemy", "hp":1000, "dex":10}]
	combat.victim = fallen
	combat.hit = 10
	combat.queue_action(survivor, "Defend")
	combat.resolve_round([survivor, fallen])
	check(fallen["hp"] == 0 and fallen["death_rounds_remaining"] == 3, "falling round does not count")
	for remaining in [2, 1, 0]:
		combat.queue_action(survivor, "Defend")
		combat.resolve_round([survivor, fallen])
		check(fallen["death_rounds_remaining"] == remaining, "exactly three subsequent full rounds")
	check(fallen["dead"] and not combat.can_act(fallen), "third tick causes death and blocks actions")
	check(CharacterHealth.heal(fallen, 100) == 0 and fallen["hp"] == 0, "ordinary healing cannot revive dead")
	check(CharacterHealth.resurrect(fallen) and fallen["hp"] == 1, "resurrection restores life to one HP")
	fallen["effects"] = [{"id":"curse", "persistent":true, "duration":-1}]
	CharacterHealth.damage(fallen, 10)
	var snapshot = CharacterHealth.countdown_snapshot([fallen])
	CharacterHealth.complete_round(snapshot)
	check(fallen["death_rounds_remaining"] == 2, "countdown can persist with two remaining")
	check(CharacterHealth.heal(fallen, 5) == 5 and fallen["death_rounds_remaining"] == 3, "healing above zero cancels countdown")
	CharacterHealth.damage(fallen, 5)
	CharacterHealth.complete_round(snapshot)
	check(fallen["death_rounds_remaining"] == 3, "healed then refallen character does not tick old countdown")
	check(fallen["effects"].size() == 1, "healing preserves unrelated conditions")
	# A round cut short by victory must not advance any countdown.
	combat.victim = {}
	combat.enemies[0]["hp"] = 1
	survivor["dex"] = 20
	combat.queue_action(survivor, "Win")
	combat.resolve_round([survivor, fallen])
	check(fallen["death_rounds_remaining"] == 3, "partial victory round pauses countdown")
	combat.enemies[0]["hp"] = 1
	survivor["dex"] = 0
	combat.queue_action(survivor, "Win")
	combat.resolve_round([survivor, fallen])
	check(fallen["death_rounds_remaining"] == 2, "victory on last scheduled turn counts a complete round")
	CharacterHealth.heal(fallen, 1)
	CharacterHealth.damage(fallen, 1)
	survivor["dex"] = 20
	combat.start_specific_encounter("skeleton")
	check(fallen["death_rounds_remaining"] == 3, "new encounter does not reset or advance countdown")
	combat.queue_action(survivor, "Defend")
	combat.resolve_round([survivor, fallen])
	check(fallen["death_rounds_remaining"] == 2, "next encounter resumes on first full round")
	combat.resolve_failed_escape([survivor, fallen])
	check(fallen["death_rounds_remaining"] == 1, "failed escape retaliation counts one complete round")
	var healer = member("Healer")
	check(is_same(combat.get_most_injured_party_member([healer, fallen]), fallen), "automatic healing may target incapacitated ally")
	combat.heal_character(healer, fallen, 10, "heals")
	check(fallen["hp"] == 10 and fallen["death_rounds_remaining"] == 3, "combat healing restores consciousness")
	fallen["dead"] = true
	fallen["hp"] = 0
	check(is_same(combat.get_most_injured_party_member([healer, fallen]), healer), "automatic healing excludes dead ally")
	var effects = combat.effects
	effects.apply(healer, {"id":"poison", "kind":"condition"})
	effects.apply(healer, {"id":"stun", "kind":"control", "duration":2})
	effects.end_encounter(healer)
	check(healer["effects"].size() == 1 and healer["effects"][0]["id"] == "poison", "persistent conditions survive encounter cleanup")
	effects.tick(healer)
	check(healer["effects"].size() == 1, "indefinite poison requires cleansing")
	if failures.is_empty():
		print("PASS exact death timing, recovery, resurrection, and persistent conditions")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
