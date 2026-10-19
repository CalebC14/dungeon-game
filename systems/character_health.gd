class_name CharacterHealth
extends RefCounted

const DEATH_ROUNDS = 3

static func ensure(character: Dictionary):
	character["dead"] = bool(character.get("dead", false))
	character["incapacitation_generation"] = int(character.get("incapacitation_generation", 0))
	if character["dead"]:
		character["hp"] = 0
		character["death_rounds_remaining"] = 0
	elif int(character.get("hp", 0)) > 0:
		character["death_rounds_remaining"] = DEATH_ROUNDS
	else:
		character["hp"] = 0
		character["death_rounds_remaining"] = clampi(int(character.get("death_rounds_remaining", DEATH_ROUNDS)), 1, DEATH_ROUNDS)

static func conscious(character: Dictionary) -> bool:
	return not bool(character.get("dead", false)) and int(character.get("hp", 0)) > 0

static func damage(character: Dictionary, amount: int) -> int:
	ensure(character)
	if not conscious(character) or amount <= 0:
		return 0
	var before = int(character["hp"])
	character["hp"] = maxi(0, before - amount)
	if character["hp"] == 0:
		character["death_rounds_remaining"] = DEATH_ROUNDS
		character["incapacitation_generation"] += 1
		for flag in ["defending", "guarded", "warded"]:
			character[flag] = false
	return before - int(character["hp"])

static func heal(character: Dictionary, amount: int) -> int:
	ensure(character)
	if character["dead"] or amount <= 0:
		return 0
	var before = int(character["hp"])
	character["hp"] = mini(int(character.get("max_hp", before)), before + amount)
	if character["hp"] > 0:
		character["death_rounds_remaining"] = DEATH_ROUNDS
	return int(character["hp"]) - before

static func resurrect(character: Dictionary, hp: int = 1) -> bool:
	ensure(character)
	if not character["dead"] or hp <= 0:
		return false
	character["dead"] = false
	character["hp"] = clampi(hp, 1, maxi(1, int(character.get("max_hp", 1))))
	character["death_rounds_remaining"] = DEATH_ROUNDS
	return true

static func countdown_snapshot(party: Array) -> Array:
	var snapshot: Array = []
	for character in party:
		ensure(character)
		if not character["dead"] and character["hp"] == 0:
			snapshot.append({"character": character, "generation": character["incapacitation_generation"]})
	return snapshot

static func complete_round(snapshot: Array) -> Array:
	var deaths: Array = []
	for entry in snapshot:
		var character: Dictionary = entry["character"]
		if conscious(character) or bool(character.get("dead", false)) or character.get("incapacitation_generation", 0) != entry["generation"]:
			continue
		character["death_rounds_remaining"] = maxi(0, int(character["death_rounds_remaining"]) - 1)
		if character["death_rounds_remaining"] == 0:
			character["dead"] = true
			deaths.append(character)
	return deaths

static func status(character: Dictionary) -> String:
	if bool(character.get("dead", false)):
		return "DEAD — resurrection required"
	if int(character.get("hp", 0)) <= 0:
		return "INCAPACITATED — %d rounds remaining" % int(character.get("death_rounds_remaining", DEATH_ROUNDS))
	return "Conscious"
