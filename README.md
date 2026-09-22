# LumaQuest

**A small light. A big journey.**

LumaQuest is an original third-person 3D action-adventure platformer built in Godot 4. It combines responsive platforming, readable sword combat, environmental exploration, light-based secrets, and a magical companion called **Luma**.

The current milestone is a playable **Green Fields 3D vertical slice**. It replaces the original 2D prototype with a stylized 3D foundation.

## Current 3D milestone

- Camera-relative four-arrow-key movement
- Sprinting, coyote time, jump buffering, variable jump height, air control and dodge roll
- Mouse orbit camera with `SpringArm3D` collision and wheel zoom
- One-button three-step sword combo with real overlap hit detection
- Guarding and Q lock-on
- Luma follow behavior and an F-key reveal pulse
- Hidden Luma platforms
- Slime, bat, goblin, skeleton and mini-boss enemy variants
- Three-heart health, knockback, invulnerability and checkpoints
- Coins, Luma Shards, keys and hearts
- NPC/sign interaction and a key-locked ancient gate
- HUD, dialogue, region-map overlay, inventory overlay and pause screen
- Versioned save data foundation
- A procedurally assembled stylized 3D Green Fields environment with ruins, trees, river gorge, bridge, waterfalls, mountain silhouettes and a distant castle
- Windows CI validation, native startup smoke testing and versioned prerelease packaging

## Controls

| Action | Keyboard |
| --- | --- |
| Move forward | `↑` |
| Move backward | `↓` |
| Move left | `←` |
| Move right | `→` |
| Jump | `Space` |
| Sprint | `Left Shift` |
| Sword / combo | `J` |
| Dodge | `K` |
| Guard | `L` |
| Lock-on | `Q` |
| Interact | `E` |
| Luma reveal | `F` |
| Item | `R` |
| Inventory | `Tab` |
| Region map | `M` |
| Pause | `Esc` |
| Camera | Mouse |
| Camera zoom | Mouse wheel |

See [CONTROLS.md](CONTROLS.md) for details.

## Green Fields

The first vertical slice is designed around a compact semi-open route rather than an empty open world. It includes:

- a giant-tree starting grove
- mossy ruins and lanterns
- a river gorge and old bridge
- a goblin meadow
- elevated ruin-platforming
- a hidden Luma crossing
- a ruin key and sealed ancient gate
- a checkpoint
- a final combat arena
- a distant castle that acts as a long-term landmark

## Art direction

The project uses original primitive/procedural geometry for this milestone so the gameplay and world composition can be validated without depending on copyrighted or unlicensed third-party character packs. The target style is colorful, storybook-like, slightly chunky fantasy 3D with painterly color separation and strong silhouettes.

The concept references inform mood and composition only. LumaQuest does not use Nintendo characters, maps, music, models, textures, level layouts or proprietary assets.

## Technology

- **Engine:** Godot 4.7.2 stable
- **Language:** GDScript
- **Renderer:** OpenGL compatibility renderer
- **Current packaged target:** Windows x86_64
- **License:** MIT for original project code

The older R36S/ArkOS target remains a future investigation. The 3D redesign intentionally prioritizes the PC vertical slice first; low-power handheld performance will need separate profiling and possibly a reduced render path.

## Run locally

1. Install Godot 4.7.2 stable.
2. Clone this repository.
3. Open `project.godot`.
4. Run the main scene.

## Build Windows

Install Godot 4.7.2 export templates and use the `Windows Desktop` export preset. GitHub Actions also validates the project, boots it headlessly, exports an embedded-PCK Windows executable, runs it on a native Windows runner, then packages the verified build.

## Project structure

```text
scenes/
  Main.tscn
  Player.tscn
  Luma.tscn
  Enemy.tscn
  Collectible.tscn
  Interactable.tscn
  HUD.tscn

scripts/
  ArtFactory.gd
  GameManager.gd
  World.gd
  Player.gd
  Luma.gd
  Enemy.gd
  Collectible3D.gd
  HiddenPlatform.gd
  Interactable3D.gd
  HUD.gd
```

## Research

Implementation notes, open-source references and licensing decisions are documented in [RESEARCH_NOTES.md](RESEARCH_NOTES.md). The project studies techniques rather than copying proprietary game content.

## Roadmap

The next large milestones are imported original character animation, expanded enemy state machines, real dungeon interiors, Luma upgrade progression, a richer minimap, audio/VFX, rebindable controls UI, additional regions, graphics presets and dedicated handheld profiling.

## Status

**v0.1.0-alpha.1 — Green Fields 3D vertical slice**

This is a development prerelease intended for playtesting the new 3D direction. The CI pipeline validates the Godot 4.7.2 project and native Windows startup before release.
