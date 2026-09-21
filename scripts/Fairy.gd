extends Node2D

export(NodePath) var target_path
export var follow_speed := 6.0
export var hover_height := 26.0
export var reveal_radius := 115.0
var target = null
var t := 0.0
var revealing := false

func _ready():
    if target_path:
        target = get_node(target_path)

func _process(delta):
    t += delta
    if target:
        var side = -22 if target.facing < 0 else 22
        var desired = target.global_position + Vector2(side, -hover_height + sin(t * 4.2) * 4.0)
        global_position = global_position.linear_interpolate(desired, min(1.0, follow_speed * delta))

    revealing = Input.is_action_pressed("fairy_action")
    scale = Vector2.ONE * (1.35 if revealing else 1.0)
    $Aura.visible = revealing
    if revealing:
        get_tree().call_group("fairy_reveal", "fairy_reveal", global_position, reveal_radius)
