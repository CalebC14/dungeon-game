class_name IronreachData
extends RefCounted

const DATA = {
	"id": "ironreach",
	"name": "Ironreach",
	"zone": "dreadmarch",
	"map": [
		"#####################",
		"#...................#",
		"#....#####.#####....#",
		"#....#...#.#...#....#",
		"#....#####.#####....#",
		"#...................#",
		"#...................#",
		"#....###.....###....#",
		".....................",
		"#....###.....###....#",
		"#...................#",
		"#...................#",
		"#....#####.#####....#",
		"#....#...#.#...#....#",
		"#....#####.#####....#",
		"#...................#",
		"#####################"
	],
	"start_position": Vector2i(1, 8),
	"start_facing": 1,
	"locations": {
		Vector2i(0, 8): {"type":"wilderness_exit", "name":"West Gate — Dreadmarch"},
		Vector2i(20, 8): {"type":"wilderness_exit", "name":"East Gate — Dreadmarch"},
		Vector2i(3, 3): {"type":"inn", "name":"The Marcher's Rest"},
		Vector2i(17, 3): {"type":"training_hall", "name":"Ironreach Training Hall"},
		Vector2i(3, 13): {"type":"shop", "name":"Ironreach General Store"},
		Vector2i(17, 13): {"type":"temple", "name":"Temple of Tay'lore"}
	}
}
