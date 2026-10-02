class_name OldPrisonHoldingData
extends RefCounted

const DATA = {
	"id": "old_prison_holding",
	"name": "Old Prison — Prisoner Holding",
	"zone": "ashenwood",
	"town": "grayhaven",
	"map": [
		"#########################",
		"#.............#.........#",
		"#.###########.#.#####.#.#",
		"#.....#.......#...#...#.#",
		"#.##.....##.###.....###.#",
		"#.........#.........#...#",
		"####......#####.....#.###",
		"#...#...#...........#...#",
		"#.#.#.#.#.#####.....###.#",
		"#.#...#.#.....#.#.#...#.#",
		"#.#####.#####.#.###.###.#",
		"#...#.#.#...#.#...#.....#",
		"#.#.#.#.#.#.###.#.#.#####",
		"#.#.#.....#...#.#.#...#.#",
		"###.#########.#.#.###.#.#",
		"#...#.......#.#.#.#.#...#",
		"#.#.........#.#.#.#.###.#",
		"#.#.........#.#.........#",
		"#.#.........#.#.....#####",
		"#.#.........#.#.....#...#",
		"#.##.......##.#.#.#.###.#",
		"#.....#...#...#.#.#.....#",
		"#######.###.#####.#####.#",
		"#.......#.........#.....#",
		"#########################"
	],
	"start_position": Vector2i(1, 23),
	"start_facing": 0,
	"fixed_encounters": {},
	"transitions": {
		Vector2i(1, 23): {"target_dungeon":"old_prison_barracks", "target_position":Vector2i(23,1), "target_facing":2, "requires_interact":true},
		Vector2i(23, 1): {"target_dungeon":"old_prison_torture", "target_position":Vector2i(1,19), "target_facing":0, "requires_interact":true}
	}
}
