class_name DungeonEncounterData
extends RefCounted

const TABLES = {
	"abandoned_warehouse":[{"enemy_id":"giant_rat","min_group":1,"max_group":4,"weight":10}],
	"wine_cellar":[{"enemy_id":"giant_rat","min_group":1,"max_group":4,"weight":6},{"enemy_id":"wino","min_group":1,"max_group":2,"weight":3},{"enemy_id":"bar_fly","min_group":2,"max_group":5,"weight":4},{"enemy_id":"drunken_slob","min_group":1,"max_group":3,"weight":3},{"enemy_id":"cellar_mold","min_group":1,"max_group":3,"weight":2}],
	"thornwake_sewers_upper":[{"enemy_id":"giant_rat","min_group":2,"max_group":5,"weight":5},{"enemy_id":"goblin","min_group":1,"max_group":4,"weight":5},{"enemy_id":"green_slime","min_group":1,"max_group":3,"weight":4},{"enemy_id":"sewer_jelly","min_group":1,"max_group":3,"weight":3},{"enemy_id":"sewer_crawler","min_group":1,"max_group":2,"weight":2}],
	"thornwake_sewers_lower":[{"enemy_id":"goblin","min_group":2,"max_group":5,"weight":4},{"enemy_id":"green_slime","min_group":1,"max_group":4,"weight":4},{"enemy_id":"sewer_jelly","min_group":1,"max_group":3,"weight":4},{"enemy_id":"sewer_crawler","min_group":1,"max_group":3,"weight":3},{"enemy_id":"giant_spider","min_group":1,"max_group":3,"weight":2}],
	"old_prison_barracks":[{"enemy_id":"bandit","min_group":2,"max_group":5,"weight":7},{"enemy_id":"bandit_lookout","min_group":2,"max_group":4,"weight":4},{"enemy_id":"bandit_archer","min_group":1,"max_group":3,"weight":3}],
	"old_prison_holding":[{"enemy_id":"bandit","min_group":2,"max_group":5,"weight":5},{"enemy_id":"bandit_bruiser","min_group":1,"max_group":3,"weight":4},{"enemy_id":"bandit_cutthroat","min_group":1,"max_group":3,"weight":4},{"enemy_id":"bandit_archer","min_group":1,"max_group":3,"weight":2}],
	"old_prison_torture":[{"enemy_id":"bandit_veteran","min_group":1,"max_group":3,"weight":5},{"enemy_id":"bandit_cutthroat","min_group":2,"max_group":4,"weight":4},{"enemy_id":"bandit_bruiser","min_group":1,"max_group":3,"weight":3}],
	"old_prison_morgue":[{"enemy_id":"bandit_veteran","min_group":2,"max_group":4,"weight":6},{"enemy_id":"bandit_cutthroat","min_group":2,"max_group":4,"weight":3}]
}
static func get_table(dungeon_id:String)->Array: return TABLES.get(dungeon_id,[])
