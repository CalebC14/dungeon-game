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
	game.enter_dungeon("architect_test_church_nave")
	var d = game.dungeon
	d.player_pos = Vector2i(12,2)
	key(game,KEY_ENTER)
	check(d.dungeon_id == "architect_test_church_nave" and "sealed" in d.message, "Nave descent remains guardian-gated")
	d.player_pos = Vector2i(12,4)
	game.check_dungeon_tile()
	for enemy in game.combat.enemies: enemy["hp"] = 0
	game.handle_combat_victory()
	key(game,KEY_ENTER)
	d.player_pos = Vector2i(12,2)
	key(game,KEY_ENTER)
	check(d.dungeon_id == "architect_test_archives" and d.player_pos == Vector2i(12,16) and d.facing == 0, "descent uses matched imported stair coordinates")
	check(d.map == preload("res://import_previews/broken_reliquary/architect_broken_reliquary_archives.gd").DATA["map"], "Archives geometry is unchanged")
	key(game,KEY_ENTER)
	check(d.dungeon_id == "architect_test_church_nave" and d.player_pos == Vector2i(12,2) and d.facing == 2, "return stair works immediately without extra gate or auto bounce")
	key(game,KEY_ENTER)
	check(d.dungeon_id == "architect_test_archives", "explicit Enter can descend again")
	key(game,KEY_UP)
	key(game,KEY_UP)
	key(game,KEY_RIGHT)
	key(game,KEY_UP)
	check(game.game_state == game.GameState.COMBAT and game.combat.enemies[0]["id"] == "skeleton", "Archives guardian uses explicit stand-in")
	var quests = game.quest_system.quest_states.duplicate(true)
	for enemy in game.combat.enemies: enemy["hp"] = 0
	game.handle_combat_victory()
	key(game,KEY_ENTER)
	check(d.is_fixed_encounter_defeated(d.dungeon_id,"archives_test_guardian") and game.quest_system.quest_states == quests, "Archives completion does not alter live quests")
	d.facing = 0
	check(not d.can_move_to(Vector2i(13,13)), "ordinary door initially blocks passage")
	key(game,KEY_ENTER)
	check(d.can_move_to(Vector2i(13,13)), "Enter opens keyless door")
	var states = d.interaction_states.duplicate(true)
	key(game,KEY_ENTER)
	check(states == d.interaction_states, "opening an open door is harmless")
	key(game,KEY_UP)
	check(d.player_pos == Vector2i(13,13), "can traverse opened door")
	check(game.restore_save(game.capture_save()), "save on opened Archives door restores")
	d = game.dungeon
	check(d.can_move_to(Vector2i(13,13)) and d.is_fixed_encounter_defeated(d.dungeon_id,"archives_test_guardian"), "door and guardian persist")
	var gold = game.progression.get_party_gold()
	for position in [Vector2i(2,2),Vector2i(22,16)]:
		d.player_pos = position
		d.facing = 0
		key(game,KEY_ENTER)
		key(game,KEY_ENTER)
	check(game.progression.get_party_gold() == gold + 50, "two caches pay once each")
	check(game.restore_save(game.capture_save()), "Archives cache collection saves")
	d = game.dungeon
	d.player_pos = Vector2i(22,16)
	key(game,KEY_ENTER)
	check(game.progression.get_party_gold() == gold + 50, "saved cache cannot pay twice")
	d.player_pos = Vector2i(12,2)
	game.check_dungeon_tile()
	key(game,KEY_ENTER)
	check(d.dungeon_id == "architect_test_catacombs_upper", "Archives stairs reach playable Upper Catacombs")
	key(game,KEY_ENTER)
	check(d.dungeon_id == "architect_test_archives" and d.player_pos == Vector2i(12,2), "Upper Catacombs return stair restores Archives landing")
	d.player_pos = Vector2i(12,16)
	key(game,KEY_ENTER)
	check(d.dungeon_id == "architect_test_church_nave" and d.is_fixed_encounter_defeated(d.dungeon_id,"nave_test_guardian"), "Nave state survives floor return")
	d.player_pos = Vector2i(12,16)
	key(game,KEY_ENTER)
	check(game.game_state == game.GameState.CITY, "return chain reaches town exit")
	check(EncounterValidation.all_errors().is_empty(), "new encounter bindings validate")
	for id in ["architect_test_church_nave","architect_test_archives"]:
		check(DungeonLayoutValidation.inspect(id,DungeonData.DUNGEONS[id],DungeonData.DUNGEONS)["errors"].is_empty(), "connected test floor validates: " + id)
	# Prove every keyless door can be approached and opened in sequence.
	var layout = DungeonSystem.new()
	layout.load_dungeon("architect_test_archives")
	for iteration in range(7):
		# Reuse actual passability with accumulated door states.
		var queue = [layout.player_pos]
		var seen = {layout.player_pos:true}
		var cursor = 0
		while cursor < queue.size():
			var position = queue[cursor]
			cursor += 1
			for direction in DungeonSystem.DIRECTIONS:
				var next = position + direction
				if layout.can_move_to(next) and not seen.has(next):
					seen[next] = true
					queue.append(next)
		for position in layout.dungeon_data["interactions"]:
			var object: Dictionary = layout.get_interaction_at(position)
			if object.get("type") == "door" and DungeonLayoutValidation.accessible(seen,position,true):
				layout.interaction_states[DungeonInteractions.state_key(layout,object)] = {"open":true}
		if iteration == 6:
			check(seen.has(Vector2i(2,2)) and seen.has(Vector2i(22,16)) and seen.has(Vector2i(12,2)), "opening approachable doors reaches caches and unfinished stairs")
	game.queue_free()
	if failures.is_empty():
		print("PASS connected imported Archives, doors, rewards, guardian, return route, and saves")
		quit(0)
	else:
		for label in failures: push_error(label)
		quit(1)
