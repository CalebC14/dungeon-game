# Generated preview only; not registered as playable content.
extends RefCounted

const DATA = {
"architect_markers": {
Vector2i(3, 9): {
"description": "Optional treasure behind broken pews.",
"title": "Votive Cache",
"type": "treasure",
"x": 3.0,
"y": 9.0
},
Vector2i(11, 10): {
"description": "A pressure plate threatens explorers.",
"title": "Loose Flagstones",
"type": "trap",
"x": 11.0,
"y": 10.0
},
Vector2i(12, 2): {
"connection_id": "reliquary_link_1",
"connection_kind": "trapdoor",
"description": "Leads to Broken Reliquary Floor 2: Archives.",
"destination_floor": 2.0,
"destination_x": 12.0,
"destination_y": 16.0,
"title": "Trapdoor to Archives",
"type": "stairs",
"x": 12.0,
"y": 2.0
},
Vector2i(12, 4): {
"description": "Mini-boss guards the descent; defeat unlocks the trapdoor.",
"encounter_id": "reliquary_nave_guardian",
"title": "Profaned Nave Guardian",
"type": "boss",
"x": 12.0,
"y": 4.0
},
Vector2i(12, 16): {
"description": "Broken doors open onto the ruined nave.",
"title": "Church entrance",
"type": "entrance",
"x": 12.0,
"y": 16.0
},
Vector2i(20, 3): {
"description": "Concealed niche with church lore.",
"title": "Hidden Sacristy",
"type": "secret",
"x": 20.0,
"y": 3.0
},
Vector2i(20, 9): {
"description": "A corrupted altar of Tay’lore.",
"title": "Desecrated Shrine",
"type": "event",
"x": 20.0,
"y": 9.0
}
},
"architect_notes": "Desecrated church of Tay’lore; guardian protects the trapdoor to the Archives.",
"architect_preview_only": true,
"fixed_encounters": {},
"id": "architect_broken_reliquary_church_nave",
"map": ["#########################", "#########################", "###....##.......###....##", "###....##.......###....##", "###....##.......###....##", "#####.###.......####.####", "#####.###.......####.####", "#####.#...........##.####", "##....#...........#....##", "##.....................##", "##....#...........#....##", "##....#...........#....##", "#######...........#######", "##########.....##########", "##########.....##########", "##########.....##########", "##########.....##########", "#########################", "#########################"],
"name": "Church Nave",
"start_facing": 0,
"start_position": Vector2i(12, 16),
"transitions": {
Vector2i(12, 2): {
"requires_interact": true,
"target_dungeon": "architect_broken_reliquary_archives",
"target_position": Vector2i(12, 16)
}
}
}
