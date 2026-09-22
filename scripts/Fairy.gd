extends Node2D
export(NodePath) var target_path
export var follow_speed = 7.0
export var hover_height = 30.0
export var reveal_radius = 125.0
var target = null
var t = 0.0
var revealing = false

func _ready():
    if target_path != NodePath(""):
        target = get_node(target_path)

func _process(delta):
    t += delta
    if target:
        var side = -24.0 if target.facing < 0 else 24.0
        var desired = target.global_position + Vector2(side, -hover_height + sin(t * 4.2) * 4.0)
        global_position = global_position.linear_interpolate(desired, min(1.0, follow_speed * delta))
    revealing = Input.is_action_pressed("fairy_action")
    $Visual.scale = Vector2.ONE * (1.18 if revealing else 1.0)
    $Visual/Core.modulate.a = 0.88 + sin(t * 7.0) * 0.12
    $Visual/LeftWing.rotation_degrees = -18.0 + sin(t * 12.0) * 14.0
    $Visual/RightWing.rotation_degrees = 18.0 - sin(t * 12.0) * 14.0
    $Aura.visible = revealing
    if revealing:
        get_tree().call_group("fairy_reveal", "fairy_reveal", global_position, reveal_radius)
