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
	game.load_test_roster()
	check(is_same(game.combat.formation, game.party_system), "combat bound to canonical formation after fixture load")
	var count = game.party.size()
	var id: String = game.party_system.slots[0]
	game.game_state = game.GameState.DUNGEON
	key(game, KEY_F)
	check(game.formation_menu_open, "exploration formation shortcut")
	key(game, KEY_1)
	key(game, KEY_4)
	check(game.party_system.slots[3] == id and game.party.size() == count, "free formation swap preserves membership")
	check(game.game_state == game.GameState.DUNGEON, "overlay preserves location state")
	key(game, KEY_ESCAPE)
	check(not game.formation_menu_open, "overlay closes")
	var frozen = game.party_system.slots.duplicate()
	game.game_state = game.GameState.COMBAT
	game.combat_character_index = 0
	var actor = game.get_current_combat_character()
	var mover: String = actor["character_id"]
	var old_slot = game.party_system.slots.find(mover)
	var destination = 5 if old_slot != 5 else 4
	key(game, KEY_5)
	key(game, KEY_ESCAPE)
	check(game.combat.party_actions.is_empty(), "cancel costs no action")
	key(game, KEY_5)
	key(game, KEY_1 + destination)
	check(not game.formation_menu_open and game.combat_character_index == 1, "combat move advances action selection")
	check(game.party_system.slots == frozen, "queued move does not change formation prematurely")
	check(game.combat.party_actions.size() == 1 and game.combat.party_actions[0]["action"] == "Reposition", "movement queues one action")
	check(game.combat.party_actions[0]["target_slot"] == destination, "movement preserves destination")
	var enemy = game.combat.create_enemy_from_data(GameData.ENEMIES["skeleton"])
	enemy["hp"] = 10000
	game.combat.enemies = [enemy]
	while game.combat.round_number == 1:
		game.queue_current_action("Defend")
	check(game.party_system.slots[destination] == mover, "queued combat movement resolves through controller")
	check(game.combat.round_number == 2, "movement round finishes")
	game.game_state = game.GameState.COMBAT
	key(game, KEY_F)
	check(not game.formation_menu_open, "free exploration shortcut unavailable in combat")
	game.queue_free()
	if failures.is_empty():
		print("PASS formation menu and queued movement controls")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
