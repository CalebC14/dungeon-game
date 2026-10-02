class_name ThornwakeSewersLowerData
extends RefCounted

const DATA = {
	"id":"thornwake_sewers_lower",
	"name":"Thornwake Sewers - Deep Cistern",
	"zone":"ashenwood",
	"town":"thornwake",
	"map":["#####################", "#...........#.......#", "#.#########.#.#####.#", "#.#.......#.#.....#.#", "#.#.#####.#.#####.#.#", "#.#.#...#.#.....#.#.#", "#.#.#.#.#.#####.#.#.#", "#...#.#.#.....#.#...#", "#####.#.#####.#.###.#", "#.....#.......#.....#", "#.###############.#.#", "#.....#.........#.#.#", "#.###.#.#######.#.#.#", "#...#.#.#.....#.#.#.#", "###.#.#.#.###.#.#.#.#", "#...#...#...#.#...#.#", "#.#########.#.#####.#", "#.........#.#.......#", "#.#######.#.#######.#", "#...................#", "#####################"],
	"start_position":Vector2i(1,1),
	"start_facing":2,
	"fixed_encounters":{
		Vector2i(19,19):{
			"id":"sewer_troll_boss",
			"tag":"sewer_troll_boss",
			"enemy_id":"sewer_troll",
			"count":1,
			"intro":"A hulking Sewer Troll rises beside the exit stair. Around its neck hangs a sealed bottle in a filthy leather sling!"
		}
	},
	"transitions":{
		Vector2i(19,19):{
			"to_city":true,
			"requires_interact":true
		}
	}
}
