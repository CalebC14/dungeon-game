extends "res://tests/test_imported_chain.gd"

var random_battles = 0
var fixed_battles = 0
var battle_floors: Dictionary = {}
var resource_log: Array[Dictionary] = []
var last_battle_floor = ""
var last_battle_step = -1

func totals(game) -> Dictionary:
	var hp = 0
	var sp = 0
	var conscious = 0
	var dead = 0
	for member in game.party:
		hp += int(member["hp"])
		sp += int(member["sp"])
		if CharacterHealth.conscious(member): conscious += 1
		if bool(member.get("dead",false)): dead += 1
	return {"hp":hp,"sp":sp,"conscious":conscious,"dead":dead}

func win_battle(game) -> bool:
	if game.game_state != game.GameState.COMBAT: return true
	var floor_id: String = game.dungeon.dungeon_id
	var step: int = game.dungeon.exploration_steps
	var random_battle = game.current_combat_tag.is_empty()
	if random_battle:
		random_battles += 1
		check(not game.dungeon.is_quiet_area(),"random fight never starts in quiet area")
		if floor_id == last_battle_floor:
			check(step-last_battle_step >= 5,"random battle respects post-battle movement protection")
	else:
		fixed_battles += 1
	battle_floors[floor_id] = int(battle_floors.get(floor_id,0))+1
	last_battle_floor = floor_id
	last_battle_step = step
	var won = super.win_battle(game)
	var resources = totals(game)
	resources["floor"] = floor_id
	resources["step"] = step
	resources["random"] = random_battle
	resource_log.append(resources)
	return won

func run_checks():
	var game = Game.new()
	root.add_child(game)
	game.load_test_roster()
	seed(123456) # Game._ready randomizes; seed only after startup and party setup.
	check(game.encounter_chance == 0.25,"test uses normal base random encounter rate")
	game.save_path = "/private/tmp/imported-chain-random-%d.dat" % OS.get_process_id()
	var quests = game.quest_system.quest_states.duplicate(true)
	var initial = totals(game)
	var completed = journey(game)
	check(completed,"random-enabled journey completes")
	check(random_battles > 0,"random encounters actually occurred")
	check(fixed_battles == 3,"all three fixed encounters still occur")
	check(battles == random_battles+fixed_battles,"battle accounting includes every fight")
	check(game.quest_system.quest_states == quests,"random-enabled test leaves live quests unchanged")
	check(game.progression.get_party_gold() > 150,"combat and cache rewards accumulated")
	check(totals(game)["conscious"] > 0,"party remains able to adventure at completion")
	var final = totals(game)
	print("RANDOM CHAIN seed=123456 completed=%s random=%d fixed=%d steps=%d doors=%d initial=%s final=%s floors=%s" % [str(completed),random_battles,fixed_battles,walked_steps,opened_doors,str(initial),str(final),str(battle_floors)])
	print("RESOURCE CHECKPOINTS " + str(resource_log))
	DirAccess.remove_absolute(game.save_path)
	game.queue_free()
	if failures.is_empty():
		print("PASS full imported chain with normal random encounters, real battles, disk checkpoint, and final exit")
		quit(0)
	else:
		for label in failures: push_error(label)
		quit(1)
