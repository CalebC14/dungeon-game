extends RefCounted

# Effects: {id, kind, value, duration, stacks?, max_stacks?, source_key?}.
# Duration is measured in completed rounds. A fresh effect survives its first tick.
func apply(target: Dictionary, effect: Dictionary) -> bool:
	if effect.get("kind", "") == "control":
		if randf() < resistance(target, str(effect.get("id", ""))):
			return false
	var active: Array = target.get("effects", [])
	var incoming = effect.duplicate(true)
	incoming["persistent"] = bool(incoming.get("persistent", str(incoming.get("id", "")) in ["poison", "curse", "disease", "paralysis", "petrify"]))
	var duration = int(incoming.get("duration", -1 if incoming["persistent"] else 1))
	incoming["duration"] = -1 if duration < 0 and incoming["persistent"] else maxi(1, duration)
	incoming["stacks"] = maxi(1, int(incoming.get("stacks", 1)))
	for existing in active:
		if str(existing.get("id", "")) == str(incoming.get("id", "")) and str(existing.get("source_key", "")) == str(incoming.get("source_key", "")):
			existing["stacks"] = mini(int(incoming.get("max_stacks", existing.get("max_stacks", 1))), int(existing.get("stacks", 1)) + int(incoming["stacks"]))
			existing["persistent"] = incoming["persistent"]
			existing["duration"] = -1 if int(existing.get("duration", 1)) == -1 or int(incoming["duration"]) == -1 else maxi(int(existing.get("duration", 1)), int(incoming["duration"]))
			target["effects"] = active
			return true
	active.append(incoming)
	target["effects"] = active
	return true

func tick(target: Dictionary) -> void:
	var remaining: Array = []
	for effect in target.get("effects", []):
		if int(effect.get("duration", 1)) == -1:
			remaining.append(effect)
			continue
		effect["duration"] = int(effect.get("duration", 1)) - 1
		if int(effect["duration"]) > 0:
			remaining.append(effect)
	target["effects"] = remaining
	var cooldowns: Dictionary = target.get("cooldowns", {})
	for key in cooldowns.keys():
		cooldowns[key] = maxi(0, int(cooldowns[key]) - 1)
	target["cooldowns"] = cooldowns

func total(target: Dictionary, kind: String) -> float:
	var result = 0.0
	for effect in target.get("effects", []):
		if effect.get("kind", "") == kind:
			result += float(effect.get("value", 0.0)) * int(effect.get("stacks", 1))
	return result

func mitigate(target: Dictionary, damage: int) -> int:
	var reduction = clampf(total(target, "damage_reduction"), 0.0, 0.95)
	var flat = maxi(0, int(total(target, "flat_reduction")))
	return maxi(1, int(ceil(float(damage) * (1.0 - reduction))) - flat)

func threat_multiplier(target: Dictionary) -> float:
	return maxf(0.0, 1.0 + total(target, "threat_multiplier"))

func forced_target(enemy: Dictionary) -> String:
	for effect in enemy.get("effects", []):
		if effect.get("kind", "") == "forced_target":
			return str(effect.get("source_key", ""))
	return ""

func redirect_target(original: Dictionary, living_party: Array) -> Dictionary:
	for effect in original.get("effects", []):
		if effect.get("kind", "") == "redirect":
			for member in living_party:
				if str(member.get("combat_key", "")) == str(effect.get("source_key", "")) and member.get("hp", 0) > 0:
					return member
	return original

func resistance(target: Dictionary, control_id: String) -> float:
	return clampf(total(target, "control_resistance") + total(target, "resist_" + control_id), 0.0, 1.0)

func has_control(target: Dictionary, control_id: String) -> bool:
	for effect in target.get("effects", []):
		if effect.get("kind", "") == "control" and effect.get("id", "") == control_id:
			return true
	return false

func fire_trigger(actor: Dictionary, event_name: String, context: Dictionary) -> void:
	# Passive triggers are data-driven; callers can consume accumulated events.
	for passive in actor.get("passives", []):
		if passive.get("trigger", "") == event_name:
			var events: Array = actor.get("passive_events", [])
			events.append({"id": passive.get("id", ""), "context": context.duplicate()})
			actor["passive_events"] = events

func cooldown_remaining(actor: Dictionary, ability_id: String) -> int:
	return int(actor.get("cooldowns", {}).get(ability_id, 0))

func set_cooldown(actor: Dictionary, ability_id: String, rounds: int) -> void:
	var cooldowns: Dictionary = actor.get("cooldowns", {})
	cooldowns[ability_id] = maxi(0, rounds)
	actor["cooldowns"] = cooldowns

func end_encounter(target: Dictionary):
	var persistent: Array = []
	for effect in target.get("effects", []):
		if bool(effect.get("persistent", str(effect.get("id", "")) in ["poison", "curse", "disease", "paralysis", "petrify"])):
			persistent.append(effect)
	target["effects"] = persistent
	target["cooldowns"] = {}
	for field in ["combat_key", "passive_events"]:
		target.erase(field)
