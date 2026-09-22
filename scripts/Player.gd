class_name LumaQuestPlayer
extends CharacterBody3D

signal health_changed(value: int, maximum: int)
signal shards_changed(value: int)
signal coins_changed(value: int)
signal keys_changed(value: int)
signal lock_changed(target: Node3D)
signal dialogue_requested(speaker: String, message: String)

@export var walk_speed := 5.4
@export var sprint_speed := 8.2
@export var acceleration := 22.0
@export var air_acceleration := 9.0
@export var deceleration := 26.0
@export var jump_velocity := 8.4
@export var gravity := 24.0
@export var fall_gravity := 31.0
@export var coyote_time := 0.13
@export var jump_buffer_time := 0.14
@export var mouse_sensitivity := 0.0025
@export var max_health := 3

var health := 3
var shards := 0
var coins := 23
var keys := 0

var _coyote_left := 0.0
var _jump_buffer_left := 0.0
var _dodge_left := 0.0
var _dodge_direction := Vector3.ZERO
var _invulnerable_left := 0.0
var _attack_phase := 0
var _attack_time := 0.0
var _attack_queued := false
var _attack_hits: Array[Node] = []
var _locked_target: Node3D = null
var _spawn_position := Vector3.ZERO
var _run_time := 0.0
var _last_move_direction := Vector3.FORWARD

@onready var visual: Node3D = $Visual
@onready var body_root: Node3D = $Visual/BodyRoot
@onready var left_arm: Node3D = $Visual/BodyRoot/LeftArm
@onready var right_arm: Node3D = $Visual/BodyRoot/RightArm
@onready var left_leg: Node3D = $Visual/BodyRoot/LeftLeg
@onready var right_leg: Node3D = $Visual/BodyRoot/RightLeg
@onready var sword_pivot: Node3D = $Visual/BodyRoot/RightArm/SwordPivot
@onready var camera_pivot: Node3D = $CameraPivot
@onready var spring_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var attack_area: Area3D = $AttackArea

func _ready() -> void:
	_spawn_position = global_position
	health = max_health
	_build_visuals()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	sync_stats()

func _build_visuals() -> void:
	var skin := Color("#f2c39d")
	var hair := Color("#34271f")
	var tunic := Color("#264c3c")
	var tunic_light := Color("#356b51")
	var leather := Color("#69462d")
	var boots := Color("#34291f")
	var metal := Color("#d8e1df")
	var gold := Color("#c89b3c")
	var cape := Color("#7b2f35")

	ArtFactory.box(body_root, Vector3(0.82, 1.0, 0.48), tunic, Vector3(0, 1.26, 0), Vector3.ZERO, null, "Torso")
	ArtFactory.sphere(body_root, 0.39, skin, Vector3(0, 2.04, 0), null, "Head")
	ArtFactory.sphere(body_root, 0.41, hair, Vector3(0, 2.19, 0.02), null, "Hair")
	ArtFactory.box(body_root, Vector3(0.78, 0.12, 0.52), tunic_light, Vector3(0, 0.79, 0), Vector3.ZERO, null, "BeltLine")
	ArtFactory.box(body_root, Vector3(0.94, 0.7, 0.08), cape, Vector3(0, 1.4, 0.31), Vector3(deg_to_rad(-8), 0, 0), null, "Cape")

	ArtFactory.cylinder(left_arm, 0.11, 0.78, tunic_light, Vector3(0, -0.34, 0))
	ArtFactory.sphere(left_arm, 0.13, skin, Vector3(0, -0.75, 0))
	ArtFactory.cylinder(right_arm, 0.11, 0.78, tunic_light, Vector3(0, -0.34, 0))
	ArtFactory.sphere(right_arm, 0.13, skin, Vector3(0, -0.75, 0))
	ArtFactory.cylinder(left_leg, 0.13, 0.82, leather, Vector3(0, -0.38, 0))
	ArtFactory.box(left_leg, Vector3(0.29, 0.23, 0.48), boots, Vector3(0, -0.83, -0.09))
	ArtFactory.cylinder(right_leg, 0.13, 0.82, leather, Vector3(0, -0.38, 0))
	ArtFactory.box(right_leg, Vector3(0.29, 0.23, 0.48), boots, Vector3(0, -0.83, -0.09))

	ArtFactory.box(sword_pivot, Vector3(0.12, 0.12, 0.32), leather, Vector3(0, 0, -0.16), Vector3.ZERO, null, "Grip")
	ArtFactory.box(sword_pivot, Vector3(0.48, 0.09, 0.09), gold, Vector3(0, 0, -0.34), Vector3.ZERO, null, "Guard")
	ArtFactory.box(sword_pivot, Vector3(0.11, 0.07, 1.15), metal, Vector3(0, 0, -0.92), Vector3.ZERO, null, "Blade")
	ArtFactory.cone(sword_pivot, 0.085, 0.25, metal, Vector3(0, 0, -1.59), Vector3(deg_to_rad(90), 0, 0), null, "Tip")

func _physics_process(delta: float) -> void:
	_run_time += delta
	_invulnerable_left = maxf(0.0, _invulnerable_left - delta)
	_update_lock_on(delta)
	_update_jump_timers(delta)
	_update_combat(delta)

	if _dodge_left > 0.0:
		_dodge_left -= delta
		velocity.x = _dodge_direction.x * 11.5
		velocity.z = _dodge_direction.z * 11.5
	else:
		_handle_movement(delta)

	_handle_vertical(delta)
	move_and_slide()

	if global_position.y < -14.0:
		respawn()

	_update_visual_animation(delta)

func _handle_movement(delta: float) -> void:
	var input_right := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var input_forward := Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	var cam_forward := -camera.global_transform.basis.z
	var cam_right := camera.global_transform.basis.x
	cam_forward.y = 0.0
	cam_right.y = 0.0
	cam_forward = cam_forward.normalized()
	cam_right = cam_right.normalized()
	var desired := cam_right * input_right + cam_forward * input_forward
	if desired.length_squared() > 1.0:
		desired = desired.normalized()

	var guarding := Input.is_action_pressed("guard")
	var speed := sprint_speed if Input.is_action_pressed("sprint") and not guarding else walk_speed
	if guarding:
		speed *= 0.45
	if _attack_phase > 0:
		speed *= 0.35

	var target_velocity := desired * speed
	var accel := acceleration if is_on_floor() else air_acceleration
	if desired.length_squared() > 0.001:
		velocity.x = move_toward(velocity.x, target_velocity.x, accel * delta)
		velocity.z = move_toward(velocity.z, target_velocity.z, accel * delta)
		_last_move_direction = desired.normalized()
	else:
		var drag := deceleration if is_on_floor() else air_acceleration * 0.45
		velocity.x = move_toward(velocity.x, 0.0, drag * delta)
		velocity.z = move_toward(velocity.z, 0.0, drag * delta)

	if _locked_target != null and is_instance_valid(_locked_target):
		_face_point(_locked_target.global_position, delta, 15.0)
	elif desired.length_squared() > 0.01:
		_face_direction(desired, delta, 12.0)

	if Input.is_action_just_pressed("dodge") and is_on_floor() and _attack_phase == 0:
		_start_dodge(desired)
	if Input.is_action_just_pressed("interact"):
		_try_interact()

func _update_jump_timers(delta: float) -> void:
	if is_on_floor():
		_coyote_left = coyote_time
	else:
		_coyote_left = maxf(0.0, _coyote_left - delta)
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_left = jump_buffer_time
	else:
		_jump_buffer_left = maxf(0.0, _jump_buffer_left - delta)

func _handle_vertical(delta: float) -> void:
	if _jump_buffer_left > 0.0 and _coyote_left > 0.0 and _dodge_left <= 0.0:
		velocity.y = jump_velocity
		_jump_buffer_left = 0.0
		_coyote_left = 0.0
	if Input.is_action_just_released("jump") and velocity.y > 2.0:
		velocity.y *= 0.48
	if not is_on_floor():
		velocity.y -= (gravity if velocity.y > 0.0 else fall_gravity) * delta
	else:
		if velocity.y < 0.0:
			velocity.y = -0.4

func _start_dodge(input_direction: Vector3) -> void:
	_dodge_direction = input_direction.normalized() if input_direction.length_squared() > 0.01 else _last_move_direction
	if _dodge_direction.length_squared() < 0.01:
		_dodge_direction = -visual.global_transform.basis.z
	_dodge_direction.y = 0.0
	_dodge_direction = _dodge_direction.normalized()
	_dodge_left = 0.34
	_invulnerable_left = maxf(_invulnerable_left, 0.42)
	_attack_phase = 0
	_attack_time = 0.0

func _update_combat(delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		if _attack_phase == 0:
			_begin_attack(1)
		elif _attack_time > 0.14:
			_attack_queued = true

	if _attack_phase <= 0:
		return

	_attack_time += delta
	var active := _attack_time >= 0.10 and _attack_time <= 0.27
	if active:
		_apply_attack_hits()

	var phase_offset := float(_attack_phase - 1) * 0.8
	sword_pivot.rotation.x = -0.8 + sin(clampf(_attack_time / 0.42, 0.0, 1.0) * PI) * 2.1
	sword_pivot.rotation.y = phase_offset * 0.18

	if _attack_time >= 0.42:
		if _attack_queued and _attack_phase < 3:
			_begin_attack(_attack_phase + 1)
		else:
			_attack_phase = 0
			_attack_time = 0.0
			_attack_queued = false
			_attack_hits.clear()
			sword_pivot.rotation = Vector3(deg_to_rad(-25), 0, 0)

func _begin_attack(phase: int) -> void:
	_attack_phase = phase
	_attack_time = 0.0
	_attack_queued = false
	_attack_hits.clear()

func _apply_attack_hits() -> void:
	for body in attack_area.get_overlapping_bodies():
		if body == self or body in _attack_hits:
			continue
		if body.has_method("take_hit"):
			_attack_hits.append(body)
			var damage := 2 if _attack_phase == 3 else 1
			var direction := global_position.direction_to(body.global_position)
			direction.y = 0.0
			body.take_hit(damage, direction.normalized(), self)

func _update_lock_on(delta: float) -> void:
	if Input.is_action_just_pressed("lock_on"):
		if _locked_target != null:
			_locked_target = null
		else:
			_locked_target = _find_lock_target()
		lock_changed.emit(_locked_target)

	if _locked_target != null:
		if not is_instance_valid(_locked_target) or global_position.distance_to(_locked_target.global_position) > 18.0:
			_locked_target = null
			lock_changed.emit(null)
			return
		var to_target := _locked_target.global_position - global_position
		var desired_yaw := atan2(to_target.x, to_target.z)
		camera_pivot.rotation.y = lerp_angle(camera_pivot.rotation.y, desired_yaw + PI, clampf(delta * 4.2, 0.0, 1.0))

func _find_lock_target() -> Node3D:
	var best: Node3D = null
	var best_distance := 16.0
	for node in get_tree().get_nodes_in_group("enemy"):
		if node is Node3D and is_instance_valid(node):
			var distance := global_position.distance_to(node.global_position)
			if distance < best_distance:
				best_distance = distance
				best = node
	return best

func _try_interact() -> void:
	var best: Node = null
	var best_distance := 3.0
	for node in get_tree().get_nodes_in_group("interactable"):
		if node is Node3D:
			var distance := global_position.distance_to(node.global_position)
			if distance < best_distance:
				best_distance = distance
				best = node
	if best != null and best.has_method("interact"):
		best.interact(self)

func _face_direction(direction: Vector3, delta: float, speed: float) -> void:
	if direction.length_squared() < 0.001:
		return
	var target_yaw := atan2(-direction.x, -direction.z)
	visual.rotation.y = lerp_angle(visual.rotation.y, target_yaw, clampf(delta * speed, 0.0, 1.0))

func _face_point(point: Vector3, delta: float, speed: float) -> void:
	var direction := point - global_position
	direction.y = 0.0
	_face_direction(direction.normalized(), delta, speed)

func _update_visual_animation(delta: float) -> void:
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	var moving := horizontal_speed > 0.35 and is_on_floor()
	var gait := sin(_run_time * (11.0 if horizontal_speed > walk_speed + 0.5 else 8.0))
	if _dodge_left > 0.0:
		body_root.rotation.x = lerp(body_root.rotation.x, deg_to_rad(-28), delta * 12.0)
		visual.position.y = 0.12
	else:
		body_root.rotation.x = lerp(body_root.rotation.x, 0.0, delta * 10.0)
		visual.position.y = sin(_run_time * 8.0) * 0.035 if moving else sin(_run_time * 2.1) * 0.018
	if moving:
		left_leg.rotation.x = gait * 0.72
		right_leg.rotation.x = -gait * 0.72
		if _attack_phase == 0:
			left_arm.rotation.x = -gait * 0.48
			right_arm.rotation.x = gait * 0.48
	else:
		left_leg.rotation.x = lerp(left_leg.rotation.x, 0.0, delta * 8.0)
		right_leg.rotation.x = lerp(right_leg.rotation.x, 0.0, delta * 8.0)
		left_arm.rotation.x = lerp(left_arm.rotation.x, 0.0, delta * 8.0)
		if _attack_phase == 0:
			right_arm.rotation.x = lerp(right_arm.rotation.x, 0.0, delta * 8.0)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and _locked_target == null:
		camera_pivot.rotation.y -= event.screen_relative.x * mouse_sensitivity
		camera_pivot.rotation.x -= event.screen_relative.y * mouse_sensitivity
		camera_pivot.rotation.x = clampf(camera_pivot.rotation.x, deg_to_rad(-55), deg_to_rad(45))
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			spring_arm.spring_length = maxf(3.2, spring_arm.spring_length - 0.45)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			spring_arm.spring_length = minf(7.8, spring_arm.spring_length + 0.45)

func hurt(amount: int = 1, knockback := Vector3.ZERO) -> void:
	if _invulnerable_left > 0.0:
		return
	if Input.is_action_pressed("guard") and is_on_floor():
		_invulnerable_left = 0.18
		velocity += knockback * 0.35
		return
	health = maxi(0, health - amount)
	health_changed.emit(health, max_health)
	velocity += knockback
	_invulnerable_left = 0.78
	if health <= 0:
		respawn()

func respawn() -> void:
	global_position = _spawn_position
	velocity = Vector3.ZERO
	health = max_health
	health_changed.emit(health, max_health)

func set_checkpoint(point: Vector3) -> void:
	_spawn_position = point
	GameManager.save_player(self)

func collect_shard(value: int = 1) -> void:
	shards += value
	shards_changed.emit(shards)

func collect_coin(value: int = 1) -> void:
	coins += value
	coins_changed.emit(coins)

func collect_key(value: int = 1) -> void:
	keys += value
	keys_changed.emit(keys)

func consume_key() -> bool:
	if keys <= 0:
		return false
	keys -= 1
	keys_changed.emit(keys)
	return true

func heal(value: int = 1) -> void:
	health = mini(max_health, health + value)
	health_changed.emit(health, max_health)

func sync_stats() -> void:
	health_changed.emit(health, max_health)
	shards_changed.emit(shards)
	coins_changed.emit(coins)
	keys_changed.emit(keys)
