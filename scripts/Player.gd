extends KinematicBody2D

export var speed := 150.0
export var jump_force := 300.0
export var gravity := 900.0
var velocity := Vector2.ZERO

func _physics_process(delta):
    var direction := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    velocity.x = direction * speed
    velocity.y += gravity * delta

    if is_on_floor() and Input.is_action_just_pressed("jump"):
        velocity.y = -jump_force

    velocity = move_and_slide(velocity, Vector2.UP)
