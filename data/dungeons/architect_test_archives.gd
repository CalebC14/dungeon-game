# Explicit test bindings for the imported Archives geometry.
extends RefCounted
const Preview = preload("res://import_previews/broken_reliquary/architect_broken_reliquary_archives.gd")
const DATA = {
	"id":"architect_test_archives", "name":"Archives (Test)", "town":"thornwake", "zone":"ashenwood",
	"map":Preview.DATA["map"], "start_position":Vector2i(12,16), "start_facing":0,
	"tracks_exploration_time":true, "quiet_areas":[Rect2i(0,12,25,7)],
	"fixed_encounters": {Vector2i(13,14): {"id":"archives_test_guardian", "tag":"architect_archives_guardian", "enemy_id":"skeleton", "count":1,"intro":"A restless archivist rises. A single Skeleton stands in for the Archives guardian."}},
	"transitions": {
		Vector2i(12,2): {"target_dungeon":"architect_test_catacombs_upper","target_position":Vector2i(12,16),"target_facing":0,"requires_interact":true,"hint":"[Enter] Descend to the Upper Catacombs."},
		Vector2i(12,16): {"target_dungeon":"architect_test_church_nave","target_position":Vector2i(12,2),"target_facing":2,"requires_interact":true,"hint":"[Enter] Climb back to the Church Nave."}},
	"interactions": {
		Vector2i(11,5): {"id":"archives_door_1","type":"door","name":"Archive door"},
		Vector2i(4,7): {"id":"archives_door_2","type":"door","name":"West archive door"},
		Vector2i(20,7): {"id":"archives_door_3","type":"door","name":"East archive door"},
		Vector2i(4,11): {"id":"archives_door_4","type":"door","name":"West reading-room door"},
		Vector2i(20,11): {"id":"archives_door_5","type":"door","name":"East reading-room door"},
		Vector2i(13,13): {"id":"archives_door_6","type":"door","name":"Archivist's door"},
		Vector2i(2,2): {"id":"archives_cache_north","type":"hidden_treasure","name":"an old records coin pouch","clue":"A loose ledger cover conceals a small pouch.","reward_gold":25},
		Vector2i(22,16): {"id":"archives_cache_south","type":"hidden_treasure","name":"a forgotten donation pouch","clue":"Coins glint beneath a dusty reading desk.","reward_gold":25}
	},
	"events": {
		Vector2i(12,15): {"id":"archives_test_notice","type":"lore","message":"Archives test: Enter opens doors. Return stairs are south; Upper Catacombs stairs are north."},
		Vector2i(2,16): {"id":"archives_ritual_lore","type":"lore","message":"A brittle ledger records Bristle-Aptarj's failed ritual. The dead rose, but the lower chambers remained sealed."},
		Vector2i(12,2): {"id":"archives_upper_stairs_notice","type":"lore","message":"The stairs descend to the Upper Catacombs. Press Enter to continue; you can return by the same route."}
	}
}
