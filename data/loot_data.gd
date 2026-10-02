class_name LootData
extends RefCounted

# Each defeated enemy gets one loot roll. "chance" is the chance that
# the enemy drops an item at all. The table is weighted after a drop occurs.
const LOOT_TABLES = {
	"giant_rat": {
		"chance": 0.12,
		"items": [
			{"item_id":"healing_potion", "weight":3}
		]
	},
	"rat_broodmother": {
		"chance": 1.0,
		"items": [
			{"item_id":"healing_potion", "weight":3},
			{"item_id":"lucky_charm", "weight":1}
		]
	},
	"kobold": {
		"chance": 0.25,
		"items": [
			{"item_id":"healing_potion", "weight":4},
			{"item_id":"leather_cap", "weight":3},
			{"item_id":"old_key", "weight":1}
		]
	},
	"goblin": {
		"chance": 0.28,
		"items": [
			{"item_id":"healing_potion", "weight":4},
			{"item_id":"leather_armor", "weight":2},
			{"item_id":"iron_sword", "weight":2}
		]
	},
	"skeleton": {
		"chance": 0.25,
		"items": [
			{"item_id":"iron_sword", "weight":3},
			{"item_id":"wooden_shield", "weight":2},
			{"item_id":"old_key", "weight":1}
		]
	},
	"wolf": {
		"chance": 0.10,
		"items": [
			{"item_id":"healing_potion", "weight":1}
		]
	},
	"zombie": {
		"chance": 0.18,
		"items": [
			{"item_id":"old_key", "weight":2},
			{"item_id":"healing_potion", "weight":1}
		]
	},
	"orc": {
		"chance": 0.35,
		"items": [
			{"item_id":"battle_axe", "weight":2},
			{"item_id":"chain_shirt", "weight":1},
			{"item_id":"healing_potion", "weight":3}
		]
	},
	"giant_spider": {
		"chance": 0.22,
		"items": [
			{"item_id":"antidote", "weight":5},
			{"item_id":"healing_potion", "weight":1}
		]
	},
	"ghoul": {
		"chance": 0.32,
		"items": [
			{"item_id":"silver_ring", "weight":1},
			{"item_id":"healing_potion", "weight":3},
			{"item_id":"old_key", "weight":2}
		]
	},
	"ogre": {
		"chance": 0.55,
		"items": [
			{"item_id":"battle_axe", "weight":3},
			{"item_id":"chain_shirt", "weight":2},
			{"item_id":"lucky_charm", "weight":1}
		]
	}
}
