class_name ThornwakeData
extends RefCounted

const DATA = {
	"id": "thornwake",
	"name": "Thornwake",
	"zone": "ashenwood",
	"map": [
		"#################",
		"#...............#",
		"#...............#",
		"#.....#####.....#",
		"#.....#...#.....#",
		"#.....#...#.....#",
		"#.....#...#.....#",
		"#.....#####.....#",
		"#...............#",
		"#...............#",
		"#...............#",
		"#...............#",
		"#................",
		"#...............#",
		"#################"
	],
	"start_position": Vector2i(3, 2),
	"start_facing": 1,
	"locations": {
		Vector2i(2, 2): {
			"type": "guild",
			"name": "Adventurers' Guild"
		},
		Vector2i(8, 2): {
			"type": "town_hall",
			"name": "Thornwake Town Hall"
		},
		Vector2i(13, 2): {
			"type": "training_hall",
			"name": "Training Hall"
		},
		Vector2i(2, 6): {
			"type": "shop",
			"name": "General Store"
		},
		Vector2i(14, 6): {
			"type": "inn",
			"name": "The Wayfarer's Inn"
		},
		Vector2i(6, 12): {
			"type": "temple",
			"name": "Temple"
		},
		Vector2i(8, 10): {
			"type": "dungeon",
			"name": "Abandoned Warehouse",
			"dungeon_id": "abandoned_warehouse"
		},
		Vector2i(16, 12): {
			"type": "wilderness_exit",
			"name": "East Gate — Ashenwood"
		}
	}
}
