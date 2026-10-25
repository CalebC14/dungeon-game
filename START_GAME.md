# Start the game from Terminal

```
cd ~/dungeon-game
./run-game.sh
```

The launcher refreshes Godot's generated script-class and asset caches before
starting the game. This is needed after a fresh checkout or when new scripts
have been added. It does not change saves or gameplay definitions.

It finds `godot` on PATH, then checks `/Applications/Godot.app` and
`~/Downloads/Godot.app`. For another installation:

```
GODOT_BIN="/full/path/to/Godot" ./run-game.sh
```

To open the editor instead:

```
./run-game.sh --editor
```

A one-time manual refresh also works:

```
/Users/caleb/Downloads/Godot.app/Contents/MacOS/Godot --headless --path ~/dungeon-game --editor --import --quit
```

After that, the usual Godot `--path ~/dungeon-game` command can launch directly
until the generated cache becomes stale again. The main scene now uses its
resource path rather than depending on a generated scene-UID lookup.

The reported `CharacterHealth`, `DungeonInteractions`, and `ExplorationSkills`
errors came from a stale Godot global-class cache, not missing class skills.
The class declarations already existed in source. The launcher was verified on
a separate copy without `.godot`, followed by headless game startup with no
script errors. The actual local project cache was also refreshed.

For the imported test chain, prepare an active party and press F12 → N.
At the Guild, F12 → T loads the existing test roster.
