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
	check(is_same(game.inventory_system.party_model, game.party_system), "shared inventory binds after roster reset")
	check(is_same(game.shop_system.inventory_system, game.inventory_system) and is_same(game.loot_system.inventory_system, game.inventory_system), "shop and loot share live service")
	for member in game.roster:
		check(member["inventory"].is_empty(), "starter packs pooled")
	var warrior = game.party[0]
	game.party_system.inventory = []
	for i in range(9):
		game.inventory_system.add_item({}, "healing_potion")
	game.inventory_system.add_item({}, "iron_sword")
	game.game_state = game.GameState.DUNGEON
	key(game, KEY_I)
	check(game.game_state == game.GameState.INVENTORY, "management opens during exploration")
	key(game, KEY_PAGEDOWN)
	key(game, KEY_1)
	check(warrior["equipment"]["weapon"] == "iron_sword", "paged inventory key equips correct item")
	check(game.inventory_page == 0, "removing last page item clamps page")
	key(game, KEY_E)
	key(game, KEY_1)
	check(warrior["equipment"]["weapon"] == null and game.party_system.inventory.back() == "iron_sword", "equipment view unequips into shared bag")
	key(game, KEY_B)
	warrior["hp"] = 0
	key(game, KEY_1)
	check(warrior["hp"] == 12 and game.party_system.inventory.size() == 9, "bag potion targets selected character")
	key(game, KEY_D)
	check(game.inventory_mode == "details", "details tab available")
	key(game, KEY_F)
	check(game.formation_menu_open, "management links to formation")
	key(game, KEY_ESCAPE)
	key(game, KEY_ESCAPE)
	check(game.game_state == game.GameState.DUNGEON, "management returns to original location")
	var reserve = game.roster.back()
	game.party_system.remove_member(reserve["character_id"], true)
	game.game_state = game.GameState.GUILD
	key(game, KEY_I)
	check(game.get_management_members().size() == game.roster.size(), "Guild management includes reserves")
	key(game, KEY_LEFT)
	check(game.get_management_members()[game.inventory_character_index]["character_id"] == reserve["character_id"], "reserve selectable at Guild")
	game.party_system.inventory = ["leather_cap"]
	key(game, KEY_1)
	check(reserve["equipment"]["head"] == "leather_cap", "reserve equipment accessible at Guild")
	key(game, KEY_ESCAPE)
	game.game_state = game.GameState.DUNGEON
	key(game, KEY_I)
	check(game.get_management_members().size() == 5, "exploration management excludes reserves")
	key(game, KEY_ESCAPE)
	game.game_state = game.GameState.COMBAT
	key(game, KEY_I)
	game.open_inventory(game.GameState.COMBAT)
	check(game.game_state == game.GameState.COMBAT, "combat cannot open free inventory")
	game.game_state = game.GameState.CITY
	game.progression.add_gold(100)
	game.enter_shop()
	game.party_system.inventory = []
	key(game, KEY_1)
	check(game.party_system.inventory == ["iron_sword"] and game.progression.get_party_gold() == 65, "shop controller buys into shared pool")
	key(game, KEY_S)
	key(game, KEY_1)
	check(game.party_system.inventory.is_empty() and game.progression.get_party_gold() == 82, "shop controller sells from pool")
	for i in range(10):
		game.inventory_system.add_item({}, "healing_potion")
	key(game, KEY_PAGEDOWN)
	key(game, KEY_1)
	check(game.party_system.inventory.size() == 9 and game.shop_page == 0, "shop sale supports second page and clamps")
	check(game.add_item_to_shared_inventory("silver_ring") and game.party_system.inventory.back() == "silver_ring", "dungeon treasure uses shared inventory")
	game.queue_free()
	if failures.is_empty():
		print("PASS party management controls and shared economy integration")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
