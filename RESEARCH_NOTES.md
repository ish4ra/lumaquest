# LumaQuest 3D Research Notes

Research for the 3D redesign was performed before implementation. The goal was to understand proven controller/camera architecture and licensing, not to paste another project's code.

## Engine choice

The redesign targets **Godot 4.7.2 stable** rather than the 4.8 development snapshots. The stable branch gives us `CharacterBody3D`, `SpringArm3D`, modern Godot 4 materials/environment systems and current export tooling without building a release on a preview engine.

## Official Godot references

### Third-person camera with SpringArm3D
Godot's official third-person spring-arm documentation describes a `Node3D -> SpringArm3D -> Camera3D` hierarchy. SpringArm3D sweeps the camera shape and pulls the camera forward near geometry, avoiding the classic third-person wall-clipping problem.

Adopted:
- camera pivot
- direct Camera3D child of SpringArm3D
- mouse orbit
- pitch limits
- spring-arm zoom and collision

### CharacterBody3D and input
The controller uses `CharacterBody3D`, camera-relative input vectors, acceleration/deceleration, explicit air control, coyote time and jump buffering. Physical keyboard positions are used for action bindings where applicable.

### Environment
`WorldEnvironment`, procedural sky, fog and stylized StandardMaterial3D materials provide atmosphere without external art dependencies.

## Open-source repositories inspected

### LucasFASouza/godot-adventure
Repository: https://github.com/LucasFASouza/godot-adventure

The README describes a third-person Godot adventure template with walking, running, jumping, climbing, swimming, flying and foundational melee/ranged combat. It states that software code is MIT licensed and art is CC-BY 4.0.

Used as:
- architectural reference for separating movement, combat and world systems
- evidence that a reusable adventure-controller foundation benefits from independent gameplay systems

Not copied:
- source code
- art/models/animations
- multiplayer systems

### EasterEggProductions/adventure-mode-godot
Repository: https://github.com/EasterEggProductions/adventure-mode-godot

Inspected as the related upstream project. Used only as a conceptual reference.

### Janders1800/3D-Platformer
Repository: https://github.com/Janders1800/3D-Platformer

The README documents keyboard/gamepad movement, mouse/right-stick camera and Space/A jumping. The repository includes an MIT license.

Used as:
- control-convention reference
- confirmation of the mouse-camera + keyboard movement pattern

Not copied:
- source code or assets

### gdquest-demos/godot-3d-mannequin
Repository: https://github.com/gdquest-demos/godot-3d-mannequin

Its README explains a third-person character controller with a state-machine player and a camera rig using a spring arm. The repository states code is MIT and art is CC-BY 4.0. It targets an older Godot generation, so it is treated as architecture/history rather than drop-in Godot 4 code.

Adopted conceptually:
- keeping camera behavior separate from character movement logic
- finite-state thinking for future expansion

Not copied:
- mannequin, art, animation or source files

### Lazy13909/Recreating_Zelda
Repository: https://github.com/Lazy13909/Recreating_Zelda

Inspected as a public 3D Zelda-recreation study. We do not import Nintendo content or implementation code from it.

### Natwm/Godot_project_Action_zelda
Repository: https://github.com/Natwm/Godot_project_Action_zelda

Inspected only as another action-adventure prototype reference. No source or assets are imported.

## Design conclusions

1. **Movement first.** A large world does not matter if basic movement and camera control feel poor.
2. **Spring-arm camera collision is non-negotiable** for a third-person platformer.
3. **Camera-relative movement** makes arrow-key movement intuitive even when the camera rotates freely.
4. **Input forgiveness** (coyote time, jump buffering, variable jump height) is more useful than adding many movement gimmicks.
5. **One primary attack key** keeps combat readable. LumaQuest uses J with a timed combo queue.
6. **Luma must change traversal**, so the first implementation reveals temporary hidden platforms instead of acting as a decorative follower.
7. **Landmarks should guide exploration.** The castle, waterfalls, giant trees and ruin arches are visible composition anchors.
8. **Original procedural placeholder art beats unlicensed asset packs.** The first 3D milestone builds its hero, enemies and world from original primitive geometry so gameplay can evolve safely.

## Future research

- animation retargeting and AnimationTree for the final original hero rig
- navigation mesh/pathfinding for more complex enemy spaces
- user-facing InputMap rebinding UI
- occlusion/LOD/visibility ranges for larger regions
- R36S/ArkOS feasibility with Godot 4's compatibility renderer
