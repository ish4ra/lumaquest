extends KinematicBody2D
export var speed = 42.0
export var patrol_distance = 85.0
export var health = 2
var start_x = 0.0
var direction = -1
var velocity = Vector2.ZERO
var stunned = false

func _ready():
    start_x = global_position.x

func _physics_process(delta):
    if not stunned:
        velocity.x = direction * speed
    velocity.y += 900.0 * delta
    velocity = move_and_slide(velocity, Vector2.UP)
    $VisualRoot.scale.x = direction
    if abs(global_position.x - start_x) > patrol_distance:
        direction *= -1
    for i in range(get_slide_count()):
        var hit = get_slide_collision(i)
        if hit.collider and hit.collider.has_method("hurt"):
            hit.collider.hurt(1, Vector2(direction * 150.0, -170.0))

func take_hit(from_direction = 1):
    health -= 1
    stunned = true
    velocity = Vector2(from_direction * 180.0, -110.0)
    $VisualRoot.modulate = Color(1.0, 0.55, 0.55, 1.0)
    if health <= 0:
        queue_free()
        return
    yield(get_tree().create_timer(0.14), "timeout")
    $VisualRoot.modulate = Color.white
    stunned = false
