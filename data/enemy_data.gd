class_name EnemyData
extends RefCounted

const ENEMIES = {
	"giant_rat": {"id":"giant_rat","name":"Giant Rat","hp":7,"attack":3,"dex":13,"base_accuracy":0.58,"base_avoidance":0.10,"absorption":0,"damage_min":1,"damage_max":3,"xp":8,"gold_min":1,"gold_max":3,"tags":["beast"]},
	"rat_broodmother": {"id":"rat_broodmother","name":"Rat Broodmother","hp":42,"attack":7,"dex":12,"base_accuracy":0.68,"base_avoidance":0.08,"absorption":1,"damage_min":3,"damage_max":7,"xp":75,"gold_min":20,"gold_max":35,"tags":["beast","boss"]},
	"kobold": {"id":"kobold","name":"Kobold","hp":8,"attack":3,"dex":12,"base_accuracy":0.60,"base_avoidance":0.08,"absorption":0,"damage_min":1,"damage_max":3,"xp":10,"gold_min":2,"gold_max":5,"tags":["humanoid"]},
	"goblin": {"id":"goblin","name":"Goblin","hp":10,"attack":4,"dex":11,"base_accuracy":0.62,"base_avoidance":0.07,"absorption":1,"damage_min":1,"damage_max":4,"xp":12,"gold_min":3,"gold_max":7,"tags":["humanoid"]},
	"skeleton": {"id":"skeleton","name":"Skeleton","hp":12,"attack":4,"dex":8,"base_accuracy":0.58,"base_avoidance":0.02,"absorption":2,"damage_min":2,"damage_max":4,"xp":14,"gold_min":1,"gold_max":4,"tags":["undead"]},
	"wolf": {"id":"wolf","name":"Wolf","hp":11,"attack":5,"dex":14,"base_accuracy":0.68,"base_avoidance":0.12,"absorption":0,"damage_min":2,"damage_max":5,"xp":16,"gold_min":0,"gold_max":0,"tags":["beast"]},
	"zombie": {"id":"zombie","name":"Zombie","hp":18,"attack":5,"dex":5,"base_accuracy":0.55,"base_avoidance":0.00,"absorption":2,"damage_min":2,"damage_max":5,"xp":18,"gold_min":0,"gold_max":3,"tags":["undead"]},
	"orc": {"id":"orc","name":"Orc","hp":16,"attack":6,"dex":9,"base_accuracy":0.65,"base_avoidance":0.04,"absorption":2,"damage_min":3,"damage_max":6,"xp":22,"gold_min":5,"gold_max":10,"tags":["humanoid"]},
	"giant_spider": {"id":"giant_spider","name":"Giant Spider","hp":12,"attack":5,"dex":15,"base_accuracy":0.70,"base_avoidance":0.14,"absorption":0,"damage_min":2,"damage_max":5,"xp":24,"gold_min":1,"gold_max":4,"tags":["beast","venomous"]},
	"ghoul": {"id":"ghoul","name":"Ghoul","hp":17,"attack":6,"dex":11,"base_accuracy":0.67,"base_avoidance":0.07,"absorption":2,"damage_min":3,"damage_max":6,"xp":30,"gold_min":3,"gold_max":8,"tags":["undead"]},
	"ogre": {"id":"ogre","name":"Ogre","hp":30,"attack":8,"dex":6,"base_accuracy":0.60,"base_avoidance":0.01,"absorption":3,"damage_min":4,"damage_max":8,"xp":45,"gold_min":10,"gold_max":25,"tags":["giant"]}

,
	"wino":{"id":"wino","name":"Wino","hp":13,"attack":4,"dex":9,"base_accuracy":0.58,"base_avoidance":0.04,"absorption":0,"damage_min":2,"damage_max":4,"xp":16,"gold_min":2,"gold_max":8,"tags":["humanoid","cellar"]},
	"bar_fly":{"id":"bar_fly","name":"Bar Fly","hp":8,"attack":3,"dex":15,"base_accuracy":0.66,"base_avoidance":0.14,"absorption":0,"damage_min":1,"damage_max":3,"xp":11,"gold_min":0,"gold_max":2,"tags":["vermin","cellar"]},
	"drunken_slob":{"id":"drunken_slob","name":"Drunken Slob","hp":18,"attack":6,"dex":6,"base_accuracy":0.52,"base_avoidance":0.01,"absorption":1,"damage_min":3,"damage_max":6,"xp":22,"gold_min":3,"gold_max":10,"tags":["humanoid","cellar"]},
	"cellar_mold":{"id":"cellar_mold","name":"Cellar Mold","hp":14,"attack":4,"dex":4,"base_accuracy":0.62,"base_avoidance":0.0,"absorption":2,"damage_min":2,"damage_max":5,"xp":20,"gold_min":0,"gold_max":0,"tags":["fungus","cellar"]},
	"green_slime":{"id":"green_slime","name":"Green Slime","hp":16,"attack":5,"dex":3,"base_accuracy":0.64,"base_avoidance":0.0,"absorption":2,"damage_min":2,"damage_max":5,"xp":24,"gold_min":0,"gold_max":2,"tags":["ooze","sewer"]},
	"sewer_jelly":{"id":"sewer_jelly","name":"Sewer Jelly","hp":20,"attack":5,"dex":5,"base_accuracy":0.62,"base_avoidance":0.01,"absorption":3,"damage_min":2,"damage_max":6,"xp":28,"gold_min":0,"gold_max":3,"tags":["ooze","sewer"]},
	"sewer_crawler":{"id":"sewer_crawler","name":"Sewer Crawler","hp":22,"attack":6,"dex":12,"base_accuracy":0.68,"base_avoidance":0.08,"absorption":1,"damage_min":3,"damage_max":6,"xp":32,"gold_min":1,"gold_max":5,"tags":["beast","sewer"]},
	"sewer_troll":{"id":"sewer_troll","name":"Sewer Troll","hp":95,"attack":10,"dex":7,"base_accuracy":0.68,"base_avoidance":0.03,"absorption":4,"damage_min":5,"damage_max":10,"xp":180,"gold_min":45,"gold_max":80,"tags":["giant","boss","sewer"]},
	"bandit":{"id":"bandit","name":"Bandit","hp":20,"attack":6,"dex":11,"base_accuracy":0.64,"base_avoidance":0.06,"absorption":1,"damage_min":3,"damage_max":6,"xp":26,"gold_min":4,"gold_max":10,"tags":["humanoid","bandit"]},
	"bandit_lookout":{"id":"bandit_lookout","name":"Bandit Lookout","hp":16,"attack":5,"dex":15,"base_accuracy":0.66,"base_avoidance":0.12,"absorption":0,"damage_min":2,"damage_max":5,"xp":28,"gold_min":3,"gold_max":9,"tags":["humanoid","bandit"]},
	"bandit_archer":{"id":"bandit_archer","name":"Bandit Archer","hp":18,"attack":6,"dex":14,"base_accuracy":0.74,"base_avoidance":0.08,"absorption":0,"damage_min":3,"damage_max":7,"xp":32,"gold_min":4,"gold_max":11,"tags":["humanoid","bandit"]},
	"bandit_bruiser":{"id":"bandit_bruiser","name":"Bandit Bruiser","hp":32,"attack":8,"dex":7,"base_accuracy":0.64,"base_avoidance":0.02,"absorption":3,"damage_min":4,"damage_max":9,"xp":40,"gold_min":6,"gold_max":14,"tags":["humanoid","bandit"]},
	"bandit_cutthroat":{"id":"bandit_cutthroat","name":"Bandit Cutthroat","hp":22,"attack":7,"dex":16,"base_accuracy":0.72,"base_avoidance":0.14,"absorption":1,"damage_min":4,"damage_max":8,"xp":42,"gold_min":6,"gold_max":15,"tags":["humanoid","bandit"]},
	"bandit_veteran":{"id":"bandit_veteran","name":"Bandit Veteran","hp":36,"attack":9,"dex":12,"base_accuracy":0.72,"base_avoidance":0.08,"absorption":3,"damage_min":5,"damage_max":9,"xp":52,"gold_min":8,"gold_max":18,"tags":["humanoid","bandit"]},
	"onika_bandit_queen":{"id":"onika_bandit_queen","name":"Onika the Bandit Queen","hp":110,"attack":11,"dex":16,"base_accuracy":0.78,"base_avoidance":0.14,"absorption":4,"damage_min":6,"damage_max":12,"xp":240,"gold_min":60,"gold_max":100,"tags":["humanoid","bandit","boss"]}
}
