class_name OldPrisonMorgueData
extends RefCounted

const DATA = {
	"id":"old_prison_morgue",
	"name":"Old Prison — Prison Morgue",
	"zone":"ashenwood",
	"town":"grayhaven",
	"map":[
		"###############",
		"#.....#.#.....#",
		"#.###.#.#.###.#",
		"#.#.........#.#",
		"#.#.#######.#.#",
		"#.#.#.....#.#.#",
		"#...#.....#...#",
		"###.........###",
		"#...#.....#...#",
		"#.#.#.....#.#.#",
		"#.#.#######.#.#",
		"#.#.........#.#",
		"#.###.#.#.###.#",
		"#.............#",
		"###############"
	],
	"start_position":Vector2i(7,13),
	"start_facing":0,
	"fixed_encounters":{
		Vector2i(7, 7): {
			"id":"onika_boss",
			"tag":"onika_bandit_queen",
			"groups":[
				{"enemy_id":"onika_bandit_queen","count":1},
				{"enemy_id":"bandit_veteran","count":2},
				{"enemy_id":"bandit_bruiser","count":1},
				{"enemy_id":"bandit_archer","count":1},
				{"enemy_id":"bandit_cutthroat","count":1}
			],
			"intro":"Onika the Bandit Queen rises in the morgue's central chamber. Five of her deadliest lieutenants close ranks around her. The stair door out of the prison stands behind them."
		}
	},
	"transitions":{
		Vector2i(7,13): {"target_dungeon":"old_prison_torture", "target_position":Vector2i(19,1), "target_facing":2, "requires_interact":true},
		Vector2i(7,5): {"to_city":true, "to_city_id":"grayhaven", "requires_interact":true}
	}
}
