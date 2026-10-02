extends RefCounted

var message: String = ""

func get_action_for_key(keycode: int) -> String:
	match keycode:
		KEY_1: return "travel_thornwake"
		KEY_2: return "travel_wilderness"
		KEY_3: return "travel_grayhaven"
		KEY_4: return "dungeon_warehouse"
		KEY_5: return "dungeon_wine_cellar"
		KEY_6: return "dungeon_sewers_upper"
		KEY_7: return "dungeon_sewers_lower"
		KEY_8: return "dungeon_prison_barracks"
		KEY_9: return "dungeon_prison_holding"
		KEY_A: return "dungeon_prison_torture"
		KEY_B: return "dungeon_prison_morgue"
		KEY_C: return "quest_rats_start"
		KEY_D: return "quest_rats_complete"
		KEY_E: return "quest_wine_start"
		KEY_F: return "quest_wine_complete"
		KEY_H: return "quest_prison_start"
		KEY_J: return "quest_onika_defeated"
		KEY_K: return "quest_prison_complete"
		KEY_P: return "heal_party"
		KEY_X: return "give_xp"
		KEY_G: return "give_gold"
		KEY_T: return "load_test_party"
		KEY_R: return "give_reliquary_key"
	return ""

func get_display_lines() -> Array:
	return [
		"TRAVEL",
		"[1] Thornwake     [2] Ashenwood Wilderness     [3] Grayhaven",
		"",
		"DUNGEONS",
		"[4] Abandoned Warehouse     [5] Wine Cellar",
		"[6] Sewers - Upper          [7] Sewers - Lower",
		"[8] Old Prison - Guard Barracks",
		"[9] Old Prison - Prisoner Holding",
		"[A] Old Prison - Torture Chamber     [B] Old Prison - Morgue",
		"",
		"QUEST STATES",
		"[C] Start Rats     [D] Complete Rats",
		"[E] Start Vintage  [F] Complete Vintage",
		"[H] Start Old Prison     [J] Mark Onika Defeated     [K] Complete Old Prison",
		"",
		"PARTY / WORLD",
		"[P] Heal Party     [X] +500 XP Each     [G] +1000 Gold",
		"[T] Load Test Party     [R] Give Broken Reliquary Key",
		"",
		"[ESC] Return to game     [F12] Toggle menu"
	]
