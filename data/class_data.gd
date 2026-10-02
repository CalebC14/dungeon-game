class_name ClassData
extends RefCounted


const CLASSES = [
	{
		"name": "Warrior",
		"requirements": {
			"str": 12
		},
		"role": "Front-line martial",
		"ability": "Power Attack"
	},
	{
		"name": "Paladin",
		"requirements": {
			"str": 12,
			"con": 12,
			"lck": 10
		},
		"role": "Defender / support",
		"ability": "Guard Ally"
	},
	{
		"name": "Berserker",
		"requirements": {
			"str": 14,
			"con": 12
		},
		"role": "Heavy melee damage",
		"ability": "Rage"
	},
	{
		"name": "Rogue",
		"requirements": {
			"dex": 12,
			"lck": 10
		},
		"role": "Traps / locks / damage",
		"ability": "Backstab"
	},
	{
		"name": "Hunter",
		"requirements": {
			"dex": 12,
			"str": 10
		},
		"role": "Ranged martial",
		"ability": "Aimed Shot"
	},
	{
		"name": "Monk",
		"requirements": {
			"dex": 12,
			"con": 11
		},
		"role": "Unarmed martial",
		"ability": "Flurry"
	},
	{
		"name": "Bard",
		"requirements": {
			"dex": 10,
			"int": 10,
			"lck": 10
		},
		"role": "Songs / party support",
		"ability": "Song of Courage"
	},
	{
		"name": "Priest",
		"requirements": {
			"int": 10,
			"lck": 12
		},
		"role": "Healing / protection",
		"ability": "Mend"
	},
	{
		"name": "Shaman",
		"requirements": {
			"int": 11,
			"con": 10,
			"lck": 11
		},
		"role": "Spirits / wards / hexes",
		"ability": "Ancestor's Ward"
	},
	{
		"name": "Conjurer",
		"requirements": {
			"int": 12
		},
		"role": "Summons / arcane support",
		"ability": "Conjure Flame"
	},
	{
		"name": "Magician",
		"requirements": {
			"int": 13
		},
		"role": "Offensive magic",
		"ability": "Arcane Bolt"
	},
	{
		"name": "Druid",
		"requirements": {
			"int": 11,
			"con": 11
		},
		"role": "Nature magic",
		"ability": "Regrowth"
	},
	{
		"name": "Warlock",
		"requirements": {
			"int": 13,
			"lck": 12
		},
		"role": "Curses / dark magic",
		"ability": "Life Drain"
	}
]
