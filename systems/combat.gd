class_name CombatSystem
extends RefCounted


# ============================================================
# COMBAT STATE
# ============================================================

var enemies: Array = []
var combat_log: Array[String] = []

var round_number: int = 1

var party_actions: Array = []

var song_of_courage_active: bool = false

var inventory_system = InventorySystem.new()

# Encounter-local mechanics. All state lives on existing combatant dictionaries.
const CombatEffects = preload("res://systems/combat_effects.gd")
var effects = CombatEffects.new()
var next_combat_key: int = 1

const BASE_HIT_CHANCE: float = 0.65
const BASE_AVOIDANCE: float = 0.05
const MIN_HIT_CHANCE: float = 0.10
const MAX_HIT_CHANCE: float = 0.95

const CLASS_ATTACK_STAT = {
	"Warrior": "str",
	"Paladin": "str",
	"Berserker": "str",
	"Rogue": "dex",
	"Hunter": "dex",
	"Monk": "dex",
	"Bard": "dex",
	"Priest": "str",
	"Shaman": "str",
	"Conjurer": "dex",
	"Magician": "dex",
	"Druid": "str",
	"Warlock": "dex"
}


# ============================================================
# START / RESET
# ============================================================

func start_encounter() -> void:

	enemies.clear()
	combat_log.clear()
	party_actions.clear()

	round_number = 1
	song_of_courage_active = false

	generate_encounter()

	add_log(
		get_encounter_intro_text()
	)


func start_specific_encounter(
	enemy_id: String,
	group_size: int = 1,
	intro_override: String = ""
) -> void:

	enemies.clear()
	combat_log.clear()
	party_actions.clear()

	round_number = 1
	song_of_courage_active = false

	create_enemy_group(enemy_id, group_size)

	if intro_override != "":
		add_log(intro_override)
	else:
		add_log(get_encounter_intro_text())


func start_mixed_encounter(groups: Array, intro_override: String = "") -> void:
	enemies.clear()
	combat_log.clear()
	party_actions.clear()
	round_number = 1
	song_of_courage_active = false
	for group in groups:
		create_enemy_group(str(group.get("enemy_id", "")), int(group.get("count", 1)))
	if intro_override != "":
		add_log(intro_override)
	else:
		add_log(get_encounter_intro_text())


# ============================================================
# ENCOUNTER GENERATION
# ============================================================

func generate_encounter() -> void:

	var encounter_entry = roll_weighted_encounter()

	if encounter_entry.is_empty():

		# This should never normally happen.
		# Skeleton provides a safe fallback if encounter
		# data is accidentally empty or invalid.

		create_enemy_group(
			"skeleton",
			2
		)

		return

	var enemy_id: String = (
		encounter_entry["enemy_id"]
	)

	var min_group: int = (
		encounter_entry["min_group"]
	)

	var max_group: int = (
		encounter_entry["max_group"]
	)

	var group_size = randi_range(
		min_group,
		max_group
	)

	create_enemy_group(
		enemy_id,
		group_size
	)


# ============================================================
# WEIGHTED ENCOUNTER ROLL
# ============================================================

func roll_weighted_encounter() -> Dictionary:

	var encounter_table = (
		GameData.DUNGEON_1_ENCOUNTERS
	)

	if encounter_table.is_empty():
		return {}

	var total_weight = 0

	for entry in encounter_table:

		total_weight += entry["weight"]

	if total_weight <= 0:
		return {}

	var roll = randi_range(
		1,
		total_weight
	)

	var running_weight = 0

	for entry in encounter_table:

		running_weight += entry["weight"]

		if roll <= running_weight:

			return entry

	return encounter_table[
		encounter_table.size() - 1
	]


# ============================================================
# CREATE ENEMY GROUP
# ============================================================

func create_enemy_group(
	enemy_id: String,
	group_size: int
) -> void:

	if not GameData.ENEMIES.has(
		enemy_id
	):
		return

	var enemy_data = (
		GameData.ENEMIES[enemy_id]
	)

	for i in range(
		group_size
	):

		enemies.append(
			create_enemy_from_data(
				enemy_data
			)
		)


# ============================================================
# CREATE COMBAT ENEMY
# ============================================================

func create_enemy_from_data(
	enemy_data: Dictionary
) -> Dictionary:

	return {
		"id": enemy_data["id"],
		"name": enemy_data["name"],

		"hp": enemy_data["hp"],
		"max_hp": enemy_data["hp"],

		"attack": enemy_data["attack"],
		"dex": enemy_data["dex"],
		"base_accuracy": enemy_data.get("base_accuracy", 0.60),
		"base_avoidance": enemy_data.get("base_avoidance", 0.05),
		"absorption": enemy_data.get("absorption", 0),
		"damage_min": enemy_data.get("damage_min", 1),
		"damage_max": enemy_data.get("damage_max", enemy_data["attack"]),

		"xp": enemy_data["xp"],

		"gold_min": enemy_data["gold_min"],
		"gold_max": enemy_data["gold_max"],

		"tags": enemy_data["tags"].duplicate(),
		"threat": {},
		"effects": []
	}


# ============================================================
# ENCOUNTER DESCRIPTION
# ============================================================

func get_encounter_intro_text() -> String:

	if enemies.is_empty():
		return "Something moves in the darkness..."

	var enemy_name = enemies[0]["name"]

	var count = enemies.size()

	if count == 1:

		return (
			"A "
			+ enemy_name
			+ " emerges from the darkness!"
		)

	return (
		str(count)
		+ " "
		+ get_plural_enemy_name(
			enemy_name
		)
		+ " emerge from the darkness!"
	)


func get_plural_enemy_name(
	enemy_name: String
) -> String:

	# Temporary simple pluralization.
	#
	# Later we can store plural names directly in
	# EnemyData for creatures with unusual plurals.

	if enemy_name.ends_with("s"):
		return enemy_name

	return enemy_name + "s"


# ============================================================
# LOG
# ============================================================

func add_log(
	message: String
) -> void:

	combat_log.append(
		message
	)

	while combat_log.size() > 12:

		combat_log.pop_front()


# ============================================================
# ENEMY HELPERS
# ============================================================

func get_living_enemies() -> Array:

	var living = []

	for enemy in enemies:

		if enemy["hp"] > 0:

			living.append(
				enemy
			)

	return living


func resolve_attack_target(selected_target: Dictionary) -> Dictionary:
	if selected_target.is_empty():
		return get_first_living_enemy()
	for enemy in enemies:
		if enemy == selected_target and int(enemy.get("hp", 0)) > 0:
			return enemy
	add_log("Selected target is no longer available.")
	return {}

func get_first_living_enemy() -> Dictionary:

	for enemy in enemies:

		if enemy["hp"] > 0:
			return enemy

	return {}


func all_enemies_defeated() -> bool:

	for enemy in enemies:

		if enemy["hp"] > 0:
			return false

	return true


# ============================================================
# PARTY HELPERS
# ============================================================

func get_living_party(
	party: Array
) -> Array:

	var living = []

	for member in party:

		if member["hp"] > 0:

			living.append(
				member
			)

	return living


func party_defeated(
	party: Array
) -> bool:

	for member in party:

		if member["hp"] > 0:
			return false

	return true


# ============================================================
# ACTION QUEUE
# ============================================================

func clear_actions() -> void:

	party_actions.clear()


func queue_action(
	character: Dictionary,
	action_name: String,
	ability_id: String = "",
	target: Dictionary = {}
) -> void:

	party_actions.append({
		"actor": character,
		"action": action_name,
		"ability_id": ability_id,
		"target": target
	})


# ============================================================
# ROUND RESOLUTION
# ============================================================

func resolve_round(
	party: Array
) -> void:

	add_log("")

	add_log(
		"--- ROUND "
		+ str(round_number)
		+ " ---"
	)

	var turn_order = []

	for action in party_actions:

		var actor = action["actor"]

		if actor["hp"] <= 0:
			continue

		turn_order.append({
			"type": "party",
			"dex": actor["dex"],
			"data": action
		})

	for enemy in enemies:

		if enemy["hp"] <= 0:
			continue

		turn_order.append({
			"type": "enemy",
			"dex": enemy["dex"],
			"data": enemy
		})

	turn_order.sort_custom(
		func(a, b):
			return a["dex"] > b["dex"]
	)

	for turn in turn_order:

		if all_enemies_defeated():
			break

		if party_defeated(party):
			break

		if turn["type"] == "party":

			resolve_party_action(
				turn["data"],
				party
			)

		else:

			resolve_enemy_action(
				turn["data"],
				party
			)

	for combatant in party + enemies:
		effects.tick(combatant)
	party_actions.clear()

	round_number += 1


# ============================================================
# PARTY ACTIONS
# ============================================================

func resolve_party_action(
	action_data: Dictionary,
	party: Array
) -> void:

	var actor = action_data["actor"]

	if actor["hp"] <= 0:
		return

	ensure_warrior_tank_presence(actor)
	var selected_target: Dictionary = action_data.get("target", {})
	var action_name = (
		action_data["action"]
	)

	match action_name:

		"Attack":

			physical_attack(actor, selected_target)

		"Defend":

			defend(
				actor
			)

		"Ability":

			var ability_id: String = str(action_data.get("ability_id", ""))
			if ability_id == "warrior_shield_bash":
				warrior_shield_bash(actor, selected_target)
			elif ability_id == "warrior_taunt":
				warrior_taunt(actor, selected_target)
			elif ability_id == "warrior_disarm":
				warrior_disarm(actor, selected_target)
			elif ability_id == "warrior_shield_wall":
				warrior_shield_wall(actor)
			elif ability_id == "warrior_unbreakable_guardian":
				warrior_unbreakable_guardian(actor, party)
			else:
				use_class_ability(actor, party)


# ============================================================
# BASIC ATTACK
# ============================================================

func physical_attack(
	actor: Dictionary,
	selected_target: Dictionary = {}
) -> void:

	var target = resolve_attack_target(selected_target)

	if target.is_empty():
		return

	var hit_chance = get_character_hit_chance(actor, target)

	if randf() > hit_chance:
		add_log(
			actor["name"] + " attacks " + target["name"]
			+ " but misses. [" + str(int(hit_chance * 100.0)) + "%]"
		)
		return

	var damage = roll_character_damage(actor)
	damage = max(1, damage - int(target.get("absorption", 0)))

	var crit_chance = 0.05 + actor["lck"] * 0.005

	if randf() < crit_chance:
		damage *= 2
		add_log(actor["name"] + " lands a critical hit!")

	damage_enemy(actor, target, damage, "attacks")


func get_character_attack_stat(actor: Dictionary) -> String:
	return CLASS_ATTACK_STAT.get(actor["class"], "str")


func get_character_attack_stat_value(actor: Dictionary) -> int:
	var stat_name = get_character_attack_stat(actor)
	return int(actor.get(stat_name, 10))


func get_stat_accuracy_bonus(stat_value: int) -> float:
	return float(stat_value - 10) * 0.02


func get_stat_damage_bonus(stat_value: int) -> int:
	return int(floor(float(stat_value - 10) / 3.0))


func get_character_hit_chance(
	actor: Dictionary,
	target: Dictionary
) -> float:

	var attack_stat = get_character_attack_stat_value(actor)
	var stat_bonus = get_stat_accuracy_bonus(attack_stat)
	var weapon_accuracy = inventory_system.get_weapon_accuracy(actor)
	var target_avoidance = float(target.get("base_avoidance", 0.05))

	return clamp(
		BASE_HIT_CHANCE + stat_bonus + weapon_accuracy - target_avoidance,
		MIN_HIT_CHANCE,
		MAX_HIT_CHANCE
	)


func roll_character_damage(actor: Dictionary) -> int:

	var attack_stat = get_character_attack_stat_value(actor)
	var stat_bonus = get_stat_damage_bonus(attack_stat)
	var base_damage = randi_range(1, 3)
	var weapon_damage = inventory_system.roll_weapon_damage(actor)

	var damage = base_damage + stat_bonus + weapon_damage

	if song_of_courage_active:
		damage += 2

	return max(1, damage)


# ============================================================
# DEFEND
# ============================================================

func defend(
	actor: Dictionary
) -> void:

	actor["defending"] = true

	add_log(
		actor["name"]
		+ " takes a defensive stance."
	)


# ============================================================
# CLASS ABILITIES
# ============================================================

func use_class_ability(
	actor: Dictionary,
	party: Array
) -> void:

	match actor["class"]:

		"Warrior":

			power_attack(
				actor
			)

		"Paladin":

			guard_ally(
				actor,
				party
			)

		"Berserker":

			rage(
				actor
			)

		"Rogue":

			backstab(
				actor
			)

		"Hunter":

			aimed_shot(
				actor
			)

		"Monk":

			flurry(
				actor
			)

		"Bard":

			song_of_courage(
				actor
			)

		"Priest":

			mend(
				actor,
				party
			)

		"Shaman":

			ancestor_ward(
				actor
			)

		"Conjurer":

			conjure_flame(
				actor
			)

		"Magician":

			arcane_bolt(
				actor
			)

		"Druid":

			regrowth(
				actor,
				party
			)

		"Warlock":

			life_drain(
				actor
			)


# ============================================================
# WARRIOR
# ============================================================

func power_attack(
	actor: Dictionary
) -> void:

	var target = (
		get_first_living_enemy()
	)

	if target.is_empty():
		return

	var damage = (
		randi_range(
			5,
			9
		)
		+ int(
			actor["str"] / 3
		)
	)

	damage_enemy(
		actor,
		target,
		damage,
		"uses Power Attack on"
	)


# ============================================================
# PALADIN
# ============================================================

func guard_ally(
	actor: Dictionary,
	party: Array
) -> void:

	var target = (
		get_most_injured_party_member(
			party
		)
	)

	if target.is_empty():
		return

	target["guarded"] = true

	add_log(
		actor["name"]
		+ " guards "
		+ target["name"]
		+ "."
	)


# ============================================================
# BERSERKER
# ============================================================

func rage(
	actor: Dictionary
) -> void:

	var target = (
		get_first_living_enemy()
	)

	if target.is_empty():
		return

	var damage = (
		randi_range(
			7,
			12
		)
		+ int(
			actor["str"] / 2
		)
	)

	damage_enemy(
		actor,
		target,
		damage,
		"rages against"
	)


# ============================================================
# ROGUE
# ============================================================

func backstab(
	actor: Dictionary
) -> void:

	var target = (
		get_first_living_enemy()
	)

	if target.is_empty():
		return

	var damage = (
		randi_range(
			4,
			8
		)
		+ int(
			actor["dex"] / 3
		)
	)

	if randf() < 0.25:
		damage *= 2

	damage_enemy(
		actor,
		target,
		damage,
		"backstabs"
	)


# ============================================================
# HUNTER
# ============================================================

func aimed_shot(
	actor: Dictionary
) -> void:

	var target = (
		get_first_living_enemy()
	)

	if target.is_empty():
		return

	var damage = (
		randi_range(
			5,
			8
		)
		+ int(
			actor["dex"] / 3
		)
	)

	damage_enemy(
		actor,
		target,
		damage,
		"fires an Aimed Shot at"
	)


# ============================================================
# MONK
# ============================================================

func flurry(
	actor: Dictionary
) -> void:

	var target = (
		get_first_living_enemy()
	)

	if target.is_empty():
		return

	var first_hit = (
		randi_range(
			2,
			5
		)
		+ int(
			actor["dex"] / 5
		)
	)

	var second_hit = (
		randi_range(
			2,
			5
		)
		+ int(
			actor["dex"] / 5
		)
	)

	var damage = (
		first_hit
		+ second_hit
	)

	damage_enemy(
		actor,
		target,
		damage,
		"unleashes a Flurry on"
	)


# ============================================================
# BARD
# ============================================================

func song_of_courage(
	actor: Dictionary
) -> void:

	if song_of_courage_active:

		add_log(
			actor["name"]
			+ " continues the Song of Courage."
		)

		return

	song_of_courage_active = true

	add_log(
		actor["name"]
		+ " begins the Song of Courage!"
	)


# ============================================================
# PRIEST
# ============================================================

func mend(
	actor: Dictionary,
	party: Array
) -> void:

	var target = (
		get_most_injured_party_member(
			party
		)
	)

	if target.is_empty():
		return

	var healing = (
		randi_range(
			4,
			8
		)
		+ int(
			actor["int"] / 4
		)
	)

	heal_character(
		actor,
		target,
		healing,
		"casts Mend on"
	)


# ============================================================
# SHAMAN
# ============================================================

func ancestor_ward(
	actor: Dictionary
) -> void:

	actor["warded"] = true

	add_log(
		actor["name"]
		+ " invokes Ancestor's Ward."
	)


# ============================================================
# CONJURER
# ============================================================

func conjure_flame(
	actor: Dictionary
) -> void:

	var target = (
		get_first_living_enemy()
	)

	if target.is_empty():
		return

	var damage = (
		randi_range(
			4,
			8
		)
		+ int(
			actor["int"] / 3
		)
	)

	damage_enemy(
		actor,
		target,
		damage,
		"conjures flame at"
	)


# ============================================================
# MAGICIAN
# ============================================================

func arcane_bolt(
	actor: Dictionary
) -> void:

	var target = (
		get_first_living_enemy()
	)

	if target.is_empty():
		return

	var damage = (
		randi_range(
			6,
			10
		)
		+ int(
			actor["int"] / 2
		)
	)

	damage_enemy(
		actor,
		target,
		damage,
		"casts Arcane Bolt at"
	)


# ============================================================
# DRUID
# ============================================================

func regrowth(
	actor: Dictionary,
	party: Array
) -> void:

	var target = (
		get_most_injured_party_member(
			party
		)
	)

	if target.is_empty():
		return

	var healing = (
		randi_range(
			3,
			7
		)
		+ int(
			actor["int"] / 4
		)
	)

	heal_character(
		actor,
		target,
		healing,
		"casts Regrowth on"
	)


# ============================================================
# WARLOCK
# ============================================================

func life_drain(
	actor: Dictionary
) -> void:

	var target = (
		get_first_living_enemy()
	)

	if target.is_empty():
		return

	var damage = (
		randi_range(
			5,
			9
		)
		+ int(
			actor["int"] / 3
		)
	)

	damage_enemy(
		actor,
		target,
		damage,
		"drains the life of"
	)

	var healing = max(
		1,
		int(
			damage / 2.0
		)
	)

	actor["hp"] = min(
		actor["max_hp"],
		actor["hp"] + healing
	)

	add_log(
		actor["name"]
		+ " recovers "
		+ str(healing)
		+ " HP."
	)


# ============================================================
# DAMAGE / HEAL HELPERS
# ============================================================

func damage_enemy(
	actor: Dictionary,
	target: Dictionary,
	damage: int,
	verb: String
) -> void:

	target["hp"] -= damage

	if target["hp"] < 0:
		target["hp"] = 0

	add_log(
		actor["name"]
		+ " "
		+ verb
		+ " "
		+ target["name"]
		+ " for "
		+ str(damage)
		+ " damage."
	)

	add_threat(target, actor, float(damage))
	effects.fire_trigger(actor, "damage_dealt", {"target": target, "damage": damage})
	if target["hp"] <= 0:

		add_log(
			target["name"]
			+ " is defeated!"
		)


func heal_character(
	actor: Dictionary,
	target: Dictionary,
	amount: int,
	verb: String
) -> void:

	var old_hp = target["hp"]

	target["hp"] = min(
		target["max_hp"],
		target["hp"] + amount
	)

	var actual_healing = (
		target["hp"]
		- old_hp
	)

	add_log(
		actor["name"]
		+ " "
		+ verb
		+ " "
		+ target["name"]
		+ " for "
		+ str(actual_healing)
		+ " HP."
	)


func get_most_injured_party_member(
	party: Array
) -> Dictionary:

	var result = {}

	var most_missing_hp = 0

	for member in party:

		if member["hp"] <= 0:
			continue

		var missing = (
			member["max_hp"]
			- member["hp"]
		)

		if missing > most_missing_hp:

			most_missing_hp = missing

			result = member

	if result.is_empty():

		for member in party:

			if member["hp"] > 0:
				return member

	return result


# ============================================================
# ENEMY TURN
# ============================================================

func resolve_enemy_action(
	enemy: Dictionary,
	party: Array
) -> void:

	if enemy["hp"] <= 0:
		return

	var living_party = get_living_party(party)

	if living_party.is_empty():
		return

	if effects.has_control(enemy, "stun"):
		add_log(enemy["name"] + " is stunned.")
		return
	var target = select_enemy_target(enemy, living_party)
	var hit_chance = get_enemy_hit_chance(enemy, target)

	if randf() > hit_chance:
		add_log(
			enemy["name"] + " attacks " + target["name"]
			+ " but misses. [" + str(int(hit_chance * 100.0)) + "%]"
		)
		return

	var raw_damage = randi_range(
		int(enemy.get("damage_min", 1)),
		int(enemy.get("damage_max", enemy["attack"]))
	)

	# Interception happens before shield block, so the defender may block.
	var original_target = target
	var guardian = effects.redirect_target(original_target, living_party)
	var intercepted = guardian != original_target
	if intercepted:
		target = guardian
	# A successful shield block prevents this hit and may trigger Riposte.
	if resolve_warrior_block(target, enemy):
		return

	# Disarm modifies physical attack damage before armor.
	raw_damage = maxi(1, int(ceil(float(raw_damage) * (1.0 - effects.total(enemy, "physical_damage_reduction")))))
	var absorption = inventory_system.get_total_absorption(target)
	var damage = max(1, raw_damage - absorption)

	if target.get("defending", false):
		damage = max(1, int(ceil(damage / 2.0)))

	if target.get("guarded", false):
		damage = max(1, int(ceil(damage / 2.0)))

	if target.get("warded", false):
		damage = max(1, damage - 2)

	damage = effects.mitigate(target, damage)
	if intercepted:
		damage = maxi(1, int(ceil(float(damage) * 0.70)))
		# Extra threat is applied to the attacker only, not all enemies.
		add_threat(enemy, target, float(damage), 1.5)
	target["hp"] -= damage
	effects.fire_trigger(target, "damage_taken", {"source": enemy, "damage": damage})

	if target["hp"] < 0:
		target["hp"] = 0

	add_log(
		enemy["name"] + " attacks " + target["name"]
		+ " for " + str(damage) + " damage."
	)

	if target["hp"] <= 0:
		add_log(target["name"] + " falls unconscious!")


func get_enemy_hit_chance(
	enemy: Dictionary,
	target: Dictionary
) -> float:

	var enemy_accuracy = float(enemy.get("base_accuracy", 0.60))
	var target_avoidance = get_character_avoidance(target)

	return clamp(
		enemy_accuracy - target_avoidance,
		MIN_HIT_CHANCE,
		MAX_HIT_CHANCE
	)


func get_character_avoidance(character: Dictionary) -> float:

	var dexterity = int(character.get("dex", 10))
	var dex_bonus = float(dexterity - 10) * 0.01
	var equipment_avoidance = inventory_system.get_total_avoidance(character)

	var avoidance = BASE_AVOIDANCE + dex_bonus + equipment_avoidance

	if character.get("defending", false):
		avoidance += 0.10

	return clamp(avoidance, 0.0, 0.60)


# ============================================================
# ROUND CLEANUP
# ============================================================

func cleanup_round(
	party: Array
) -> void:

	for member in party:

		member["defending"] = false
		member["guarded"] = false
		member["warded"] = false


# ============================================================
# SHARED TANK COMBAT FOUNDATIONS
# ============================================================

func combatant_key(actor: Dictionary) -> String:
	# Runtime instance identity; names are not necessarily unique.
	if not actor.has("combat_key"):
		actor["combat_key"] = str(next_combat_key)
		next_combat_key += 1
	return str(actor["combat_key"])

func add_threat(enemy: Dictionary, actor: Dictionary, amount: float, multiplier: float = 1.0) -> void:
	var table: Dictionary = enemy.get("threat", {})
	var key = combatant_key(actor)
	table[key] = maxf(0.0, float(table.get(key, 0.0)) + amount * multiplier * effects.threat_multiplier(actor))
	enemy["threat"] = table

func add_threat_from_damage(actor: Dictionary, damage: int, multiplier: float = 1.0) -> void:
	for enemy in enemies:
		if int(enemy.get("hp", 0)) > 0:
			add_threat(enemy, actor, float(damage), multiplier)

func select_enemy_target(enemy: Dictionary, living_party: Array) -> Dictionary:
	var forced_key = effects.forced_target(enemy)
	for member in living_party:
		if int(member.get("hp", 0)) > 0 and combatant_key(member) == forced_key:
			return member
	var best: Dictionary = {}
	var highest = -1.0
	var table: Dictionary = enemy.get("threat", {})
	for member in living_party:
		if int(member.get("hp", 0)) <= 0:
			continue
		var score = float(table.get(combatant_key(member), 0.0))
		if score > highest:
			highest = score
			best = member
	return best

func apply_combat_effect(target: Dictionary, effect: Dictionary) -> bool:
	return effects.apply(target, effect)

func use_combat_resource(actor: Dictionary, ability_id: String, sp_cost: int, cooldown: int) -> bool:
	if sp_cost < 0 or cooldown < 0 or int(actor.get("sp", 0)) < sp_cost or effects.cooldown_remaining(actor, ability_id) > 0:
		return false
	actor["sp"] = int(actor.get("sp", 0)) - sp_cost
	effects.set_cooldown(actor, ability_id, cooldown)
	return true


# ============================================================
# WARRIOR TANK: FIRST PLAYABLE SLICE
# ============================================================

func is_warrior_tank(actor: Dictionary) -> bool:
	return str(actor.get("class", "")) == "Warrior" and str(actor.get("specialization", "")) == "tank"

func warrior_tank_unlocked(actor: Dictionary, required_level: int) -> bool:
	return is_warrior_tank(actor) and int(actor.get("level", 1)) >= required_level

func has_equipped_shield(actor: Dictionary) -> bool:
	var off_hand = actor.get("equipment", {}).get("off_hand", null)
	if typeof(off_hand) != TYPE_STRING:
		return false
	if not ItemData.ITEMS.has(off_hand):
		return false
	var item: Dictionary = ItemData.ITEMS[off_hand]
	return str(item.get("slot", "")) == "off_hand" and "shield" in str(item.get("name", "")).to_lower()

func ensure_warrior_tank_presence(actor: Dictionary) -> void:
	if not warrior_tank_unlocked(actor, 9):
		return
	var present = false
	for effect in actor.get("effects", []):
		if str(effect.get("id", "")) == "warrior_defenders_presence":
			present = true
			break
	if not present:
		apply_combat_effect(actor, {"id": "warrior_defenders_presence", "kind": "threat_multiplier", "value": 1.0, "duration": 999999})
	# Shield block bonus is read by future block-resolution integration.

func warrior_shield_bash(actor: Dictionary, selected_target: Dictionary = {}) -> bool:
	if not warrior_tank_unlocked(actor, 10):
		return false
	if not has_equipped_shield(actor):
		add_log(actor.get("name", "Warrior") + " needs a shield for Shield Bash.")
		return false
	var enemy = resolve_attack_target(selected_target)
	if enemy.is_empty():
		return false
	ensure_warrior_tank_presence(actor)
	var damage = maxi(1, roll_character_damage(actor))
	damage_enemy(actor, enemy, damage, "shield bashes")
	# damage_enemy already adds baseline threat, so add only the
	# remaining 2x to reach 3x total (before passive multipliers).
	add_threat(enemy, actor, float(damage), 2.0)
	return true

# Phase 2: explicit enemy-targeted Taunt; shared effect/cooldown infrastructure.
func warrior_taunt(actor: Dictionary, selected_target: Dictionary = {}) -> bool:
	if not warrior_tank_unlocked(actor, 30):
		return false
	var enemy = resolve_attack_target(selected_target)
	if enemy.is_empty():
		return false
	if not use_combat_resource(actor, "warrior_taunt", 5, 4):
		add_log("Taunt unavailable (SP or cooldown).")
		return false
	var table: Dictionary = enemy.get("threat", {})
	var highest: float = 0.0
	for value in table.values():
		highest = maxf(highest, float(value))
	var key = combatant_key(actor)
	table[key] = maxf(float(table.get(key, 0.0)), highest * 1.1 + 1.0)
	enemy["threat"] = table
	add_log(str(actor.get("name", "Warrior")) + " taunts " + str(enemy.get("name", "enemy")) + "!")
	return true


# Warrior Tank Phase 2: shield block and Riposte.
# Optional rolls make these mechanics deterministic in regression tests.
func warrior_block_chance(actor: Dictionary) -> float:
	if not warrior_tank_unlocked(actor, 9) or not has_equipped_shield(actor):
		return 0.0
	return 0.10

func resolve_warrior_block(actor: Dictionary, attacker: Dictionary, block_roll: float = -1.0, riposte_roll: float = -1.0) -> bool:
	var chance = warrior_block_chance(actor)
	if chance <= 0.0:
		return false
	var roll = randf() if block_roll < 0.0 else block_roll
	if roll >= chance:
		return false
	add_log(str(actor.get("name", "Warrior")) + " blocks " + str(attacker.get("name", "enemy")) + "'s attack.")
	if warrior_tank_unlocked(actor, 20) and int(attacker.get("hp", 0)) > 0:
		var counter_roll = randf() if riposte_roll < 0.0 else riposte_roll
		if counter_roll < 0.30:
			var damage = maxi(1, int(round(float(roll_character_damage(actor)) * 0.75)))
			damage_enemy(actor, attacker, damage, "ripostes")
			# Standard damage_enemy grants 1x threat. Add 1x more for 2x total.
			add_threat(attacker, actor, float(damage), 1.0)
	return true


# WARRIOR TANK PHASE 3: uses existing combat effects and cooldowns.
func warrior_disarm(actor: Dictionary, selected_target: Dictionary = {}) -> bool:
	if not warrior_tank_unlocked(actor, 40):
		return false
	var enemy = resolve_attack_target(selected_target)
	if enemy.is_empty():
		return false
	if not use_combat_resource(actor, "warrior_disarm", 8, 5):
		return false
	var is_boss: bool = "boss" in enemy.get("tags", [])
	apply_combat_effect(enemy, {"id": "warrior_disarm", "kind": "physical_damage_reduction", "value": 0.15 if is_boss else 0.30, "duration": 3})
	add_log(str(actor.get("name", "Warrior")) + " disarms " + str(enemy.get("name", "enemy")) + "!")
	return true

func warrior_shield_wall(actor: Dictionary) -> bool:
	if not warrior_tank_unlocked(actor, 50) or not has_equipped_shield(actor):
		return false
	if not use_combat_resource(actor, "warrior_shield_wall", 12, 6):
		return false
	apply_combat_effect(actor, {"id": "warrior_shield_wall", "kind": "damage_reduction", "value": 0.50, "duration": 2})
	add_log(str(actor.get("name", "Warrior")) + " raises Shield Wall!")
	return true

func warrior_unbreakable_guardian(actor: Dictionary, party: Array) -> bool:
	if not warrior_tank_unlocked(actor, 60) or not has_equipped_shield(actor):
		return false
	if not use_combat_resource(actor, "warrior_unbreakable_guardian", 15, 8):
		return false
	var key = combatant_key(actor)
	for ally in party:
		if ally == actor or int(ally.get("hp", 0)) <= 0:
			continue
		apply_combat_effect(ally, {"id": "warrior_unbreakable_guardian", "kind": "redirect", "source_key": key, "duration": 2})
	add_log(str(actor.get("name", "Warrior")) + " protects the party with Unbreakable Guardian!")
	return true
