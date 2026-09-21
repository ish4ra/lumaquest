extends Node2D

export(NodePath) var target_path
export var follow_speed := 5.0
export var hover_height := 24.0
var target = null
var t := 0.0

func _ready():
    if target_path:
        target = get_node(target_path)

func _process(delta):
    t += delta
    if target:
        var desired = target.global_position + Vector2(22, -hover_height + sin(t * 4.0) * 4.0)
        global_position = global_position.linear_interpolate(desired, min(1.0, follow_speed * delta))

    if Input.is_action_pressed("fairy_action"):
        scale = Vector2.ONE * 1.25
    else:
        scale = Vector2.ONE
