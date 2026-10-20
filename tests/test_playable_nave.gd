extends SceneTree
const Game = preload("res://game.gd")
var failures: Array[String] = []
func check(ok: bool, label: String):
	if not ok: failures.append(label)
func key(game, code: int):
	var event = InputEventKey.new()
	event.keycode = code
	event.pressed = true
	game._input(event)
func _initialize(): call_deferred("run_checks")
func run_checks():
	var game = Game.new()
	root.add_child(game)
	game.load_test_roster()
	game.encounter_chance = 0.0
	key(game,KEY_F12)
	key(game,KEY_N)
	check(game.game_state == game.GameState.DUNGEON and game.dungeon.dungeon_id == "architect_test_church_nave" and not game.developer_menu_open, "developer shortcut enters registered test dungeon")
	var d = game.dungeon
	check(d.player_pos == Vector2i(12,16) and d.get_current_transition().get("to_city",false), "imported entrance has immediate safe return")
	key(game,KEY_ENTER)
	check(game.game_state == game.GameState.CITY and game.city.city_id == "thornwake", "entrance returns to town before boss")
	game.enter_dungeon("architect_test_church_nave")
	d = game.dungeon
	check(d.map == preload("res://import_previews/broken_reliquary/architect_broken_reliquary_church_nave.gd").DATA["map"], "live data uses imported geometry unchanged")
	var reachable = DungeonLayoutValidation.reachable(d.dungeon_data)
	check(reachable.has(Vector2i(12,4)) and reachable.has(Vector2i(12,2)), "guardian and sealed exit physically reachable without secrets")
	d.player_pos = Vector2i(12,2)
	key(game,KEY_ENTER)
	check(game.game_state == game.GameState.DUNGEON and "sealed" in d.message, "completion exit blocks before guardian")
	var gold = game.progression.get_party_gold()
	d.player_pos = Vector2i(3,10)
	d.facing = 0
	key(game,KEY_ENTER)
	key(game,KEY_ENTER)
	check(game.progression.get_party_gold() == gold + 25, "imported treasure binding pays once")
	d.player_pos = Vector2i(11,11)
	d.facing = 0
	var hp = game.party[0]["hp"]
	key(game,KEY_UP)
	check(game.party[0]["hp"] == hp - 4 and d.exploration_steps == 1, "imported trap uses health and time systems")
	d.player_pos = Vector2i(20,4)
	d.facing = 0
	check(not d.can_move_to(Vector2i(20,3)), "secret niche starts concealed")
	key(game,KEY_ENTER)
	key(game,KEY_UP)
	check(d.player_pos == Vector2i(20,3) and "inscription" in d.message, "search opens niche and walking reveals lore")
	d.player_pos = Vector2i(12,4)
	game.check_dungeon_tile()
	check(game.game_state == game.GameState.COMBAT and game.combat.enemies[0]["id"] == "skeleton", "guardian starts explicit stand-in encounter")
	var quests = game.quest_system.quest_states.duplicate(true)
	for enemy in game.combat.enemies: enemy["hp"] = 0
	game.handle_combat_victory()
	check(d.is_fixed_encounter_defeated(d.dungeon_id,"nave_test_guardian") and game.quest_system.quest_states == quests, "test guardian completes without changing live Reliquary quests")
	key(game,KEY_ENTER)
	check(game.restore_save(game.capture_save()), "playable import save restores")
	d = game.dungeon
	check(d.get_current_fixed_encounter().is_empty() and not d.interaction_states.is_empty(), "guardian and interaction states persist")
	d.player_pos = Vector2i(12,2)
	key(game,KEY_ENTER)
	check(game.game_state == game.GameState.CITY, "guardian victory unlocks completion exit")
	game.enter_dungeon("architect_test_church_nave")
	game.dungeon.player_pos = Vector2i(12,4)
	check(game.dungeon.get_current_fixed_encounter().is_empty(), "guardian stays defeated on re-entry")
	check(DungeonData.DUNGEONS.has("broken_reliquary_church") and not DungeonData.DUNGEONS.has("architect_broken_reliquary_archives"), "original dungeon retained and unbound Archives not exposed")
	check(EncounterValidation.all_errors().is_empty(), "all encounter and reward bindings validate")
	check(DungeonLayoutValidation.inspect(d.dungeon_id,d.dungeon_data,DungeonData.DUNGEONS)["errors"].is_empty(), "playable layout validates")
	game.queue_free()
	if failures.is_empty():
		print("PASS playable imported Nave entry, interactions, guardian gating, and saves")
		quit(0)
	else:
		for label in failures: push_error(label)
		quit(1)
