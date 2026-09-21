extends KinematicBody2D

signal health_changed(value, maximum)
signal shards_changed(value)

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
var shards := 0
var facing := 1
var attacking := false
var invulnerable := false
var spawn_position := Vector2.ZERO
var crouching := false

func _ready():
    health = max_health
    spawn_position = global_position
    emit_signal("health_changed", health, max_health)
    emit_signal("shards_changed", shards)

func _physics_process(delta):
    crouching = Input.is_action_pressed("crouch") and is_on_floor()
    $Body.scale.y = 0.62 if crouching else 1.0
    $Body.position.y = 5.0 if crouching else 0.0
    var direction := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    if crouching:
        direction = 0
    if direction != 0:
        facing = int(sign(direction))
        velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
    else:
        velocity.x = move_toward(velocity.x, 0, friction * delta)

    coyote_left = coyote_time if is_on_floor() else max(0.0, coyote_left - delta)
    jump_buffer_left = jump_buffer_time if Input.is_action_just_pressed("jump") else max(0.0, jump_buffer_left - delta)

    if jump_buffer_left > 0.0 and coyote_left > 0.0 and not crouching:
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
    if global_position.y > 540:
        _respawn()

func _attack():
    attacking = true
    $SwordPivot.scale.x = facing
    $SwordPivot/Hitbox.monitoring = true
    $SwordPivot/Blade.visible = true
    for body in $SwordPivot/Hitbox.get_overlapping_bodies():
        if body.has_method("take_hit"):
            body.take_hit(facing)
    yield(get_tree().create_timer(0.16), "timeout")
    $SwordPivot/Hitbox.monitoring = false
    $SwordPivot/Blade.visible = false
    attacking = false

func hurt(amount := 1, knockback := Vector2.ZERO):
    if invulnerable:
        return
    health = max(0, health - amount)
    emit_signal("health_changed", health, max_health)
    velocity = knockback
    if health <= 0:
        _respawn()
        return
    invulnerable = true
    modulate.a = 0.45
    yield(get_tree().create_timer(0.65), "timeout")
    modulate.a = 1.0
    invulnerable = false

func collect_shard(value := 1):
    shards += value
    emit_signal("shards_changed", shards)

func set_checkpoint(point: Vector2):
    spawn_position = point

func _respawn():
    global_position = spawn_position
    velocity = Vector2.ZERO
    health = max_health
    emit_signal("health_changed", health, max_health)
