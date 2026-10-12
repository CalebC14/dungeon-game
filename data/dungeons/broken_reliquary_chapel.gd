class_name BrokenReliquaryChapelData
extends RefCounted

const DATA = {
	"id": "broken_reliquary_chapel",
	"name": "Broken Reliquary — Chapel of the Black Warlock",
	"map": [
		"#########################",
		"#........#######........#",
		"#........#.....#........#",
		"#.########.....########.#",
		"#.#.....####.####.....#.#",
		"#.#.....#.......#.....#.#",
		"#.#...................#.#",
		"#.#.....####.####.....#.#",
		"#.#########...#########.#",
		"#.......................#",
		"#.######.........######.#",
		"#.#....#.........#....#.#",
		"#.#....#.........#....#.#",
		"#.#...................#.#",
		"#.#....#.........#....#.#",
		"#.#....#.........#....#.#",
		"#.#....#.........#....#.#",
		"#.######.........######.#",
		"#.......................#",
		"#.......................#",
		"#.......................#",
		"#.......................#",
		"#.......................#",
		"#.......................#",
		"#########################"
	],
	"start_position": Vector2i(12, 23),
	"start_facing": 0,
	"fixed_encounters": {
		Vector2i(12, 7): {
			"id": "bristle_aptarj",
			"tag": "bristle_aptarj",
			"groups": [
				{"enemy_id": "bristle_aptarj", "count": 1},
				{"enemy_id": "black_acolyte", "count": 2},
				{"enemy_id": "wight", "count": 1},
				{"enemy_id": "armored_skeleton", "count": 2}
			],
			"intro": "At the head of the ruined chapel, Bristle-Aptarj preaches from a blackened altar. His undead congregation turns as one. \"The living have come to kneel,\" he says."
		}
	},
	"transitions": {
		Vector2i(12, 23): {
			"target_dungeon": "broken_reliquary_catacombs_lower",
			"target_position": Vector2i(3, 25),
			"target_facing": 1,
			"requires_interact": true
		},
		Vector2i(12, 2): {
			"target_dungeon": "broken_reliquary_church",
			"target_position": Vector2i(12, 22),
			"target_facing": 2,
			"requires_interact": true
		}
	},
	"events": {
		Vector2i(12, 18): {
			"id": "bristle_sermon",
			"type": "lore",
			"message": "A voice rolls through the stone ahead: 'From death shall rise our dominion. From darkness, our salvation.' A congregation answers with a dry chorus of moans."
		},
		Vector2i(12, 2): {
			"id": "reliquary_treasure_5",
			"type": "treasure",
			"gold": 500,
			"item_id": "holy_symbol_taylore",
			"message": "Beyond Bristle-Aptarj's altar lies the sealed treasury. Gold surrounds a long, thin chain, cold to the touch, with a gold T at the end — the Holy Symbol of Tay'lore. A restored portal shimmers at the rear of the chamber."
		}
	}
}
