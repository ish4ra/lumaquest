extends KinematicBody2D

export var speed := 42.0
export var patrol_distance := 85.0
export var health := 2
var start_x := 0.0
var direction := -1
var velocity := Vector2.ZERO

func _ready():
    start_x = global_position.x

func _physics_process(delta):
    velocity.x = direction * speed
    velocity.y += 900.0 * delta
    velocity = move_and_slide(velocity, Vector2.UP)
    $Visual.scale.x = direction
    if abs(global_position.x - start_x) > patrol_distance:
        direction *= -1
    for i in get_slide_count():
        var hit = get_slide_collision(i)
        if hit.collider and hit.collider.name == "Player":
            hit.collider.hurt(1, Vector2(direction * 150.0, -170.0))

func take_hit(from_direction := 1):
    health -= 1
    velocity.x = from_direction * 170.0
    modulate = Color(1,0.65,0.65,1)
    if health <= 0:
        queue_free()
    else:
        yield(get_tree().create_timer(0.12), "timeout")
        modulate = Color.white
