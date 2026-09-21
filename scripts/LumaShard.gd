extends Area2D

export var value := 1
var t := 0.0
var base_y := 0.0

func _ready():
    base_y = position.y
    connect("body_entered", self, "_on_body_entered")

func _process(delta):
    t += delta
    position.y = base_y + sin(t * 3.0) * 3.0
    rotation += delta * 1.5

func _on_body_entered(body):
    if body.has_method("collect_shard"):
        body.collect_shard(value)
        queue_free()
