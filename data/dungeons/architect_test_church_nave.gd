# Playable test bindings layered over the generated preview; do not edit the export.
extends RefCounted
const Preview = preload("res://import_previews/broken_reliquary/architect_broken_reliquary_church_nave.gd")
const DATA = {
	"id":"architect_test_church_nave", "name":"Church Nave (Test)", "town":"thornwake", "zone":"ashenwood",
	"map":Preview.DATA["map"], "start_position":Vector2i(12,16), "start_facing":0,
	"tracks_exploration_time":true, "quiet_areas":[Rect2i(0,9,25,10)],
	"fixed_encounters": {Vector2i(12,4): {"id":"nave_test_guardian", "tag":"architect_nave_guardian", "enemy_id":"skeleton", "count":1, "intro":"The Profaned Nave Guardian rises. A single Skeleton stands in for this test boss."}},
	"transitions": {
		Vector2i(12,16): {"to_city":true,"to_city_id":"thornwake","requires_interact":true,"hint":"[Enter] Leave the test Nave for Thornwake."},
		Vector2i(12,2): {"target_dungeon":"architect_test_archives","target_position":Vector2i(12,16),"target_facing":0,"requires_interact":true,"requires_defeated":"nave_test_guardian","hint":"[Enter] Descend to the Archives after defeating the guardian."}
	},
	"interactions": {
		Vector2i(3,9): {"id":"nave_votive_cache","type":"hidden_treasure","name":"a votive coin cache","clue":"A cracked pew conceals a small compartment.","reward_gold":25},
		Vector2i(11,10): {"id":"nave_flagstone_trap","type":"trap","name":"Loose flagstone trap","damage":4},
		Vector2i(20,3): {"id":"nave_hidden_sacristy","type":"secret_door","name":"Sacristy niche","clue":"A sun-shaped seam marks this section of the sacristy.","discovery_message":"A concealed panel opens onto a weathered inscription."}
	},
	"events": {
		Vector2i(12,15): {"id":"nave_test_notice","type":"lore","message":"Import test: search the side rooms, then face the guardian in the north. Enter at the entrance returns to town."},
		Vector2i(20,9): {"id":"nave_shrine_lore","type":"lore","message":"The shrine of Tay'lore has been desecrated. A faded sun survives beneath the soot."},
		Vector2i(20,3): {"id":"nave_sacristy_lore","type":"lore","message":"The hidden inscription reads: Even beneath stone, the sun remembers its faithful."}
	}
}
