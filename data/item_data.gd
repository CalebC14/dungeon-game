class_name ItemData
extends RefCounted

const ITEMS = {
	"iron_sword": {"id":"iron_sword","name":"Iron Sword","type":"equipment","slot":"weapon","value":35,"damage_min":2,"damage_max":6,"accuracy":0.05,"avoidance":0.0,"absorption":0,"allowed_classes":["Warrior","Paladin","Berserker","Rogue","Hunter","Bard"]},
	"battle_axe": {"id":"battle_axe","name":"Battle Axe","type":"equipment","slot":"weapon","value":50,"damage_min":3,"damage_max":7,"accuracy":-0.02,"avoidance":0.0,"absorption":0,"allowed_classes":["Warrior","Paladin","Berserker"]},
	"quarterstaff": {"id":"quarterstaff","name":"Quarterstaff","type":"equipment","slot":"weapon","value":20,"damage_min":1,"damage_max":5,"accuracy":0.04,"avoidance":0.02,"absorption":0,"allowed_classes":["Monk","Priest","Shaman","Conjurer","Magician","Druid","Warlock"]},
	"short_bow": {"id":"short_bow","name":"Short Bow","type":"equipment","slot":"weapon","value":40,"damage_min":2,"damage_max":5,"accuracy":0.10,"avoidance":0.0,"absorption":0,"allowed_classes":["Hunter","Rogue","Bard"]},
	"wooden_shield": {"id":"wooden_shield","name":"Wooden Shield","type":"equipment","slot":"off_hand","value":25,"accuracy":0.0,"avoidance":0.03,"absorption":2,"allowed_classes":["Warrior","Paladin","Priest","Shaman","Druid"]},
	"leather_cap": {"id":"leather_cap","name":"Leather Cap","type":"equipment","slot":"head","value":15,"accuracy":0.0,"avoidance":0.01,"absorption":1,"allowed_classes":[]},
	"leather_armor": {"id":"leather_armor","name":"Leather Armor","type":"equipment","slot":"body","value":30,"accuracy":0.0,"avoidance":0.05,"absorption":2,"allowed_classes":[]},
	"chain_shirt": {"id":"chain_shirt","name":"Chain Shirt","type":"equipment","slot":"body","value":70,"accuracy":0.0,"avoidance":-0.02,"absorption":4,"allowed_classes":["Warrior","Paladin","Berserker","Priest"]},
	"leather_gloves": {"id":"leather_gloves","name":"Leather Gloves","type":"equipment","slot":"hands","value":12,"accuracy":0.01,"avoidance":0.0,"absorption":1,"allowed_classes":[]},
	"leather_boots": {"id":"leather_boots","name":"Leather Boots","type":"equipment","slot":"feet","value":18,"accuracy":0.0,"avoidance":0.02,"absorption":1,"allowed_classes":[]},
	"silver_ring": {"id":"silver_ring","name":"Silver Ring","type":"equipment","slot":"accessory","value":60,"accuracy":0.01,"avoidance":0.01,"absorption":0,"allowed_classes":[]},
	"lucky_charm": {"id":"lucky_charm","name":"Lucky Charm","type":"equipment","slot":"trinket","value":75,"accuracy":0.02,"avoidance":0.02,"absorption":0,"allowed_classes":[]},
	"healing_potion": {"id":"healing_potion","name":"Healing Potion","type":"consumable","value":20,"effect":"heal","power":12},
	"antidote": {"id":"antidote","name":"Antidote","type":"consumable","value":15,"effect":"cure_poison","power":0},
	"old_key": {"id":"old_key","name":"Old Iron Key","type":"misc","value":0},
	"sun_touched_sword": {"id":"sun_touched_sword","name":"Sun-Touched Sword","type":"equipment","slot":"weapon","value":120,"damage_min":3,"damage_max":7,"accuracy":0.07,"avoidance":0.0,"absorption":0,"allowed_classes":["Warrior","Paladin","Berserker","Rogue","Hunter","Bard"]},
	"blessed_chain": {"id":"blessed_chain","name":"Blessed Chain Shirt","type":"equipment","slot":"body","value":150,"accuracy":0.0,"avoidance":-0.01,"absorption":5,"allowed_classes":["Warrior","Paladin","Berserker","Priest"]},
	"dawn_ward": {"id":"dawn_ward","name":"Dawn Ward","type":"equipment","slot":"off_hand","value":135,"accuracy":0.0,"avoidance":0.05,"absorption":3,"allowed_classes":["Warrior","Paladin","Priest","Shaman","Druid"]},
	"sun_priest_ring": {"id":"sun_priest_ring","name":"Sun Priest's Ring","type":"equipment","slot":"accessory","value":180,"accuracy":0.02,"avoidance":0.03,"absorption":0,"allowed_classes":[]},
	"holy_symbol_taylore": {"id":"holy_symbol_taylore","name":"Holy Symbol of Tay'lore","type":"equipment","slot":"trinket","value":0,"accuracy":0.02,"avoidance":0.05,"absorption":1,"allowed_classes":[]}
}
