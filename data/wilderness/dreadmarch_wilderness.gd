class_name DreadmarchWildernessData
extends RefCounted

const DATA = {
	"id": "dreadmarch_wilderness",
	"name": "The Dreadmarch",
	"start_position": Vector2i(2, 10),
	"start_facing": 1,
	"start_message": "Wind drives dust across the stony western Dreadmarch. Oldroot stands nearby.",
	"map": [
		"^^^^^^^^^^^^^^^^^^^^^^^^^",
		"^....,,,,....RR....,,,,.^",
		"^..,,,,.....RR.....,,,..^",
		"^....====....R....====..^",
		"^....=..=.........=..=..^",
		"^.,,.=..====...====..=..^",
		"^.,,.=.....R...R.....=..^",
		"^....=====..R...R..===..^",
		"^........=..R...R..=....^",
		"^..RR....=.........=.,..^",
		"=====....===========.,..^",
		"^..RR....=....,,,,.=.,..^",
		"^........=..RR.....=....^",
		"^..,,,,..=..RR..====....^",
		"^........=......=.......^",
		"^..RR....========..,,,,.^",
		"^..RR...........=.......^",
		"^..,,,,.........=====...^",
		"^........RR.............^",
		"^..,,,,..RR....,,,,.....^",
		"^^^^^^^^^^^^^^^^^^^^^^^^^"
	],
	"locations": {
		Vector2i(0, 10): {"type":"zone_exit", "wilderness_id":"ashenwood_wilderness", "name":"Western Road — Ashenwood"},
		Vector2i(2, 10): {"type":"town", "town_id":"oldroot", "name":"Oldroot"},
		Vector2i(21, 17): {"type":"town", "town_id":"ironreach", "name":"Ironreach"},
		Vector2i(20, 4): {"type":"fort_dread", "name":"Fort Dread"}
	}
}
