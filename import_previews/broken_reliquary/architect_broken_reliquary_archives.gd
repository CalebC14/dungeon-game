# Generated preview only; not registered as playable content.
extends RefCounted

const DATA = {
"architect_markers": {
Vector2i(2, 2): {
"type": "treasure",
"x": 2.0,
"y": 2.0
},
Vector2i(2, 16): {
"type": "event",
"x": 2.0,
"y": 16.0
},
Vector2i(4, 7): {
"type": "door",
"x": 4.0,
"y": 7.0
},
Vector2i(4, 11): {
"type": "door",
"x": 4.0,
"y": 11.0
},
Vector2i(11, 5): {
"type": "door",
"x": 11.0,
"y": 5.0
},
Vector2i(12, 2): {
"connection_id": "reliquary_link_2",
"connection_kind": "stairs",
"destination_floor": 3.0,
"destination_x": 12.0,
"destination_y": 16.0,
"type": "stairs",
"x": 12.0,
"y": 2.0
},
Vector2i(12, 16): {
"connection_id": "reliquary_link_1",
"connection_kind": "trapdoor",
"destination_floor": 1.0,
"destination_x": 12.0,
"destination_y": 2.0,
"type": "stairs",
"x": 12.0,
"y": 16.0
},
Vector2i(13, 13): {
"type": "door",
"x": 13.0,
"y": 13.0
},
Vector2i(13, 14): {
"type": "boss",
"x": 13.0,
"y": 14.0
},
Vector2i(20, 7): {
"type": "door",
"x": 20.0,
"y": 7.0
},
Vector2i(20, 11): {
"type": "door",
"x": 20.0,
"y": 11.0
},
Vector2i(22, 16): {
"type": "treasure",
"x": 22.0,
"y": 16.0
}
},
"architect_notes": "Forgotten records reveal Bristle-Aptarj’s failed ritual. Starter layout for hand editing; not a recreation of the game map.",
"architect_preview_only": true,
"fixed_encounters": {},
"id": "architect_broken_reliquary_archives",
"map": ["#########################", "#########################", "##....#...#..#....#....##", "##....#...#..#....#....##", "##....#...#..#....#....##", "##....#...#.##....#....##", "##....#...........#....##", "####.##...........##.####", "##.....................##", "##.....................##", "##.....................##", "####.##...........##.####", "##....#...........#....##", "##....#....##.#...#....##", "##....#....#..#...#....##", "##....#....#..#...#....##", "##....#....#..#...#....##", "#########################", "#########################"],
"name": "Forgotten Archives",
"start_facing": 0,
"start_position": Vector2i(12, 16),
"transitions": {
Vector2i(12, 2): {
"requires_interact": true,
"target_dungeon": "architect_broken_reliquary_catacombs_upper",
"target_position": Vector2i(12, 16)
},
Vector2i(12, 16): {
"requires_interact": true,
"target_dungeon": "architect_broken_reliquary_church_nave",
"target_position": Vector2i(12, 2)
}
}
}
