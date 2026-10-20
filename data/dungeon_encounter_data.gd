class_name DungeonEncounterData
extends RefCounted

const TABLES = {
	"architect_test_catacombs_upper":[{"enemy_id":"skeleton","min_group":1,"max_group":2,"weight":1}],
	"architect_test_archives":[{"enemy_id":"skeleton","min_group":1,"max_group":2,"weight":1}],
	"architect_test_church_nave":[{"enemy_id":"skeleton","min_group":1,"max_group":2,"weight":1}],
	"abandoned_warehouse":[{"enemy_id":"giant_rat","min_group":1,"max_group":4,"weight":10}],
	"wine_cellar":[{"enemy_id":"giant_rat","min_group":1,"max_group":4,"weight":6},{"enemy_id":"wino","min_group":1,"max_group":2,"weight":3},{"enemy_id":"bar_fly","min_group":2,"max_group":5,"weight":4},{"enemy_id":"drunken_slob","min_group":1,"max_group":3,"weight":3},{"enemy_id":"cellar_mold","min_group":1,"max_group":3,"weight":2}],
	"thornwake_sewers_upper":[{"enemy_id":"giant_rat","min_group":2,"max_group":5,"weight":5},{"enemy_id":"goblin","min_group":1,"max_group":4,"weight":5},{"enemy_id":"green_slime","min_group":1,"max_group":3,"weight":4},{"enemy_id":"sewer_jelly","min_group":1,"max_group":3,"weight":3},{"enemy_id":"sewer_crawler","min_group":1,"max_group":2,"weight":2}],
	"thornwake_sewers_lower":[{"enemy_id":"goblin","min_group":2,"max_group":5,"weight":4},{"enemy_id":"green_slime","min_group":1,"max_group":4,"weight":4},{"enemy_id":"sewer_jelly","min_group":1,"max_group":3,"weight":4},{"enemy_id":"sewer_crawler","min_group":1,"max_group":3,"weight":3},{"enemy_id":"giant_spider","min_group":1,"max_group":3,"weight":2}],
	"old_prison_barracks":[{"enemy_id":"bandit","min_group":2,"max_group":5,"weight":7},{"enemy_id":"bandit_lookout","min_group":2,"max_group":4,"weight":4},{"enemy_id":"bandit_archer","min_group":1,"max_group":3,"weight":3}],
	"old_prison_holding":[{"enemy_id":"bandit","min_group":2,"max_group":5,"weight":5},{"enemy_id":"bandit_bruiser","min_group":1,"max_group":3,"weight":4},{"enemy_id":"bandit_cutthroat","min_group":1,"max_group":3,"weight":4},{"enemy_id":"bandit_archer","min_group":1,"max_group":3,"weight":2}],
	"old_prison_torture":[{"enemy_id":"bandit_veteran","min_group":1,"max_group":3,"weight":5},{"enemy_id":"bandit_cutthroat","min_group":2,"max_group":4,"weight":4},{"enemy_id":"bandit_bruiser","min_group":1,"max_group":3,"weight":3}],
	"old_prison_morgue":[{"enemy_id":"bandit_veteran","min_group":2,"max_group":4,"weight":6},{"enemy_id":"bandit_cutthroat","min_group":2,"max_group":4,"weight":3}],
	"broken_reliquary_church":[{"enemy_id":"skeleton","min_group":2,"max_group":5,"weight":6},{"enemy_id":"zombie","min_group":1,"max_group":4,"weight":6},{"enemy_id":"ghoul","min_group":1,"max_group":2,"weight":2}],
	"broken_reliquary_archives":[{"enemy_id":"skeleton","min_group":2,"max_group":5,"weight":5},{"enemy_id":"zombie","min_group":2,"max_group":4,"weight":5},{"enemy_id":"ghoul","min_group":1,"max_group":3,"weight":4},{"enemy_id":"restless_dead","min_group":1,"max_group":3,"weight":3}],
	"broken_reliquary_catacombs_upper":[{"enemy_id":"armored_skeleton","min_group":1,"max_group":4,"weight":5},{"enemy_id":"zombie","min_group":2,"max_group":5,"weight":4},{"enemy_id":"ghoul","min_group":2,"max_group":4,"weight":5},{"enemy_id":"crypt_hound","min_group":1,"max_group":3,"weight":3},{"enemy_id":"restless_dead","min_group":2,"max_group":4,"weight":3}],
	"broken_reliquary_catacombs_lower":[{"enemy_id":"armored_skeleton","min_group":2,"max_group":5,"weight":4},{"enemy_id":"ghoul","min_group":2,"max_group":5,"weight":4},{"enemy_id":"wight","min_group":1,"max_group":3,"weight":4},{"enemy_id":"wraith","min_group":1,"max_group":3,"weight":3},{"enemy_id":"bone_knight","min_group":1,"max_group":2,"weight":3},{"enemy_id":"black_acolyte","min_group":1,"max_group":3,"weight":2}],
	"broken_reliquary_chapel":[{"enemy_id":"wight","min_group":1,"max_group":3,"weight":4},{"enemy_id":"wraith","min_group":1,"max_group":3,"weight":4},{"enemy_id":"bone_knight","min_group":1,"max_group":3,"weight":4},{"enemy_id":"black_acolyte","min_group":2,"max_group":4,"weight":5},{"enemy_id":"armored_skeleton","min_group":2,"max_group":5,"weight":3}]
}

static func get_table(dungeon_id:String)->Array:
	return TABLES.get(dungeon_id,[])
