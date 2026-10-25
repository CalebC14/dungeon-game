#!/bin/bash
set -euo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
godot_bin="${GODOT_BIN:-}"
if [[ -z "$godot_bin" ]]; then
  if command -v godot >/dev/null 2>&1; then
    godot_bin="$(command -v godot)"
  elif [[ -x /Applications/Godot.app/Contents/MacOS/Godot ]]; then
    godot_bin=/Applications/Godot.app/Contents/MacOS/Godot
  elif [[ -x "$HOME/Downloads/Godot.app/Contents/MacOS/Godot" ]]; then
    godot_bin="$HOME/Downloads/Godot.app/Contents/MacOS/Godot"
  else
    echo 'Godot was not found. Set GODOT_BIN to the full path of its executable.' >&2
    exit 1
  fi
fi
if [[ ! -x "$godot_bin" ]]; then
  echo "Godot executable is not available: $godot_bin" >&2
  exit 1
fi

# Rebuild generated class/asset caches before loading the game, including on
# fresh checkouts and after new class_name scripts have been added.
"$godot_bin" --headless --path "$project_dir" --editor --import --quit
exec "$godot_bin" --path "$project_dir" "$@"
