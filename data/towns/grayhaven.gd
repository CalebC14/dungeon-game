class_name GrayhavenData
extends RefCounted

const DATA = {
	"id": "grayhaven",
	"name": "Grayhaven",
	"zone": "ashenwood",
	"map": [
		"#################",
		"#...............#",
		"#....#####......#",
		"#....#...#......#",
		"#....#...#......#",
		"#....##.##......#",
		"#...............#",
		"................#",
		"#...............#",
		"#....##.##......#",
		"#....#...#......#",
		"#....#####......#",
		"#...............#",
		"#...............#",
		"#################"
	],
	"start_position": Vector2i(1, 7),
	"start_facing": 1,
	"locations": {
		Vector2i(0, 7): {"type":"wilderness_exit", "name":"West Gate — Ashenwood"},
		Vector2i(7, 5): {"type":"warden_keep", "name":"Warden Keep"},
		Vector2i(3, 5): {"type":"inn", "name":"The Iron Lantern Inn"},
		Vector2i(13, 5): {"type":"training_hall", "name":"Grayhaven Training Hall"},
		Vector2i(7, 9): {"type":"dungeon", "name":"Old Prison", "dungeon_id":"old_prison_barracks"}
	}
}
