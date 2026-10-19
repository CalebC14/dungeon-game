extends SceneTree
const Game = preload("res://game.gd")
var failures: Array[String] = []

func check(ok: bool, label: String):
	if not ok:
		failures.append(label)

func key(game, code: int):
	var event = InputEventKey.new()
	event.keycode = code
	event.pressed = true
	game._input(event)

func _initialize():
	call_deferred("run_checks")

func run_checks():
	var game = Game.new()
	root.add_child(game)
	game.save_path = "/private/tmp/dungeon-pass4-save-recovery.dat"
	game.start_test_party()
	check(FileAccess.file_exists(game.save_path), "Guild departure establishes disk save")
	var down = game.party[0]
	var dead = game.party[1]
	CharacterHealth.damage(down, 10000)
	CharacterHealth.complete_round(CharacterHealth.countdown_snapshot([down]))
	CharacterHealth.damage(dead, 10000)
	for i in range(3):
		CharacterHealth.complete_round(CharacterHealth.countdown_snapshot([dead]))
	var down_id: String = down["character_id"]
	var dead_id: String = dead["character_id"]
	game.combat.effects.apply(down, {"id":"curse", "kind":"condition", "persistent":true})
	game.progression.add_gold(123)
	game.quest_system.set_state("rats_in_the_warehouse", "active")
	game.quest_items["old_key"] = 1
	game.dungeon.defeated_fixed_encounters["fixture"] = true
	game.dungeon.consumed_permanent_events["fixture"] = true
	game.dungeon.consumed_expedition_events["fixture"] = true
	game.game_state = game.GameState.DUNGEON
	var slots = game.party_system.slots.duplicate()
	var items = game.party_system.inventory.duplicate()
	var position = game.dungeon.player_pos
	key(game, KEY_F5)
	check(game.save_message == "Game saved.", "F5 saves stable gameplay state")
	CharacterHealth.heal(down, 99)
	CharacterHealth.resurrect(dead)
	game.progression.add_gold(999)
	game.quest_system.quest_states.clear()
	game.dungeon.defeated_fixed_encounters.clear()
	key(game, KEY_F9)
	check(game.game_state == game.GameState.DUNGEON and game.dungeon.player_pos == position, "F9 restores exact location")
	down = game.party_system.find_character(down_id)
	dead = game.party_system.find_character(dead_id)
	check(down["hp"] == 0 and down["death_rounds_remaining"] == 2 and not down["dead"], "save retains paused countdown")
	check(dead["dead"] and dead["hp"] == 0, "save retains death")
	check(down["effects"].size() == 1 and down["effects"][0]["id"] == "curse", "save retains persistent conditions")
	check(game.party_system.slots == slots and game.party_system.inventory == items, "save retains exact formation and shared inventory")
	check(game.progression.get_party_gold() == 123 and game.quest_system.get_state("rats_in_the_warehouse") == "active", "save restores rewards and quests")
	check(game.quest_items.get("old_key") == 1 and game.dungeon.defeated_fixed_encounters.get("fixture", false) and game.dungeon.consumed_permanent_events.get("fixture", false) and game.dungeon.consumed_expedition_events.get("fixture", false), "save restores quest items and dungeon progress")
	var invalid = game.capture_save()
	invalid["dungeon"]["position"] = Vector2i(-99, -99)
	check(not game.restore_save(invalid) and game.party_system.find_character(down_id)["death_rounds_remaining"] == 2, "invalid save restore is atomic")
	game.combat.start_specific_encounter("skeleton")
	game.game_state = game.GameState.COMBAT
	game.current_combat_tag = "wilderness"
	for seed_value in range(100):
		seed(seed_value)
		if randf() < 0.60:
			seed(seed_value)
			break
	game.attempt_party_escape()
	check(game.game_state == game.GameState.WILDERNESS and down["death_rounds_remaining"] == 2, "successful escape pauses countdown and restores correct exploration mode")
	game.game_state = game.GameState.COMBAT
	check(not game.save_game() and not game.load_game(), "cannot save or load during combat")
	for member in game.party:
		CharacterHealth.damage(member, 10000)
	game.game_state = game.GameState.COMBAT_RESULT
	key(game, KEY_ENTER)
	check(game.game_state == game.GameState.DUNGEON and game.party_system.find_character(dead_id)["dead"], "full-party defeat reloads saved state without free revival")
	check(not game.combat.party_defeated(game.party), "reloaded survivors restored from save")
	game.game_state = game.GameState.TEMPLE
	game.temple_character_index = game.get_party_index(game.party_system.find_character(dead_id))
	key(game, KEY_ENTER)
	dead = game.party_system.find_character(dead_id)
	check(not dead["dead"] and dead["hp"] == 1 and game.progression.get_party_gold() == 123, "temple resurrects at one HP without fee")
	game.temple_character_index = game.get_party_index(game.party_system.find_character(down_id))
	key(game, KEY_ENTER)
	check(game.party_system.find_character(down_id)["hp"] == 0, "temple resurrection does not replace healing for incapacitation")
	key(game, KEY_I)
	check(game.game_state == game.GameState.INVENTORY, "party management available at temple")
	key(game, KEY_ESCAPE)
	key(game, KEY_ESCAPE)
	check(game.game_state == game.GameState.CITY, "temple exits to city")
	game.save_path = "/private/tmp/dungeon-pass4-no-such-directory/save.dat"
	check(not game.save_game(), "write failure reported")
	for member in game.party:
		CharacterHealth.damage(member, 10000)
	game.game_state = game.GameState.COMBAT_RESULT
	key(game, KEY_ENTER)
	check(game.game_state == game.GameState.COMBAT_RESULT and game.combat.party_defeated(game.party), "missing save keeps game over instead of reviving")
	game.queue_free()
	if failures.is_empty():
		print("PASS disk saves, defeat recovery, conditions, and temple resurrection")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
