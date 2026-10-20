# Explicit first-pass bindings over the imported Lower Catacombs geometry.
extends RefCounted
const Preview = preload("res://import_previews/broken_reliquary/architect_broken_reliquary_catacombs_lower.gd")
const DATA = {
	"id":"architect_test_catacombs_lower", "name":"Lower Catacombs", "town":"thornwake", "zone":"ashenwood",
	"map":Preview.DATA["map"], "start_position":Vector2i(12,16), "start_facing":0,
	"tracks_exploration_time":true, "quiet_areas":[Rect2i(0,13,25,6)], "fixed_encounters":{},
	"transitions": {
		Vector2i(22,2): {"target_dungeon":"architect_test_black_warlock_chapel","target_position":Vector2i(12,16),"target_facing":0,"requires_interact":true,"hint":"[Enter] Descend to the Chapel."},
		Vector2i(12,16): {"target_dungeon":"architect_test_catacombs_upper","target_position":Vector2i(12,2),"target_facing":2,"requires_interact":true,"hint":"[Enter] Return to the Upper Catacombs."}},
	"interactions": {
		Vector2i(3,3): {"id":"lower_door_1","type":"door","name":"Northwest ossuary door"},
		Vector2i(7,3): {"id":"lower_door_2","type":"door","name":"Northern ossuary door"},
		Vector2i(21,6): {"id":"lower_door_3","type":"door","name":"Eastern ossuary door"},
		Vector2i(16,13): {"id":"lower_door_4","type":"door","name":"Lower passage door"},
		Vector2i(20,13): {"id":"lower_door_5","type":"door","name":"Burial chamber door"},
		Vector2i(18,14): {"id":"lower_door_6","type":"door","name":"Offering chamber door"},
		Vector2i(18,16): {"id":"lower_hidden_coins","type":"hidden_treasure","name":"an ossuary coin pouch","clue":"A cracked offering bowl conceals old coins.","reward_gold":25}
	},
	"events": {
		Vector2i(12,15): {"id":"lower_test_notice","type":"lore","message":"Lower Catacombs test: Enter opens doors. Return stairs lead upward. Chapel stairs are northeast."},
		Vector2i(2,2): {"id":"lower_ossuary_lore","type":"lore","message":"The ossuary shelves are empty. A black sigil has been scratched into the stone."},
		Vector2i(21,11): {"id":"lower_procession_lore","type":"lore","message":"A faded account describes the dead marching toward a hidden chapel beneath the reliquary."},
		Vector2i(22,2): {"id":"lower_chapel_stairs_notice","type":"lore","message":"The stairs descend to the Chapel. Press Enter to continue; the same route leads back."}
	}
}
