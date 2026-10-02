class_name TestParty
extends RefCounted


static func create() -> Array:

	var party: Array = []

	party.append(
		make_character(
			"Brann",
			"Male",
			"Human",
			"Adaptable",
			"Warrior",
			16,
			8,
			12,
			15,
			11,
			[
				"iron_sword",
				"wooden_shield",
				"chain_shirt",
				"healing_potion"
			]
		)
	)

	party.append(
		make_character(
			"Thora",
			"Female",
			"Dwarf",
			"Stout",
			"Paladin",
			15,
			9,
			9,
			16,
			12,
			[
				"battle_axe",
				"wooden_shield",
				"leather_armor",
				"healing_potion"
			]
		)
	)

	party.append(
		make_character(
			"Nyx",
			"Nonbinary",
			"Goblin",
			"Skulker",
			"Rogue",
			9,
			11,
			17,
			11,
			15,
			[
				"iron_sword",
				"leather_armor",
				"leather_boots",
				"healing_potion"
			]
		)
	)

	party.append(
		make_character(
			"Elowen",
			"Female",
			"Elf",
			"Arcane Blood",
			"Magician",
			8,
			17,
			14,
			10,
			11,
			[
				"quarterstaff",
				"silver_ring",
				"healing_potion"
			]
		)
	)

	party.append(
		make_character(
			"Merrick",
			"Male",
			"Half-Elf",
			"Versatile",
			"Bard",
			10,
			14,
			14,
			11,
			14,
			[
				"short_bow",
				"leather_armor",
				"lucky_charm",
				"healing_potion"
			]
		)
	)

	party.append(
		make_character(
			"Aldren",
			"Male",
			"Human",
			"Adaptable",
			"Priest",
			10,
			14,
			10,
			13,
			16,
			[
				"quarterstaff",
				"wooden_shield",
				"leather_armor",
				"healing_potion"
			]
		)
	)

	return party


static func make_character(
	character_name: String,
	gender: String,
	race: String,
	race_trait: String,
	character_class: String,
	strength: int,
	intelligence: int,
	dexterity: int,
	constitution: int,
	luck: int,
	starting_items: Array
) -> Dictionary:

	var character = (
		CharacterFactory.make_blank_character()
	)

	character["name"] = character_name
	character["race"] = race
	character["race_trait"] = race_trait
	character["class"] = character_class

	character["str"] = strength
	character["int"] = intelligence
	character["dex"] = dexterity
	character["con"] = constitution
	character["lck"] = luck

	character["base_str"] = strength
	character["base_int"] = intelligence
	character["base_dex"] = dexterity
	character["base_con"] = constitution
	character["base_lck"] = luck

	character["level"] = 1
	character["xp"] = 0

	character["max_hp"] = (
		10
		+ constitution
	)

	character["hp"] = (
		character["max_hp"]
	)

	CharacterFactory.apply_gender(
		character,
		gender
	)

	for item_id in starting_items:

		character["inventory"].append(
			item_id
		)

	return character
