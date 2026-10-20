# Explicit first-pass bindings over the imported Chapel geometry.
extends RefCounted
const Preview = preload("res://import_previews/broken_reliquary/architect_broken_reliquary_black_warlock_chapel.gd")
const DATA = {
	"id":"architect_test_black_warlock_chapel", "name":"Chapel (Test)", "town":"thornwake", "zone":"ashenwood",
	"map":Preview.DATA["map"], "start_position":Vector2i(12,16), "start_facing":0,
	"tracks_exploration_time":true, "quiet_areas":[Rect2i(0,13,25,6)],
	"fixed_encounters": {Vector2i(12,5): {"id":"chapel_test_boss","tag":"architect_chapel_boss","enemy_id":"black_acolyte","count":1,"intro":"Bristle-Aptarj's test encounter begins. A single Black Acolyte stands in for the final boss."}},
	"transitions": {
		Vector2i(12,16): {"target_dungeon":"architect_test_catacombs_lower","target_position":Vector2i(22,2),"target_facing":2,"requires_interact":true,"hint":"[Enter] Return to the Lower Catacombs."},
		Vector2i(12,2): {"to_city":true,"to_city_id":"thornwake","requires_interact":true,"requires_defeated":"chapel_test_boss","hide_until_defeated":true,"hint":"[Enter] Use the revealed exit to Thornwake."}
	},
	"interactions": {
		Vector2i(5,6): {"id":"chapel_door_1","type":"door","name":"Chapel door"},
		Vector2i(5,13): {"id":"chapel_door_2","type":"door","name":"Chapel door"},
		Vector2i(8,3): {"id":"chapel_door_3","type":"door","name":"Chapel door"},
		Vector2i(10,11): {"id":"chapel_door_4","type":"door","name":"Chapel door"},
		Vector2i(10,14): {"id":"chapel_door_5","type":"door","name":"Chapel door"},
		Vector2i(12,4): {"id":"chapel_door_6","type":"door","name":"Chapel door"},
		Vector2i(12,8): {"id":"chapel_door_7","type":"door","name":"Chapel door"},
		Vector2i(14,11): {"id":"chapel_door_8","type":"door","name":"Chapel door"},
		Vector2i(14,14): {"id":"chapel_door_9","type":"door","name":"Chapel door"},
		Vector2i(16,3): {"id":"chapel_door_10","type":"door","name":"Chapel door"},
		Vector2i(19,6): {"id":"chapel_door_11","type":"door","name":"Chapel door"},
		Vector2i(19,13): {"id":"chapel_door_12","type":"door","name":"Chapel door"},
		Vector2i(11,2): {"id":"chapel_cache_west","type":"hidden_treasure","name":"a western offering pouch","clue":"A loose altar tile conceals a small pouch.","reward_gold":25},
		Vector2i(13,2): {"id":"chapel_cache_east","type":"hidden_treasure","name":"an eastern offering pouch","clue":"A cracked offering chest holds a glint of coins.","reward_gold":25}
	},
	"events": {
		Vector2i(12,15): {"id":"chapel_test_notice","type":"lore","message":"Chapel test: Enter opens doors. Defeat the northern test boss to reveal a town exit. Return stairs stay open."}
	}
}
