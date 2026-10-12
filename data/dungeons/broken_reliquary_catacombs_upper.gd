class_name BrokenReliquaryCatacombsUpperData
extends RefCounted

const DATA = {
	"id": "broken_reliquary_catacombs_upper",
	"name": "Broken Reliquary — Upper Catacombs",
	"map": [
		"#############################",
		"#...#.......#.........#.....#",
		"#.###.#####.#.#####.#.#.....#",
		"#.........#...#.....#.......#",
		"###########.###.#######.....#",
		"#...#.....#.#...#.....#.....#",
		"#.#.#.###.###.###.#####.#.#.#",
		"#.#...#.#.#...#...#...#.#.#.#",
		"#.#####.#.#.###.#.#.#.#.###.#",
		"#.#.........#...#.#.#...#...#",
		"#.###########.#.#.#.#####.###",
		"#.#.....#.....#.#.#.#.#.....#",
		"#.#.....#.#####.###.#.#.###.#",
		"#.#.....#.....#.....#.#.#...#",
		"#.#.....#######.#####.#.#.###",
		"#.#...........#.#.#.....#...#",
		"#.#.#.#######.#.#.#.#######.#",
		"#...........#.#.#.......#...#",
		"#.###########.#.###.###.#.###",
		"#.#...#...#...#.........#...#",
		"###.#.#.#.#.#####.....#####.#",
		"#...#...#...#.#.......#...#.#",
		"#.###########.#.#.....#.#.#.#",
		"#.....#...#...#.#.....#.#...#",
		"#####.#.###.#.#.#.###.#.###.#",
		"#...#.#...#.#.#.#...#.#...#.#",
		"#.#.#.#.#.#.#.#.#.###.###.#.#",
		"#.#...#.#...#...#.........#.#",
		"#############################"
	],
	"start_position": Vector2i(1, 27),
	"start_facing": 0,
	"fixed_encounters": {
		Vector2i(25,3): {
			"id":"sisters_bella_gigi",
			"tag":"sisters_bella_gigi",
			"groups":[{"enemy_id":"sister_bella","count":1},{"enemy_id":"sister_gigi","count":1},{"enemy_id":"armored_skeleton","count":2}],
			"intro":"Two black-veiled nuns wait before the descending stair. Sister Bella raises a rusted mace while Sister Gigi whispers a prayer to the Black Warlock. They betrayed Tay'lore in life and serve Bristle-Aptarj still."
		}
	},
	"transitions": {
		Vector2i(1,27): {"target_dungeon":"broken_reliquary_archives","target_position":Vector2i(19,19),"target_facing":3,"requires_interact":true},
		Vector2i(25,3): {"target_dungeon":"broken_reliquary_catacombs_lower","target_position":Vector2i(27,1),"target_facing":2,"requires_interact":true}
	},
	"events": {
		Vector2i(5,13): {"id":"taylore_fountain","type":"fountain","message":"Clear water still spills from a golden sun into an untouched stone basin. Tay'lore's old blessing lingers here."},
		Vector2i(19,21): {"id":"reliquary_treasure_3","type":"treasure","gold":190,"item_id":"dawn_ward","message":"At the end of a false passage, an intact burial coffer contains old gold and a small shield bearing Tay'lore's rising sun."}
	}
}
