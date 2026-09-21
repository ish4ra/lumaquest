# LumaQuest

A pixel-art action platformer where classic platforming meets magical exploration, built around a unique fairy companion system.

## Current playtest

The first playable development slice is now in place:

- 2D player movement
- Jumping and gravity
- Controller / D-pad input
- Fairy companion follow behavior
- Fairy reveal ability and hidden-path foundation
- Sword combat, enemies, health, knockback and checkpoints
- Luma Shard collectible foundation
- 640×480 base resolution for handheld-friendly scaling
- GLES2 rendering path
- Initial Windows + Linux/R36S-oriented project structure

## Controls

| Action | Keyboard | Controller |
| --- | --- | --- |
| Move | A / D or Arrow Keys | D-pad |
| Jump | Space | A |
| Fairy action | F | X |

## Development direction

LumaQuest is planned around:

- Responsive platforming
- Sword-based combat
- Fairy abilities that affect exploration and puzzles
- Hidden rooms and secrets
- Dungeon-like areas and bosses
- Collectibles and upgrades
- Original pixel-art world and characters
- PC and R36S / ArkOS targets

## Technology

The prototype currently targets Godot 3.x with the GLES2 renderer. This keeps the 2D project lightweight and gives us a more practical path toward low-power Linux ARM handhelds such as the R36S.

## Status

**In Development — Playtest builds only**

Implemented next: acceleration/friction, coyote time, jump buffering, variable jump height, camera foundation, sword input/combat foundation, and Luma reveal logic for hidden paths.

GitHub Actions now produces a Windows development playtest artifact. Public semantic version numbers are reserved for the completed first release; the target first proper release is v1.0.0.

Next: original pixel-art assets/animation, expanded level content, sound/music, menus/save data, boss content, polish, and R36S/ArkOS packaging tests.

## License

MIT
