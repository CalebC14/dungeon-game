# Generated preview only; not registered as playable content.
extends RefCounted

const DATA = {
"architect_markers": {
Vector2i(3, 1): {
"type": "event",
"x": 3.0,
"y": 1.0
},
Vector2i(6, 3): {
"type": "door",
"x": 6.0,
"y": 3.0
},
Vector2i(7, 9): {
"type": "door",
"x": 7.0,
"y": 9.0
},
Vector2i(12, 2): {
"connection_id": "reliquary_link_3",
"connection_kind": "stairs",
"destination_floor": 4.0,
"destination_x": 12.0,
"destination_y": 16.0,
"type": "stairs",
"x": 12.0,
"y": 2.0
},
Vector2i(12, 16): {
"connection_id": "reliquary_link_2",
"connection_kind": "stairs",
"destination_floor": 2.0,
"destination_x": 12.0,
"destination_y": 2.0,
"type": "stairs",
"x": 12.0,
"y": 16.0
},
Vector2i(15, 10): {
"type": "door",
"x": 15.0,
"y": 10.0
},
Vector2i(20, 1): {
"type": "event",
"x": 20.0,
"y": 1.0
},
Vector2i(22, 16): {
"type": "treasure",
"x": 22.0,
"y": 16.0
}
},
"architect_notes": "Sisters Bella and Gigi guard the descent. Starter layout for hand editing; not a recreation of the game map.",
"architect_preview_only": true,
"fixed_encounters": {},
"id": "architect_broken_reliquary_catacombs_upper",
"map": ["#########################", "###...##############..###", "###...######......###.###", "###...................###", "############......#######", "############.############", "##...#######.#######....#", "##.....#####............#", "##.....#####.#######....#", "##......................#", "##.....##.#####.##.#....#", "##..#..##.##.##.##.#.####", "##.###.##.##.##.##.#.####", "##..#..##.##.##.##......#", "##.....##.##....##..##..#", "##.....#...#.##.##...##.#", "##.....#...#.##.####.#..#", "####...#...####...##....#", "#########################"],
"name": "Upper Catacombs",
"start_facing": 0,
"start_position": Vector2i(12, 16),
"transitions": {
Vector2i(12, 2): {
"requires_interact": true,
"target_dungeon": "architect_broken_reliquary_catacombs_lower",
"target_position": Vector2i(12, 16)
},
Vector2i(12, 16): {
"requires_interact": true,
"target_dungeon": "architect_broken_reliquary_archives",
"target_position": Vector2i(12, 2)
}
}
}
