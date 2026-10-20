# Generated preview only; not registered as playable content.
extends RefCounted

const DATA = {
"architect_markers": {
Vector2i(5, 6): {
"type": "door",
"x": 5.0,
"y": 6.0
},
Vector2i(5, 13): {
"type": "door",
"x": 5.0,
"y": 13.0
},
Vector2i(8, 3): {
"type": "door",
"x": 8.0,
"y": 3.0
},
Vector2i(10, 11): {
"type": "door",
"x": 10.0,
"y": 11.0
},
Vector2i(10, 14): {
"type": "door",
"x": 10.0,
"y": 14.0
},
Vector2i(11, 2): {
"type": "treasure",
"x": 11.0,
"y": 2.0
},
Vector2i(12, 2): {
"description": "Exit that appears only after the boss is defeated. Takes the party outside of the dungeon.",
"title": "Exit Dungeon",
"type": "secret",
"x": 12.0,
"y": 2.0
},
Vector2i(12, 4): {
"type": "door",
"x": 12.0,
"y": 4.0
},
Vector2i(12, 5): {
"encounter_id": "bristle_aptarj",
"title": "Bristle-Aptarj",
"type": "boss",
"x": 12.0,
"y": 5.0
},
Vector2i(12, 8): {
"type": "door",
"x": 12.0,
"y": 8.0
},
Vector2i(12, 16): {
"connection_id": "link",
"connection_kind": "stairs",
"destination_floor": 4.0,
"destination_x": 22.0,
"destination_y": 2.0,
"type": "stairs",
"x": 12.0,
"y": 16.0
},
Vector2i(13, 2): {
"type": "treasure",
"x": 13.0,
"y": 2.0
},
Vector2i(14, 11): {
"type": "door",
"x": 14.0,
"y": 11.0
},
Vector2i(14, 14): {
"type": "door",
"x": 14.0,
"y": 14.0
},
Vector2i(16, 3): {
"type": "door",
"x": 16.0,
"y": 3.0
},
Vector2i(19, 6): {
"type": "door",
"x": 19.0,
"y": 6.0
},
Vector2i(19, 13): {
"type": "door",
"x": 19.0,
"y": 13.0
}
},
"architect_notes": "Bristle-Aptarj waits in the Chapel of the Black Warlock. Starter layout for hand editing; not a recreation of the game map.",
"architect_preview_only": true,
"fixed_encounters": {},
"id": "architect_broken_reliquary_black_warlock_chapel",
"map": ["#########################", "#########################", "##......#.#...#.#......##", "##........#...#........##", "##......#..#.#..#......##", "##......#.......#......##", "#####.####.....####.#####", "##........#...#........##", "##........##.##........##", "##........#...#........##", "##........#...#........##", "##.....................##", "##........#...#........##", "#####.#####...#####.#####", "##.....................##", "##........#...#........##", "##........#...#........##", "#########################", "#########################"],
"name": "Chapel of the Black Warlock",
"start_facing": 0,
"start_position": Vector2i(12, 16),
"transitions": {
Vector2i(12, 16): {
"requires_interact": true,
"target_dungeon": "architect_broken_reliquary_catacombs_lower",
"target_position": Vector2i(22, 2)
}
}
}
