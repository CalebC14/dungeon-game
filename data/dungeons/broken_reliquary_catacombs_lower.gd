class_name BrokenReliquaryCatacombsLowerData
extends RefCounted

const DATA = {
	"id": "broken_reliquary_catacombs_lower",
	"name": "Broken Reliquary — Lower Catacombs",
	"map": [
		"#############################",
		"#...#.........#...#.........#",
		"#.###.#####.###.#.#.#.#####.#",
		"#.....#...#...#.#...#.#.....#",
		"#.#####.#####.#.#####.###.###",
		"#.......#...#.....#.#...#.#.#",
		"#.#######.#.#####.#.###.#.#.#",
		"#.#.....#.#.....#.....#.#...#",
		"#.#.###.#.#####.#######.#####",
		"#.#.#.#.#.#...........#.....#",
		"#.#.#.#.#.#.#..######.#.###.#",
		"#.#.#.#.#.............#...#.#",
		"#.#.#.#.###.......#.#####.#.#",
		"#.#.#.............#.....#.#.#",
		"#.#.#.#####.........###.#.#.#",
		"#.#.#.#...........#...#.#.#.#",
		"#.#.###.###.......#.#.#.###.#",
		"#.#.....#.#.......#.#.#...#.#",
		"#####.###.#.##.####.#####.#.#",
		"#...#.#...#.............#...#",
		"#.#.#.#.#####.#######.#.###.#",
		"#.#.#...#.....#...#.........#",
		"#.#.###.#.#####.#.#.#.....###",
		"#.....#.#...#...#...#.......#",
		"#.....#.###.#.#.#####.....#.#",
		"#.........#.#.#.#.........#.#",
		"#.....#####.#.###.#######.#.#",
		"#...........#.............#.#",
		"#############################"
	],
	"start_position": Vector2i(27, 1),
	"start_facing": 2,
	"transitions": {
		Vector2i(27,1): {"target_dungeon":"broken_reliquary_catacombs_upper","target_position":Vector2i(25,3),"target_facing":2,"requires_interact":true},
		Vector2i(3,25): {"target_dungeon":"broken_reliquary_chapel","target_position":Vector2i(12,23),"target_facing":0,"requires_interact":true}
	},
	"events": {
		Vector2i(14,14): {"id":"lower_ossuary","type":"lore","message":"The central ossuary has been emptied. Hundreds of bones are arranged in concentric circles around the crowned black-flame symbol of the Black Warlock."},
		Vector2i(23,23): {"id":"reliquary_treasure_4","type":"treasure","gold":260,"item_id":"sun_priest_ring","message":"A sealed crypt hidden deep in the maze holds a priest's ring and a cache of funeral offerings untouched by Bristle-Aptarj."}
	}
}
