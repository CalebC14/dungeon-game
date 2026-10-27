# Source provenance and authority

The project owner explicitly instructed on 2026-10-26: “Use the ZIP as the source of truth for the locked designs. Update the saved compendium, track the implementation differences separately, and commit the docs to the public dungeon-game repo.”

## Authoritative design package

- Supplied filename: `dungeon_game_class_compendium.zip`.
- SHA-256: `3b8978c7d254eff1e135a201aec242be0aa733a5a8595943d32e11d1514fcdc5`.
- The separately supplied `dungeon_game_class_compendium_README.md` is byte-identical to the original README inside the ZIP.
- ZIP integrity passed. All 11 non-index Markdown documents are saved byte-for-byte under their original filenames. The maintained README preserves the specialization index and design cautions, replaces package-import directions with repository maintenance links, and records this authority decision.
- [Package file hashes](source-manifest.json) allow exact verification. `README.md` in the manifest describes the original package README, not the maintained index.
- Locked labels are accepted under the owner's explicit instruction; they are not inferred from code. Paladin Healer L60 remains provisional. Source TBDs and partial frameworks retain their original status.

## Separate implementation evidence

Code inspection used local game commit `7093dd73527df7a88e55b1f80c1c6746a7bdd1fc` and GitHub main baseline `c3f9e092563b098537f2e366e116944b33a89634`. The local code is newer (including basic spell SP changes). The shared Tank ability function tail beginning at `combatant_key` matches the remote baseline exactly. Main sources: `systems/combat.gd`, `systems/combat_effects.gd`, `game.gd`, `data/class_data.gd`, and existing Tank regression fixtures.

This documentation pass changes no game logic and does not claim runtime tests or design conformance have passed. Existing Tank tests validate implemented slices, not the newly authoritative compendium as a whole. See [implementation differences](implementation-differences.md).

## Supersession and access

The prior recovery-only compendium was backed up locally before import. Its missing-design placeholders and competing hyphenated filenames are removed from the active index/directory. No synced `sources/` files were changed.

The canonical shared path is `CalebC14/dungeon-game/docs/classes/` on GitHub main once this documentation commit is published. Local project workspace copies persist separately; no automatic upload into ChatGPT Project Sources is claimed. Public documentation contains repository paths and commit IDs, not personal absolute filesystem paths.
