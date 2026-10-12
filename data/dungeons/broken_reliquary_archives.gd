class_name BrokenReliquaryArchivesData
extends RefCounted

const DATA = {
	"id": "broken_reliquary_archives",
	"name": "Broken Reliquary — Forgotten Archives",
	"map": [
		"#####################",
		"#............########",
		"#............#.....##",
		"#..##.####.#.......##",
		"#...#...#...##.....##",
		"#...#.#####.#########",
		"#.....#...#.........#",
		"#..##.#########.##..#",
		"#...#.#.#.#.#...#...#",
		"#...#.##.##.#...#...#",
		"#...................#",
		"#..##.####.####.##..#",
		"#...#...#...#...#...#",
		"#...#...#...#...#...#",
		"#...................#",
		"#..##.####.####.##..#",
		"#...#...#...#...#...#",
		"#...................#",
		"#...................#",
		"#...................#",
		"#####################"
	],
	"start_position": Vector2i(1, 1),
	"start_facing": 1,
	"transitions": {
		Vector2i(1,1): {"target_dungeon":"broken_reliquary_church","target_position":Vector2i(12,3),"target_facing":2,"requires_interact":true},
		Vector2i(19,19): {"target_dungeon":"broken_reliquary_catacombs_upper","target_position":Vector2i(1,27),"target_facing":0,"requires_interact":true}
	},
	"events": {
		Vector2i(15,3): {"id":"reliquary_treasure_2","type":"treasure","gold":140,"item_id":"blessed_chain","message":"A locked records coffer gives way. Beneath brittle vestments lie coins and a shirt of chain etched with tiny rays of the sun."},
		Vector2i(6,10): {"id":"archive_warning","type":"lore","message":"A crumbling journal records that Bristle-Aptarj was forbidden from the lower chapel after requesting burial ledgers and proscribed funerary texts."},
		Vector2i(14,14): {"id":"archive_ritual","type":"lore","message":"Torn notes describe Bristle-Aptarj's plan: bind every corpse beneath the church into one necromantic host and march that army across Ashenwood."},
		Vector2i(18,18): {"id":"archive_failure","type":"lore","message":"The final surviving page is scorched. The ritual began before its calculations were complete. The dead rose — but Bristle-Aptarj and his army were trapped below long enough for Harlic's wardens to seal the church."}
	}
}
