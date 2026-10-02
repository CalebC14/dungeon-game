class_name WineCellarData
extends RefCounted


const DATA = {
	"id": "wine_cellar",
	"name": "Wayfarer's Wine Cellar",
	"zone": "ashenwood",
	"town": "thornwake",

	"map": [
		"#####################",
		"#.....#.......#.....#",
		"#.###.#.#####.#.###.#",
		"#.#...#.....#.#...#.#",
		"#.#.#######.#.###.#.#",
		"#.#.........#.....#.#",
		"#.#########.#####.#.#",
		"#.....#.....#.....#.#",
		"#####.#.#####.#####.#",
		"#.....#.....#.......#",
		"#.#########.#.#####.#",
		"#.#.......#.#.....#.#",
		"#.#.#####.#.#####.#.#",
		"#.#.....#.#.......#.#",
		"#.#####.#.#########.#",
		"#.......#...........#",
		"#.###############.#.#",
		"#.................#.#",
		"#.###############.#.#",
		"#...................#",
		"#####################"
	],

	"start_position": Vector2i(1, 19),
	"start_facing": 0,

	"fixed_encounters": {},

	"transitions": {
		Vector2i(19, 1): {
			"target_dungeon": "thornwake_sewers_upper",
			"intro": "A jagged hole has opened in the cellar floor. A foul draft rises from below."
		}
	}
}
