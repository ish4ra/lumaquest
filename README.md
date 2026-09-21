# LumaQuest

A pixel-art action platformer where classic platforming meets magical exploration, built around a unique fairy companion system.

## Current prototype

The first playable foundation is now in place:

- 2D player movement
- Jumping and gravity
- Controller / D-pad input
- Fairy companion follow behavior
- Fairy action input
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

**Prototype 0.1 — Foundation**

Next milestone: improve movement feel, replace placeholder shapes with original pixel art, add camera/level structure, and introduce the first fairy interaction mechanic.

## License

MIT
