extends RefCounted

var message: String = ""

func get_action_for_key(keycode: int) -> String:
	match keycode:
		KEY_1: return "travel_thornwake"
		KEY_2: return "travel_wilderness"
		KEY_3: return "travel_grayhaven"
		KEY_F6: return "travel_dreadmarch"
		KEY_F7: return "travel_oldroot"
		KEY_F8: return "travel_ironreach"
		KEY_4: return "dungeon_warehouse"
		KEY_5: return "dungeon_wine_cellar"
		KEY_6: return "dungeon_sewers_upper"
		KEY_7: return "dungeon_sewers_lower"
		KEY_8: return "dungeon_prison_barracks"
		KEY_9: return "dungeon_prison_holding"
		KEY_A: return "dungeon_prison_torture"
		KEY_B: return "dungeon_prison_morgue"
		KEY_F1: return "dungeon_reliquary_1"
		KEY_F2: return "dungeon_reliquary_2"
		KEY_F3: return "dungeon_reliquary_3"
		KEY_F4: return "dungeon_reliquary_4"
		KEY_F5: return "dungeon_reliquary_5"
		KEY_C: return "quest_rats_start"
		KEY_D: return "quest_rats_complete"
		KEY_E: return "quest_wine_start"
		KEY_F: return "quest_wine_complete"
		KEY_H: return "quest_prison_start"
		KEY_J: return "quest_onika_defeated"
		KEY_K: return "quest_prison_complete"
		KEY_V: return "quest_bristle_defeated"
		KEY_P: return "heal_party"
		KEY_X: return "give_xp"
		KEY_F9: return "give_xp_5000"
		KEY_F10: return "give_xp_50000"
		KEY_G: return "give_gold"
		KEY_T: return "load_test_party"
		KEY_R: return "give_reliquary_key"
		KEY_M: return "unlock_dreadmarch"
	return ""

func get_display_lines() -> Array:
	return [
		"TRAVEL",
		"[1] Thornwake     [2] Ashenwood Wilderness     [3] Grayhaven",
		"[F6] Dreadmarch     [F7] Oldroot     [F8] Ironreach",
		"",
		"DUNGEONS",
		"[4] Warehouse  [5] Wine Cellar  [6] Sewers Upper  [7] Sewers Lower",
		"[8] Prison Barracks  [9] Prison Holding  [A] Torture  [B] Morgue",
		"[F1] Reliquary Church     [F2] Archives     [F3] Upper Catacombs",
		"[F4] Lower Catacombs       [F5] Underground Chapel",
		"",
		"QUEST STATES",
		"[C] Start Rats  [D] Complete Rats  [E] Start Vintage  [F] Complete Vintage",
		"[H] Start Old Prison  [J] Onika Defeated  [K] Complete Old Prison",
		"[R] Give Reliquary Key / Start Purge     [V] Bristle Defeated",
		"[M] Unlock Dreadmarch / Reveal Kazinov",
		"",
		"PARTY / WORLD",
		"[P] Heal Party   [X] +500 XP   [F9] +5,000 XP   [F10] +50,000 XP",
		"[G] +1000 Gold     [T] Test Party",
		"",
		"[ESC] Return to game     [F12] Toggle menu"
	]
