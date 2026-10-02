class_name OldPrisonTortureData
extends RefCounted

const DATA = {
	"id": "old_prison_torture",
	"name": "Old Prison — Torture Chamber",
	"zone": "ashenwood",
	"town": "grayhaven",
	"map": [
		"#####################",
		"#.........#.....#...#",
		"#####.###.#.###.#.#.#",
		"#.....#...#...#...#.#",
		"#.##.....######.....#",
		"#.#.......#.........#",
		"#.##......#.###.....#",
		"#.......#...#.#.....#",
		"#####.#.#####.#.....#",
		"#...#.#.#...#.#.#.#.#",
		"#.#.#.#.#.#.#.#.#.###",
		"#.#.#.#.#.#.#.#.#...#",
		"#.#.........#.#.#.#.#",
		"#.#...........#.....#",
		"#.#........####.....#",
		"#.#...........#.....#",
		"#.##.......##.#####.#",
		"#.....#...#.#.#.....#",
		"#####.#.###.#.#.#####",
		"#.....#.....#.......#",
		"#####################"
	],
	"start_position": Vector2i(1, 19),
	"start_facing": 0,
	"fixed_encounters": {},
	"transitions": {
		Vector2i(1, 19): {"target_dungeon":"old_prison_holding", "target_position":Vector2i(23,1), "target_facing":2, "requires_interact":true},
		Vector2i(19, 1): {"target_dungeon":"old_prison_morgue", "target_position":Vector2i(7,13), "target_facing":0, "requires_interact":true}
	}
}
