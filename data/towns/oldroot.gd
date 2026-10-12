class_name OldrootData
extends RefCounted

const DATA = {
	"id": "oldroot",
	"name": "Oldroot",
	"zone": "dreadmarch",
	"map": [
		"#################",
		"#...............#",
		"#....#####......#",
		"#....#...#......#",
		"#....#####......#",
		"#...............#",
		"#...............#",
		".................",
		"#...............#",
		"#....#####......#",
		"#....#...#......#",
		"#....#####......#",
		"#...............#",
		"#...............#",
		"#################"
	],
	"start_position": Vector2i(1, 7),
	"start_facing": 1,
	"locations": {
		Vector2i(0, 7): {"type":"wilderness_exit", "name":"West Gate — Dreadmarch"},
		Vector2i(16, 7): {"type":"wilderness_exit", "name":"East Gate — Dreadmarch"},
		Vector2i(3, 3): {"type":"inn", "name":"The Old Root Inn"},
		Vector2i(13, 3): {"type":"training_hall", "name":"Oldroot Training Hall"},
		Vector2i(3, 11): {"type":"shop", "name":"Oldroot General Store"},
		Vector2i(13, 11): {"type":"temple", "name":"Temple of Tay'lore"}
	}
}
