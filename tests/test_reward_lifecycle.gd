extends SceneTree
const Game = preload("res://game.gd")
var failures: Array[String] = []
func check(ok: bool, label: String):
	if not ok: failures.append(label)
func _initialize(): call_deferred("run_checks")
func run_checks():
	var game = Game.new()
	root.add_child(game)
	game.load_test_roster()
	game.enter_dungeon("abandoned_warehouse")
	game.dungeon.player_pos = Vector2i(13,1)
	game.start_fixed_encounter(game.dungeon.get_current_fixed_encounter())
	var gold = game.progression.get_party_gold()
	var xp = game.party[0]["xp"]
	game.handle_combat_victory()
	check(not game.combat.rewards_claimed and game.progression.get_party_gold() == gold, "living enemy cannot pay victory rewards")
	for enemy in game.combat.enemies: enemy["hp"] = 0
	game.handle_combat_victory()
	check(game.combat.rewards_claimed and game.progression.get_party_gold() > gold and game.party[0]["xp"] > xp, "legitimate boss victory awards rewards")
	var snapshot = game.party_system.to_data()
	gold = game.progression.get_party_gold()
	var rewards = game.last_combat_rewards.duplicate(true)
	game.handle_combat_victory()
	check(game.party_system.to_data() == snapshot and game.progression.get_party_gold() == gold and rewards == game.last_combat_rewards, "repeated victory cannot duplicate XP gold or loot")
	check(game.dungeon.get_current_fixed_encounter().is_empty() and game.quest_system.get_state("rats_in_the_warehouse") == "boss_defeated", "boss completion updates persistent state and quest")
	game.game_state = game.GameState.DUNGEON
	check(game.restore_save(game.capture_save()) and game.dungeon.get_current_fixed_encounter().is_empty(), "boss defeat and rewards save together")
	check(game.progression.get_party_gold() == gold, "loading does not re-award boss gold")
	game.combat.start_specific_encounter("giant_rat",1)
	check(not game.combat.rewards_claimed, "new encounter resets reward guard")
	game.combat.enemies[0]["hp"] = 0
	game.current_combat_tag = ""
	game.handle_combat_victory()
	check(game.progression.get_party_gold() > gold, "next encounter can award normally")
	game.combat.start_specific_encounter("giant_rat",1)
	game.game_state = game.GameState.COMBAT
	gold = game.progression.get_party_gold()
	var escape_seed = 0
	for candidate in range(100):
		seed(candidate)
		if randf() < 0.60:
			escape_seed = candidate
			break
	seed(escape_seed)
	game.attempt_party_escape()
	game.handle_combat_victory()
	check(game.game_state == game.GameState.DUNGEON and game.progression.get_party_gold() == gold and not game.combat.rewards_claimed, "successful escape pays no victory rewards")
	game.combat.start_mixed_encounter([{"enemy_id":"giant_rat","count":1}])
	check(not game.combat.rewards_claimed, "mixed encounter resets reward guard")
	gold = game.progression.get_party_gold()
	for member in game.party: member["hp"] = 0
	game.combat.enemies[0]["hp"] = 0
	game.handle_combat_victory()
	check(not game.combat.rewards_claimed and game.progression.get_party_gold() == gold, "mutual defeat cannot pay victory rewards")
	game.queue_free()
	if failures.is_empty():
		print("PASS one-time victory rewards, boss persistence, and next encounter reset")
		quit(0)
	else:
		for label in failures: push_error(label)
		quit(1)
