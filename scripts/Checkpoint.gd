extends Area2D

var activated := false

func _ready():
    connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
    if not activated and body.has_method("set_checkpoint"):
        activated = true
        body.set_checkpoint(global_position + Vector2(0, -35))
        modulate = Color(0.65, 1.0, 0.8, 1.0)
