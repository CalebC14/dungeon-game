# Generated preview only; not registered as playable content.
extends RefCounted

const DATA = {
"architect_markers": {
Vector2i(2, 2): {
"type": "event",
"x": 2.0,
"y": 2.0
},
Vector2i(3, 3): {
"type": "door",
"x": 3.0,
"y": 3.0
},
Vector2i(7, 3): {
"type": "door",
"x": 7.0,
"y": 3.0
},
Vector2i(12, 16): {
"connection_id": "reliquary_link_3",
"connection_kind": "stairs",
"destination_floor": 3.0,
"destination_x": 12.0,
"destination_y": 2.0,
"type": "stairs",
"x": 12.0,
"y": 16.0
},
Vector2i(16, 13): {
"type": "door",
"x": 16.0,
"y": 13.0
},
Vector2i(18, 14): {
"type": "door",
"x": 18.0,
"y": 14.0
},
Vector2i(18, 16): {
"type": "treasure",
"x": 18.0,
"y": 16.0
},
Vector2i(20, 13): {
"type": "door",
"x": 20.0,
"y": 13.0
},
Vector2i(21, 6): {
"type": "door",
"x": 21.0,
"y": 6.0
},
Vector2i(21, 11): {
"type": "event",
"x": 21.0,
"y": 11.0
},
Vector2i(22, 2): {
"connection_id": "link",
"connection_kind": "stairs",
"destination_floor": 5.0,
"destination_x": 12.0,
"destination_y": 16.0,
"type": "stairs",
"x": 22.0,
"y": 2.0
}
},
"architect_notes": "The emptied ossuary bears the Black Warlock’s sign. Starter layout for hand editing; not a recreation of the game map.",
"architect_preview_only": true,
"fixed_encounters": {},
"id": "architect_broken_reliquary_catacombs_lower",
"map": ["#########################", "#########################", "##.###....#............##", "##...##.#####..#######.##", "##.#........##.#..#..#.##", "##.#.#####........#..#.##", "####.############.#....##", "##.........#......#..#.##", "##.#######.#.#########.##", "##...#.....#...........##", "##...#.###.########.#####", "##...#.#...#........#..##", "##.###.########.#####..##", "##.#..........#........##", "####.######...#.##.##..##", "##........#...#.#...#..##", "##........#...#.#...#..##", "#########################", "#########################"],
"name": "Lower Catacombs",
"start_facing": 0,
"start_position": Vector2i(12, 16),
"transitions": {
Vector2i(12, 16): {
"requires_interact": true,
"target_dungeon": "architect_broken_reliquary_catacombs_upper",
"target_position": Vector2i(12, 2)
},
Vector2i(22, 2): {
"requires_interact": true,
"target_dungeon": "architect_broken_reliquary_black_warlock_chapel",
"target_position": Vector2i(12, 16)
}
}
}
