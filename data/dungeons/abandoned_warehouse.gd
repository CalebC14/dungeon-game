class_name AbandonedWarehouseData
extends RefCounted

const DATA = {
	"id":"abandoned_warehouse","name":"Abandoned Warehouse","zone":"ashenwood","town":"thornwake",
	"map":[
		"###############","#.............#","#.#####.#####.#","#.#...#.#...#.#","#.#...#.#...#.#",
		"#.#...#.....#.#","#.###.#####.#.#","#.....#.....#.#","#####.#.#####.#","#.....#.......#",
		"#.###########.#","#.............#","#.###########.#","#.............#","###############"
	],
	"start_position":Vector2i(1,13),"start_facing":0,
	"fixed_encounters":{Vector2i(13,1):{"id":"warehouse_rat_boss","tag":"warehouse_rat_boss","enemy_id":"rat_broodmother","count":1,"intro":"An enormous rat rises from a nest of splintered crates and gnawed refuse!"}},
	"transitions":{},
	"rogue_objects": {
		Vector2i(1,13): {"id":"warehouse_test_lock", "name":"Padlocked supply chest", "skill":"pick_lock", "reward_gold":20},
		Vector2i(3,13): {"id":"warehouse_test_trap", "name":"Trapped coin box", "skill":"disarm_trap", "reward_gold":10, "failure_damage":4}
	},
	"exploration_objects": {
		Vector2i(5,13): {"id": "warehouse_force_obstacle", "name": "Heavy storage gate", "skill": "force_obstacle", "reward_gold": 10, "failure_damage": 2, "success_message": "The gate lifts, exposing a small cache."},
		Vector2i(7,13): {"id": "warehouse_break_barricade", "name": "Brittle timber barricade", "skill": "break_barricade", "reward_gold": 10, "failure_damage": 2, "success_message": "The barricade breaks, exposing a small cache."},
		Vector2i(9,13): {"id": "warehouse_scout", "name": "Warehouse lookout", "skill": "scout", "reward_gold": 0, "failure_damage": 0, "success_message": "Scouting spots a large rat nest in the northeast corner (13,1)."},
		Vector2i(11,13): {"id": "warehouse_track", "name": "Tracks beneath the crates", "skill": "track", "reward_gold": 10, "failure_damage": 0, "success_message": "You follow the tracks to a hidden coin pouch."},
		Vector2i(13,13): {"id": "warehouse_traverse_gap", "name": "Gap beside the loading ledge", "skill": "traverse_gap", "reward_gold": 10, "failure_damage": 2, "success_message": "You cross the gap and retrieve an abandoned coin pouch."}
	},
	"interactions": {
		Vector2i(5,12): {"id":"warehouse_hidden_panel", "type":"secret_door", "name":"Hidden storage passage", "clue":"Scrape marks run beneath this section of wall.", "discovery_message":"You find a concealed catch. A secret door slides open into the storage corridor!"},
		Vector2i(4,11): {"id":"warehouse_floor_spikes", "type":"trap", "name":"Floor spike trap", "damage":4},
		Vector2i(2,11): {"id":"warehouse_brass_key", "type":"key", "name":"Warehouse brass key", "key_id":"warehouse_brass_key"},
		Vector2i(7,10): {"id":"warehouse_store_door", "type":"locked_door", "name":"Warehouse store door", "pickable":true, "key_id":"warehouse_brass_key", "key_name":"Warehouse brass key"},
		Vector2i(7,9): {"id":"warehouse_shortcut_lever", "type":"lever", "name":"Cross-passage lever", "opens":["warehouse_cross_passage"], "message":"The lever lowers. A panel slides open in the west wall, connecting the two storage corridors."},
		Vector2i(6,9): {"id":"warehouse_cross_passage", "type":"shortcut", "name":"Warehouse cross-passage"}
	}
}
