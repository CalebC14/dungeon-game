class_name AshenwoodWildernessData
extends RefCounted

const DATA = {
	"id": "ashenwood_wilderness",
	"name": "Ashenwood Wilderness",
	"map": [
		"TTTTTTTTTTTTTTTTTTTTT",
		"T....fff...T....fff..T",
		"T.TT.fTf...T.TT.fTf.T",
		"T....fTf.....TT.fTf..T",
		"T.====f==========f...T",
		"T.=..fff..TT....=....T",
		"T.=.TTTT..TT.fff=....T",
		"T.=.......fff...=....T",
		"T.=======B=======....T",
		"T....fff.~.fff..=....T",
		"T.TT.fTf.~.fTf..=....T",
		"T....fTf.~.fff..=....T",
		"T.======B=======.=...T",
		"T.=..fff.~.....=.=...T",
		"T.=.fTf..~.TT..=.=...T",
		"T.=.fff..~.....=.=...T",
		"T.=======B=======.=..T",
		"T....fff...fff....=..T",
		"T.TT.fTf.T.fTf....=..T",
		"T...................=T",
		"TTTTTTTTTTTTTTTTTTTTT"
	],
	"start_position": Vector2i(2, 4),
	"start_facing": 1,
	"locations": {
		Vector2i(2, 4): {"type":"town", "town_id":"thornwake", "name":"Thornwake Gate"},
		Vector2i(19, 19): {"type":"town", "town_id":"grayhaven", "name":"Grayhaven"},
		Vector2i(2, 16): {"type":"dungeon", "dungeon_id":"broken_reliquary", "name":"The Broken Reliquary"}
	}
}
