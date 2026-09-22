# Changelog

## v0.1.0-alpha.1 — Green Fields 3D

### Changed
- Rebuilt LumaQuest from the previous 2D Godot 3 prototype into a Godot 4.7.2 third-person 3D vertical slice.
- Replaced side-scrolling movement with camera-relative four-arrow-key movement.
- Replaced the 2D camera with a mouse-orbit SpringArm3D camera.
- Reframed Green Fields as a semi-open 3D exploration route with a distant castle landmark.

### Added
- sprint, coyote time, jump buffering, variable jump height and air control
- dodge, guard, lock-on and three-step sword combo
- Luma reveal pulse and temporary hidden platforms
- slime, bat, goblin, skeleton and mini-boss enemy variants
- coins, Luma Shards, hearts and keys
- NPC/sign dialogue, checkpoint and key-locked ancient gate
- HUD, map overlay, inventory overlay and pause screen
- save/load foundation
- procedural stylized trees, ruins, bridge, gorge, river, waterfalls, lanterns, mountains, clouds and castle
- Godot 4 CI import/parse checks, Linux headless boot test, Windows export and native Windows startup smoke test
- versioned prerelease workflow

### Removed
- runtime dependency on the old Godot 3 2D gameplay scripts/scenes
