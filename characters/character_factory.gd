class_name CharacterFactory
extends RefCounted


static func make_blank_character() -> Dictionary:

	return {
		"name": "",
		"gender": "",
		"subject_pronoun": "",
		"object_pronoun": "",
		"possessive_pronoun": "",
		"race": "",
		"race_trait": "",
		"class": "",
		"base_str": 0,
		"base_int": 0,
		"base_dex": 0,
		"base_con": 0,
		"base_lck": 0,
		"str": 0,
		"int": 0,
		"dex": 0,
		"con": 0,
		"lck": 0,
		"level": 1,
		"xp": 0,
		"hp": 0,
		"max_hp": 0,
		"equipment": make_empty_equipment(),
		"inventory": []
	}


static func make_empty_equipment() -> Dictionary:

	return {
		"weapon": null,
		"off_hand": null,
		"head": null,
		"body": null,
		"hands": null,
		"feet": null,
		"accessory_1": null,
		"accessory_2": null,
		"trinket": null
	}


static func roll_d6() -> int:

	return randi_range(
		1,
		6
	)


static func roll_3d6() -> int:

	return (
		roll_d6()
		+ roll_d6()
		+ roll_d6()
	)


static func roll_stats(
	character: Dictionary
):

	character["base_str"] = roll_3d6()
	character["base_int"] = roll_3d6()
	character["base_dex"] = roll_3d6()
	character["base_con"] = roll_3d6()
	character["base_lck"] = roll_3d6()


static func apply_race(
	character: Dictionary,
	race: Dictionary
):

	character["race"] = race["name"]
	character["race_trait"] = race["trait"]

	var mods = race["mods"]

	character["str"] = max(
		1,
		character["base_str"] + mods["str"]
	)

	character["int"] = max(
		1,
		character["base_int"] + mods["int"]
	)

	character["dex"] = max(
		1,
		character["base_dex"] + mods["dex"]
	)

	character["con"] = max(
		1,
		character["base_con"] + mods["con"]
	)

	character["lck"] = max(
		1,
		character["base_lck"] + mods["lck"]
	)

	character["max_hp"] = (
		10
		+ character["con"]
	)

	character["hp"] = (
		character["max_hp"]
	)


static func apply_gender(
	character: Dictionary,
	gender: String
):

	character["gender"] = gender

	match gender:

		"Male":

			character["subject_pronoun"] = "he"
			character["object_pronoun"] = "him"
			character["possessive_pronoun"] = "his"

		"Female":

			character["subject_pronoun"] = "she"
			character["object_pronoun"] = "her"
			character["possessive_pronoun"] = "her"

		"Nonbinary":

			character["subject_pronoun"] = "they"
			character["object_pronoun"] = "them"
			character["possessive_pronoun"] = "their"


static func qualifies_for_class(
	character: Dictionary,
	class_data: Dictionary
) -> bool:

	for stat in class_data["requirements"]:

		if (
			character[stat]
			< class_data["requirements"][stat]
		):
			return false

	return true
