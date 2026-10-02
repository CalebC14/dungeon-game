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
	"transitions":{}
}
