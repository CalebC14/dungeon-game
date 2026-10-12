class_name WildernessEncounterData
extends RefCounted

const TABLES = {
	"ashenwood_wilderness": [
		{"enemy_id":"giant_rat", "min_group":2, "max_group":5, "weight":3},
		{"enemy_id":"goblin", "min_group":1, "max_group":4, "weight":5},
		{"enemy_id":"giant_spider", "min_group":1, "max_group":3, "weight":3},
		{"enemy_id":"sewer_crawler", "min_group":1, "max_group":2, "weight":1}
	],
	"dreadmarch_wilderness": [
		{"enemy_id":"wolf", "min_group":2, "max_group":4, "weight":3},
		{"enemy_id":"bandit_veteran", "min_group":1, "max_group":3, "weight":3},
		{"enemy_id":"armored_skeleton", "min_group":1, "max_group":4, "weight":4},
		{"enemy_id":"wight", "min_group":1, "max_group":2, "weight":1}
	]
}

static func get_table(id: String) -> Array:
	return TABLES.get(id, [])
