extends StaticBody2D

export var fade_speed := 7.0
var target_alpha := 0.0

func _ready():
    add_to_group("fairy_reveal")
    modulate.a = 0.06

func fairy_reveal(fairy_position: Vector2, radius: float):
    target_alpha = 1.0 if global_position.distance_to(fairy_position) <= radius else 0.06

func _process(delta):
    target_alpha = 0.06 if not Input.is_action_pressed("fairy_action") else target_alpha
    modulate.a = lerp(modulate.a, target_alpha, min(1.0, fade_speed * delta))
