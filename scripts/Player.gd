extends KinematicBody2D

signal health_changed(value, maximum)
signal shards_changed(value)
signal attack_started

export var max_speed = 165.0
export var acceleration = 1100.0
export var friction = 1400.0
export var jump_force = 315.0
export var gravity = 900.0
export var fall_gravity = 1250.0
export var coyote_time = 0.10
export var jump_buffer_time = 0.12
export var max_health = 5

var velocity = Vector2.ZERO
var coyote_left = 0.0
var jump_buffer_left = 0.0
var health = 5
var shards = 0
var facing = 1
var attacking = false
var invulnerable = false
var crouching = false
var spawn_position = Vector2.ZERO

onready var visual_root = $VisualRoot
onready var standing_shape = $StandingShape
onready var crouch_shape = $CrouchShape
onready var sword = $VisualRoot/Sword
onready var attack_area = $AttackArea

func _ready():
    health = max_health
    spawn_position = global_position
    attack_area.connect("body_entered", self, "_on_attack_body_entered")
    attack_area.monitoring = false
    emit_signal("health_changed", health, max_health)
    emit_signal("shards_changed", shards)

func _physics_process(delta):
    crouching = Input.is_action_pressed("crouch") and is_on_floor() and not attacking
    standing_shape.disabled = crouching
    crouch_shape.disabled = not crouching

    var direction = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    if crouching or attacking:
        direction = 0.0
    if direction != 0:
        facing = int(sign(direction))
        velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
    else:
        velocity.x = move_toward(velocity.x, 0.0, friction * delta)

    visual_root.scale.x = facing
    coyote_left = coyote_time if is_on_floor() else max(0.0, coyote_left - delta)
    jump_buffer_left = jump_buffer_time if Input.is_action_just_pressed("jump") else max(0.0, jump_buffer_left - delta)

    if jump_buffer_left > 0.0 and coyote_left > 0.0 and not crouching:
        velocity.y = -jump_force
        jump_buffer_left = 0.0
        coyote_left = 0.0
    if Input.is_action_just_released("jump") and velocity.y < -90.0:
        velocity.y *= 0.48

    velocity.y += (gravity if velocity.y < 0.0 else fall_gravity) * delta
    velocity.y = min(velocity.y, 520.0)
    velocity = move_and_slide(velocity, Vector2.UP)

    if Input.is_action_just_pressed("attack") and not attacking:
        _attack()
    if global_position.y > 620.0:
        _respawn()
    _update_pose()

func _update_pose():
    if attacking:
        visual_root.rotation_degrees = -7.0
        return
    visual_root.rotation_degrees = 0.0
    if crouching:
        visual_root.position.y = 8.0
    else:
        visual_root.position.y = 0.0

func _attack():
    attacking = true
    emit_signal("attack_started")
    sword.visible = true
    sword.rotation_degrees = -55.0
    attack_area.position.x = 18.0 * facing
    attack_area.monitoring = true
    yield(get_tree().create_timer(0.06), "timeout")
    sword.rotation_degrees = 38.0
    yield(get_tree().create_timer(0.12), "timeout")
    attack_area.monitoring = false
    sword.rotation_degrees = -15.0
    yield(get_tree().create_timer(0.08), "timeout")
    attacking = false

func _on_attack_body_entered(body):
    if attacking and body.has_method("take_hit"):
        body.take_hit(facing)

func hurt(amount = 1, knockback = Vector2.ZERO):
    if invulnerable:
        return
    health = max(0, health - amount)
    emit_signal("health_changed", health, max_health)
    velocity = knockback
    if health <= 0:
        _respawn()
        return
    invulnerable = true
    visual_root.modulate = Color(1.0, 0.55, 0.55, 1.0)
    yield(get_tree().create_timer(0.65), "timeout")
    visual_root.modulate = Color.white
    invulnerable = false

func collect_shard(value = 1):
    shards += value
    emit_signal("shards_changed", shards)

func set_checkpoint(point):
    spawn_position = point

func _respawn():
    global_position = spawn_position
    velocity = Vector2.ZERO
    health = max_health
    emit_signal("health_changed", health, max_health)
