# Explicit first-pass bindings over the imported Upper Catacombs geometry.
extends RefCounted
const Preview = preload("res://import_previews/broken_reliquary/architect_broken_reliquary_catacombs_upper.gd")
const DATA = {
	"id":"architect_test_catacombs_upper", "name":"Upper Catacombs", "town":"thornwake", "zone":"ashenwood",
	"map":Preview.DATA["map"], "start_position":Vector2i(12,16), "start_facing":0,
	"tracks_exploration_time":true, "random_encounter_multiplier":0.5, "encounter_grace_steps":4, "quiet_areas":[Rect2i(0,13,25,6)], "fixed_encounters":{},
	"transitions": {
		Vector2i(12,2): {"target_dungeon":"architect_test_catacombs_lower","target_position":Vector2i(12,16),"target_facing":0,"requires_interact":true,"hint":"[Enter] Descend to the Lower Catacombs."},
		Vector2i(12,16): {"target_dungeon":"architect_test_archives","target_position":Vector2i(12,2),"target_facing":2,"requires_interact":true,"hint":"[Enter] Return to the Archives."}},
	"interactions": {
		Vector2i(6,3): {"id":"upper_door_north","type":"door","name":"Northern crypt door"},
		Vector2i(7,9): {"id":"upper_door_west","type":"door","name":"Western crypt door"},
		Vector2i(15,10): {"id":"upper_door_east","type":"door","name":"Eastern crypt door"},
		Vector2i(22,16): {"id":"upper_hidden_coins","type":"hidden_treasure","name":"a burial coin pouch","clue":"A loose burial stone reveals a glint of coins.","reward_gold":25}
	},
	"events": {
		Vector2i(12,15): {"id":"upper_test_notice","type":"lore","message":"Upper Catacombs test: Enter opens doors. Return stairs lead to the Archives. Lower Catacombs stairs are north."},
		Vector2i(3,1): {"id":"upper_memorial_lore","type":"lore","message":"Names of the faithful line a cracked memorial. Many were erased during the desecration."},
		Vector2i(20,1): {"id":"upper_watch_lore","type":"lore","message":"A watcher's inscription warns that restless dead roam the deeper burial passages."},
		Vector2i(12,2): {"id":"upper_lower_stairs_notice","type":"lore","message":"The stairs descend to the Lower Catacombs. Press Enter to continue; the same route leads back."}
	}
}
