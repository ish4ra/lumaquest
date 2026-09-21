extends Area2D

export var value := 1
var t := 0.0
var base_y := 0.0

func _ready():
    base_y = position.y

func _process(delta):
    t += delta
    position.y = base_y + sin(t * 3.0) * 3.0
    rotation += delta * 1.8

func _on_Collectible_body_entered(body):
    if body.name == "Player":
        queue_free()
