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
func seen_floor(d: DungeonSystem) -> Dictionary:
	var queue = [d.player_pos]
	var seen = {d.player_pos:true}
	var cursor = 0
	while cursor < queue.size():
		var position = queue[cursor]
		cursor += 1
		for direction in DungeonSystem.DIRECTIONS:
			var next = position + direction
			if d.can_move_to(next) and not seen.has(next):
				seen[next] = true
				queue.append(next)
	return seen
func run_checks():
	var game = Game.new()
	root.add_child(game)
	game.load_test_roster()
	game.encounter_chance = 0.0
	game.enter_dungeon("architect_test_catacombs_lower")
	var d = game.dungeon
	d.player_pos = Vector2i(22,2)
	key(game,KEY_ENTER)
	check(d.dungeon_id == "architect_test_black_warlock_chapel" and d.player_pos == Vector2i(12,16) and d.facing == 0, "Lower stairs reach imported Chapel landing")
	check(d.map == preload("res://import_previews/broken_reliquary/architect_broken_reliquary_black_warlock_chapel.gd").DATA["map"], "Chapel geometry unchanged")
	key(game,KEY_ENTER)
	check(d.dungeon_id == "architect_test_catacombs_lower" and d.player_pos == Vector2i(22,2) and d.facing == 2, "immediate return remains available without auto bounce")
	key(game,KEY_ENTER)
	var steps = d.exploration_steps
	key(game,KEY_UP)
	check(d.player_pos == Vector2i(12,15) and d.exploration_steps == steps+1 and "Chapel test" in d.message, "arrival walk shows testing notice")
	d.player_pos = Vector2i(12,9)
	d.facing = 0
	check(not d.can_move_to(Vector2i(12,8)), "Chapel door starts closed")
	key(game,KEY_ENTER)
	key(game,KEY_UP)
	check(d.player_pos == Vector2i(12,8), "keyless Chapel door opens and traverses")
	check(game.restore_save(game.capture_save()), "save on Chapel door restores")
	d = game.dungeon
	check(d.can_move_to(Vector2i(12,8)), "door state persists")
	var gold = game.progression.get_party_gold()
	for position in [Vector2i(11,2),Vector2i(13,2)]:
		d.player_pos = position
		d.facing = 0
		key(game,KEY_ENTER)
		key(game,KEY_ENTER)
	check(game.progression.get_party_gold() == gold+50, "two offering caches pay once each")
	d.player_pos = Vector2i(12,2)
	check(d.get_current_transition().is_empty(), "town exit hidden before victory")
	key(game,KEY_ENTER)
	check(game.game_state == game.GameState.DUNGEON, "hidden exit cannot be used")
	game.perform_dungeon_transition(d.transitions[Vector2i(12,2)])
	check(game.game_state == game.GameState.DUNGEON and "sealed" in d.message, "raw transition path still enforces boss gate")
	d.player_pos = Vector2i(12,5)
	game.check_dungeon_tile()
	check(game.game_state == game.GameState.COMBAT and game.combat.enemies[0]["id"] == "black_acolyte", "test boss uses Black Acolyte stand-in")
	var escape_seed = 0
	for candidate in range(100):
		seed(candidate)
		if randf() < 0.60:
			escape_seed = candidate
			break
	seed(escape_seed)
	game.attempt_party_escape()
	check(not d.is_fixed_encounter_defeated(d.dungeon_id,"chapel_test_boss"), "escape does not complete boss")
	d.player_pos = Vector2i(12,2)
	check(d.get_current_transition().is_empty(), "escape does not reveal town exit")
	d.player_pos = Vector2i(12,5)
	game.check_dungeon_tile()
	var quests = game.quest_system.quest_states.duplicate(true)
	for enemy in game.combat.enemies: enemy["hp"] = 0
	game.handle_combat_victory()
	gold = game.progression.get_party_gold()
	var party_data = game.party_system.to_data()
	game.handle_combat_victory()
	check(game.progression.get_party_gold() == gold and game.party_system.to_data() == party_data, "boss victory cannot duplicate XP gold or loot")
	check(game.quest_system.quest_states == quests and d.is_fixed_encounter_defeated(d.dungeon_id,"chapel_test_boss"), "test boss persists without changing live quest")
	key(game,KEY_ENTER)
	d.player_pos = Vector2i(12,2)
	check(not d.get_current_transition().is_empty(), "victory reveals exit")
	check(game.restore_save(game.capture_save()), "revealed exit save restores")
	d = game.dungeon
	check(not d.get_current_transition().is_empty(), "exit reveal persists through load")
	key(game,KEY_ENTER)
	check(game.game_state == game.GameState.CITY and game.city.city_id == "thornwake", "completion exit returns to town")
	game.enter_dungeon("architect_test_black_warlock_chapel")
	d.player_pos = Vector2i(12,5)
	check(d.get_current_fixed_encounter().is_empty(), "boss stays defeated on re-entry")
	d.player_pos = Vector2i(11,2)
	d.facing = 0
	key(game,KEY_ENTER)
	check(game.progression.get_party_gold() == gold, "cache collection survives save and re-entry")
	for id in ["architect_test_catacombs_lower","architect_test_catacombs_upper","architect_test_archives","architect_test_church_nave"]:
		d.player_pos = Vector2i(12,16)
		key(game,KEY_ENTER)
		check(d.dungeon_id == id, "return chain reaches " + id)
	d.player_pos = Vector2i(12,16)
	key(game,KEY_ENTER)
	check(game.game_state == game.GameState.CITY, "original return chain also reaches town")
	var layout = DungeonSystem.new()
	layout.load_dungeon("architect_test_black_warlock_chapel")
	for iteration in range(13):
		var seen = seen_floor(layout)
		for position in layout.dungeon_data["interactions"]:
			var object = layout.get_interaction_at(position)
			if object.get("type") == "door" and DungeonLayoutValidation.accessible(seen,position,true):
				layout.interaction_states[DungeonInteractions.state_key(layout,object)] = {"open":true}
	var seen = seen_floor(layout)
	for position in [Vector2i(12,5),Vector2i(11,2),Vector2i(13,2),Vector2i(12,2)]:
		check(seen.has(position), "content reachable through approachable doors " + str(position))
	check(EncounterValidation.all_errors().is_empty(), "encounter bindings validate")
	check(DungeonLayoutValidation.inspect(layout.dungeon_id,layout.dungeon_data,DungeonData.DUNGEONS)["errors"].is_empty(), "Chapel layout validates")
	game.queue_free()
	if failures.is_empty():
		print("PASS imported Chapel links, doors, caches, boss, exit gating, persistence, and return chain")
		quit(0)
	else:
		for label in failures: push_error(label)
		quit(1)
