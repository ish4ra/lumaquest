# LumaQuest Controls

The 3D redesign deliberately uses the four arrow keys as the primary movement cluster.

| Action | Default |
| --- | --- |
| Forward | Up Arrow |
| Backward | Down Arrow |
| Left | Left Arrow |
| Right | Right Arrow |
| Jump | Space |
| Sprint | Left Shift |
| Crouch / future contextual stance | C |
| Sword / attack combo | J |
| Dodge / roll | K |
| Guard | L |
| Lock-on | Q |
| Interact / talk / open | E |
| Luma reveal pulse | F |
| Use selected item | R |
| Inventory | Tab |
| World / region map | M |
| Pause | Escape |
| Camera orbit | Mouse |
| Camera zoom | Mouse wheel |

## Combat behavior

`J` starts a sword slash. Pressing `J` again during the combo window queues the next slash, up to a three-hit combo. The third strike deals extra damage.

`K` performs a short directional dodge and grants a brief invulnerability window.

Holding `L` guards. Guarding slows movement and currently blocks normal incoming damage while applying reduced knockback.

`Q` toggles lock-on to the nearest valid enemy in range. Lock-on turns the hero toward the target and gently recenters the camera.

## Platforming behavior

Jumping includes coyote time and input buffering. Releasing Space early cuts upward velocity for shorter jumps. Ground movement accelerates/decelerates instead of snapping instantly, while air control is intentionally weaker.

## Controller foundation

The runtime InputMap also adds baseline generic/XInput mappings for movement and core actions. A complete user-facing remapping screen is planned; keyboard defaults are currently authoritative.
