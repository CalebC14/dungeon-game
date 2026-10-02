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

		"tags": enemy_data["tags"].duplicate()
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
	action_name: String
) -> void:

	party_actions.append({
		"actor": character,
		"action": action_name
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

	var action_name = (
		action_data["action"]
	)

	match action_name:

		"Attack":

			physical_attack(
				actor
			)

		"Defend":

			defend(
				actor
			)

		"Ability":

			use_class_ability(
				actor,
				party
			)


# ============================================================
# BASIC ATTACK
# ============================================================

func physical_attack(
	actor: Dictionary
) -> void:

	var target = get_first_living_enemy()

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

	var target = living_party.pick_random()
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

	var absorption = inventory_system.get_total_absorption(target)
	var damage = max(1, raw_damage - absorption)

	if target.get("defending", false):
		damage = max(1, int(ceil(damage / 2.0)))

	if target.get("guarded", false):
		damage = max(1, int(ceil(damage / 2.0)))

	if target.get("warded", false):
		damage = max(1, damage - 2)

	target["hp"] -= damage

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
