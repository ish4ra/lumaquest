extends KinematicBody2D

export var max_speed := 165.0
export var acceleration := 1100.0
export var friction := 1400.0
export var jump_force := 315.0
export var gravity := 900.0
export var fall_gravity := 1250.0
export var coyote_time := 0.10
export var jump_buffer_time := 0.12
export var max_health := 3

var velocity := Vector2.ZERO
var coyote_left := 0.0
var jump_buffer_left := 0.0
var health := 3
var facing := 1
var attacking := false

func _ready():
    health = max_health

func _physics_process(delta):
    var direction := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    if direction != 0:
        facing = int(sign(direction))
        velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
    else:
        velocity.x = move_toward(velocity.x, 0, friction * delta)

    if is_on_floor():
        coyote_left = coyote_time
    else:
        coyote_left = max(0.0, coyote_left - delta)

    if Input.is_action_just_pressed("jump"):
        jump_buffer_left = jump_buffer_time
    else:
        jump_buffer_left = max(0.0, jump_buffer_left - delta)

    if jump_buffer_left > 0.0 and coyote_left > 0.0:
        velocity.y = -jump_force
        jump_buffer_left = 0.0
        coyote_left = 0.0

    if Input.is_action_just_released("jump") and velocity.y < -90.0:
        velocity.y *= 0.48

    velocity.y += (gravity if velocity.y < 0 else fall_gravity) * delta
    velocity.y = min(velocity.y, 520.0)
    velocity = move_and_slide(velocity, Vector2.UP)

    if Input.is_action_just_pressed("attack") and not attacking:
        _attack()

func _attack():
    attacking = true
    $SwordPivot.scale.x = facing
    $SwordPivot/Hitbox.monitoring = true
    $SwordPivot/Blade.visible = true
    yield(get_tree().create_timer(0.16), "timeout")
    $SwordPivot/Hitbox.monitoring = false
    $SwordPivot/Blade.visible = false
    attacking = false

func hurt(amount := 1):
    health = max(0, health - amount)
    if health <= 0:
        global_position = Vector2(100, 340)
        health = max_health
        velocity = Vector2.ZERO
