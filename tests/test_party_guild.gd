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
	game.handle_party_select_input(event)

func _initialize():
	call_deferred("run_checks")

func run_checks():
	var game = Game.new()
	root.add_child(game)
	for i in range(30):
		var member = CharacterFactory.make_blank_character()
		member["name"] = "Member %d" % i
		member["hp"] = 10
		member["max_hp"] = 10
		game.party_system.register_character(member)
	game.game_state = game.GameState.PARTY_SELECT
	key(game, KEY_ENTER)
	check(game.game_state == game.GameState.PARTY_SELECT, "empty party cannot leave")
	key(game, KEY_PAGEDOWN)
	key(game, KEY_2)
	check(game.party[0]["name"] == "Member 10", "paged number selects correct reserve")
	key(game, KEY_RIGHT)
	key(game, KEY_3)
	var slots = game.party_system.slots.duplicate()
	key(game, KEY_ENTER)
	check(game.game_state == game.GameState.CITY, "assembled party leaves Guild")
	game.toggle_party_member(25)
	check(game.party_system.slots == slots, "controller rejects membership changes outside Guild")
	game.game_state = game.GameState.PARTY_SELECT
	key(game, KEY_BACKSPACE)
	check(game.party.size() == 1 and game.party_system.slots[1] == "", "remove selected slot")
	for i in range(10):
		key(game, KEY_PAGEDOWN)
	check(game.roster_page == 3, "paging clamps at final page")
	key(game, KEY_9)
	check(game.party.size() == 1, "out of range paged selection is harmless")
	game.queue_free()
	if failures.is_empty():
		print("PASS Guild party integration")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
