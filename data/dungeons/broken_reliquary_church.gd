class_name BrokenReliquaryChurchData
extends RefCounted

const DATA = {
	"id": "broken_reliquary_church",
	"name": "Broken Reliquary — Desecrated Church",
	"town": "",
	"map": [
		"#########################",
		"#.......................#",
		"#.......................#",
		"#.######.........######.#",
		"#.#....#.........#....#.#",
		"#.#....#.........#....#.#",
		"#.#......##...###.....#.#",
		"#.#....#.........#....#.#",
		"#.#....#.........#....#.#",
		"#.######.........######.#",
		"#.......................#",
		"#.......................#",
		"#.######.........######.#",
		"#.#....#.........#....#.#",
		"#.#....#.........#....#.#",
		"#.#...................#.#",
		"#.#....#.........#....#.#",
		"#.#....#.........#....#.#",
		"#.######.........######.#",
		"#.......................#",
		"#.########.....########.#",
		"#.......................#",
		"#.......................#",
		"#.......................#",
		"#########################"
	],
	"start_position": Vector2i(12, 23),
	"start_facing": 0,
	"fixed_encounters": {
		Vector2i(12, 3): {
			"id": "grave_sacristan",
			"tag": "grave_sacristan",
			"groups": [
				{"enemy_id":"grave_sacristan","count":1},
				{"enemy_id":"armored_skeleton","count":2},
				{"enemy_id":"zombie","count":2}
			],
			"intro": "The Grave Sacristan rises before the shattered dais. Armored dead and rotting parishioners close around it. Behind them, iron rings are set into a hidden trapdoor."
		}
	},
	"transitions": {
		Vector2i(12, 23): {"to_wilderness":true,"requires_interact":true},
		Vector2i(12, 3): {"target_dungeon":"broken_reliquary_archives","target_position":Vector2i(1,1),"target_facing":1,"requires_interact":true}
	},
	"events": {
		Vector2i(3, 6): {"id":"reliquary_treasure_1","type":"treasure","gold":90,"item_id":"sun_touched_sword","message":"A battered offering chest survives in the ruined side chapel. Inside are old coins and a sword whose faded sun-mark still glints."},
		Vector2i(12, 10): {"id":"church_desecration","type":"lore","message":"The nave was once dedicated to Tay'lore, Goddess of the Sun. Her golden mosaics have been hacked apart and smeared with black wax."}
	}
}
