extends SceneTree
const Game = preload("res://game.gd")
var failures: Array[String] = []
var battles = 0
var walked_steps = 0
var opened_doors = 0
func check(ok: bool, label: String):
	if not ok: failures.append(label)
func key(game, code: int):
	var event = InputEventKey.new()
	event.keycode = code
	event.pressed = true
	game._input(event)
func _initialize(): call_deferred("run_checks")
func win_battle(game) -> bool:
	if game.game_state != game.GameState.COMBAT: return true
	var actions = 0
	while game.game_state == game.GameState.COMBAT and actions < 120:
		var actor: Dictionary = game.get_current_combat_character()
		if actor.is_empty():
			check(false,"combat has no selectable actor")
			return false
		var action = "Attack"
		if game.combat.position_of(actor) >= 3:
			action = "Ability" if actor.get("class") in ["Magician","Priest"] else "Defend"
		game.queue_current_action(action)
		actions += 1
	if game.game_state != game.GameState.COMBAT_RESULT or game.combat.party_defeated(game.party):
		check(false,"default test party failed fixed battle or exceeded action limit")
		return false
	check(game.combat.rewards_claimed,"fixed battle paid a legitimate victory")
	battles += 1
	key(game,KEY_ENTER)
	return game.game_state == game.GameState.DUNGEON
func route(d: DungeonSystem, goal: Vector2i) -> Array:
	var queue = [d.player_pos]
	var parents = {d.player_pos:d.player_pos}
	var cursor = 0
	while cursor < queue.size() and not parents.has(goal):
		var position = queue[cursor]
		cursor += 1
		for direction in DungeonSystem.DIRECTIONS:
			var next = position + direction
			var object = d.get_interaction_at(next)
			if not parents.has(next) and (d.can_move_to(next) or object.get("type") == "door"):
				parents[next] = position
				queue.append(next)
	if not parents.has(goal): return []
	var path: Array = []
	var position = goal
	while position != d.player_pos:
		path.push_front(position)
		position = parents[position]
	return path
func walk_to(game, goal: Vector2i) -> bool:
	var d = game.dungeon
	var path = route(d,goal)
	if path.is_empty() and d.player_pos != goal:
		check(false,"no route on " + d.dungeon_id + " to " + str(goal))
		return false
	for next in path:
		var direction = DungeonSystem.DIRECTIONS.find(next-d.player_pos)
		while d.facing != direction: key(game,KEY_RIGHT)
		if not d.can_move_to(next):
			key(game,KEY_ENTER)
			opened_doors += 1
			if not d.can_move_to(next):
				check(false,"door failed to open at " + str(next))
				return false
		var steps = d.exploration_steps
		key(game,KEY_UP)
		walked_steps += 1
		if d.player_pos != next or d.exploration_steps != steps+1:
			check(false,"actual movement/clock failed at " + str(next))
			return false
		if not win_battle(game): return false
	return true
func collect(game, position: Vector2i) -> bool:
	if not walk_to(game,position): return false
	var gold = game.progression.get_party_gold()
	key(game,KEY_ENTER)
	key(game,KEY_ENTER)
	check(game.progression.get_party_gold() == gold+25,"cache pays once on " + game.dungeon.dungeon_id)
	return true
func travel(game, position: Vector2i, expected: String) -> bool:
	if not walk_to(game,position): return false
	var steps = game.dungeon.exploration_steps
	key(game,KEY_ENTER)
	check(game.dungeon.dungeon_id == expected and game.game_state == game.GameState.DUNGEON,"stair travel reaches " + expected)
	check(game.dungeon.exploration_steps == steps,"floor travel does not charge extra exploration time")
	return game.dungeon.dungeon_id == expected
func journey(game) -> bool:
	key(game,KEY_F12)
	key(game,KEY_N)
	check(game.dungeon.dungeon_id == "architect_test_church_nave","developer entry starts Nave")
	if not collect(game,Vector2i(3,9)): return false
	if not walk_to(game,Vector2i(12,4)): return false
	if not travel(game,Vector2i(12,2),"architect_test_archives"): return false
	if not walk_to(game,Vector2i(13,14)): return false
	if not collect(game,Vector2i(22,16)): return false
	if not travel(game,Vector2i(12,2),"architect_test_catacombs_upper"): return false
	# Use actual disk save/load after two floors of state have accumulated.
	var checkpoint = game.capture_save()
	key(game,KEY_F5)
	check(game.save_message == "Game saved.","mid-journey file save succeeds")
	key(game,KEY_RIGHT)
	key(game,KEY_F9)
	check(game.capture_save() == checkpoint,"disk load restores party, rewards, floor, facing, mechanisms, and time")
	if not collect(game,Vector2i(22,16)): return false
	if not travel(game,Vector2i(12,2),"architect_test_catacombs_lower"): return false
	if not collect(game,Vector2i(18,16)): return false
	if not travel(game,Vector2i(22,2),"architect_test_black_warlock_chapel"): return false
	if not walk_to(game,Vector2i(12,5)): return false
	if not collect(game,Vector2i(11,2)): return false
	if not collect(game,Vector2i(13,2)): return false
	if not walk_to(game,Vector2i(12,2)): return false
	check(not game.dungeon.get_current_transition().is_empty(),"final victory reveals Chapel exit")
	# Face the exit wall rather than either adjacent cache: Enter prefers facing objects.
	while game.dungeon.facing != 0: key(game,KEY_RIGHT)
	key(game,KEY_ENTER)
	check(game.game_state == game.GameState.CITY and game.city.city_id == "thornwake","full journey exits to Thornwake")
	return game.game_state == game.GameState.CITY
func run_checks():
	seed(123456)
	var game = Game.new()
	root.add_child(game)
	game.load_test_roster()
	game.encounter_chance = 0.0
	game.save_path = "/private/tmp/imported-chain-%d.dat" % OS.get_process_id()
	var quests = game.quest_system.quest_states.duplicate(true)
	var completed = journey(game)
	check(completed,"forward journey completes")
	check(battles == 3,"Nave guardian, Archives guardian, and Chapel boss resolved through real combat")
	check(opened_doors > 0 and walked_steps > 0,"journey opened doors and moved without teleporting")
	check(game.quest_system.quest_states == quests,"test journey does not alter live quests")
	for pair in [["architect_test_church_nave","nave_test_guardian"],["architect_test_archives","archives_test_guardian"],["architect_test_black_warlock_chapel","chapel_test_boss"]]:
		check(game.dungeon.is_fixed_encounter_defeated(pair[0],pair[1]),"completion persists for " + pair[1])
	if completed:
		var gold = game.progression.get_party_gold()
		key(game,KEY_F12)
		key(game,KEY_N)
		if walk_to(game,Vector2i(3,9)):
			key(game,KEY_ENTER)
			check(game.progression.get_party_gold() == gold,"returning cannot farm the first cache")
	DirAccess.remove_absolute(game.save_path)
	game.queue_free()
	if failures.is_empty():
		print("PASS full imported chain: %d real battles, %d walked steps, %d doors, disk checkpoint, final exit" % [battles,walked_steps,opened_doors])
		quit(0)
	else:
		for label in failures: push_error(label)
		quit(1)
