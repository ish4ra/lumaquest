class_name LumaEnemy
extends CharacterBody3D

@export_enum("goblin", "slime", "bat", "skeleton", "golem", "mini_boss") var enemy_type := "goblin"
@export var move_speed := 2.4
@export var detection_radius := 9.0
@export var attack_radius := 1.65
@export var patrol_radius := 3.5
@export var max_health := 3
@export var gravity := 26.0

var health := 3
var _spawn := Vector3.ZERO
var _patrol_angle := 0.0
var _attack_cooldown := 0.0
var _stun_left := 0.0
var _dead := false
var _player: Node3D = null
var _time := 0.0

@onready var visual: Node3D = $Visual

func _ready() -> void:
	add_to_group("enemy")
	_spawn = global_position
	health = max_health
	_player = get_tree().get_first_node_in_group("player") as Node3D
	_apply_type_stats()
	_build_visual()

func _apply_type_stats() -> void:
	match enemy_type:
		"slime":
			max_health = 2
			move_speed = 1.8
			attack_radius = 1.25
		"bat":
			max_health = 1
			move_speed = 3.4
			detection_radius = 10.0
		"skeleton":
			max_health = 4
			move_speed = 2.8
		"golem":
			max_health = 8
			move_speed = 1.35
			attack_radius = 2.3
		"mini_boss":
			max_health = 14
			move_speed = 2.0
			detection_radius = 14.0
			attack_radius = 2.65
	health = max_health

func _build_visual() -> void:
	match enemy_type:
		"slime":
			_build_slime()
		"bat":
			_build_bat()
		"skeleton":
			_build_skeleton()
		"golem", "mini_boss":
			_build_golem(enemy_type == "mini_boss")
		_:
			_build_goblin()

func _build_goblin() -> void:
	var green := Color("#72a84a")
	var dark := Color("#263927")
	var leather := Color("#6a4327")
	ArtFactory.box(visual, Vector3(0.72, 0.82, 0.45), dark, Vector3(0, 1.05, 0))
	ArtFactory.sphere(visual, 0.36, green, Vector3(0, 1.72, 0))
	ArtFactory.cone(visual, 0.16, 0.42, green, Vector3(-0.42, 1.76, 0), Vector3(0, 0, deg_to_rad(90)))
	ArtFactory.cone(visual, 0.16, 0.42, green, Vector3(0.42, 1.76, 0), Vector3(0, 0, deg_to_rad(-90)))
	ArtFactory.cylinder(visual, 0.11, 0.62, green, Vector3(-0.46, 1.0, 0), Vector3(0, 0, deg_to_rad(-9)))
	ArtFactory.cylinder(visual, 0.11, 0.62, green, Vector3(0.46, 1.0, 0), Vector3(0, 0, deg_to_rad(9)))
	ArtFactory.cylinder(visual, 0.13, 0.62, leather, Vector3(-0.2, 0.36, 0))
	ArtFactory.cylinder(visual, 0.13, 0.62, leather, Vector3(0.2, 0.36, 0))
	var eye_mat := ArtFactory.mat(Color("#fff1a0"), 0.4, Color("#ffd65a"), 1.1)
	ArtFactory.sphere(visual, 0.055, Color.WHITE, Vector3(-0.13, 1.79, -0.32), eye_mat)
	ArtFactory.sphere(visual, 0.055, Color.WHITE, Vector3(0.13, 1.79, -0.32), eye_mat)

func _build_slime() -> void:
	var slime_mat := ArtFactory.mat(Color("#6ed889"), 0.35)
	var body := ArtFactory.sphere(visual, 0.62, Color.WHITE, Vector3(0, 0.62, 0), slime_mat)
	body.scale = Vector3(1.0, 0.75, 1.0)
	var eye_mat := ArtFactory.mat(Color("#132019"), 0.8)
	ArtFactory.sphere(visual, 0.08, Color.BLACK, Vector3(-0.2, 0.72, -0.49), eye_mat)
	ArtFactory.sphere(visual, 0.08, Color.BLACK, Vector3(0.2, 0.72, -0.49), eye_mat)

func _build_bat() -> void:
	var purple := ArtFactory.mat(Color("#5b3f79"), 0.75)
	ArtFactory.sphere(visual, 0.28, Color.WHITE, Vector3(0, 1.35, 0), purple)
	var left := ArtFactory.box(visual, Vector3(0.68, 0.08, 0.42), Color("#432d62"), Vector3(-0.42, 1.42, 0), Vector3(0, 0, deg_to_rad(-18)))
	var right := ArtFactory.box(visual, Vector3(0.68, 0.08, 0.42), Color("#432d62"), Vector3(0.42, 1.42, 0), Vector3(0, 0, deg_to_rad(18)))
	left.rotation.y = deg_to_rad(8)
	right.rotation.y = deg_to_rad(-8)
	ArtFactory.sphere(visual, 0.045, Color("#ff5f82"), Vector3(-0.08, 1.4, -0.24), ArtFactory.mat(Color("#ff5f82"), 0.4, Color("#ff365e"), 1.4))
	ArtFactory.sphere(visual, 0.045, Color("#ff5f82"), Vector3(0.08, 1.4, -0.24), ArtFactory.mat(Color("#ff5f82"), 0.4, Color("#ff365e"), 1.4))

func _build_skeleton() -> void:
	var bone := Color("#e2dcc2")
	var dark := Color("#33323a")
	ArtFactory.sphere(visual, 0.31, bone, Vector3(0, 1.7, 0))
	ArtFactory.box(visual, Vector3(0.65, 0.72, 0.24), dark, Vector3(0, 1.05, 0))
	for x in [-0.42, 0.42]:
		ArtFactory.cylinder(visual, 0.075, 0.72, bone, Vector3(x, 1.0, 0))
	for x in [-0.18, 0.18]:
		ArtFactory.cylinder(visual, 0.08, 0.68, bone, Vector3(x, 0.36, 0))
	var eye_mat := ArtFactory.mat(Color("#76e8ff"), 0.2, Color("#40d8ff"), 2.0)
	ArtFactory.sphere(visual, 0.05, Color.WHITE, Vector3(-0.1, 1.75, -0.27), eye_mat)
	ArtFactory.sphere(visual, 0.05, Color.WHITE, Vector3(0.1, 1.75, -0.27), eye_mat)

func _build_golem(boss: bool) -> void:
	var stone := Color("#59635e") if not boss else Color("#594c50")
	var scale_value := 1.0 if not boss else 1.35
	visual.scale = Vector3.ONE * scale_value
	ArtFactory.box(visual, Vector3(1.3, 1.25, 0.85), stone, Vector3(0, 1.25, 0))
	ArtFactory.box(visual, Vector3(0.86, 0.72, 0.75), stone.lightened(0.08), Vector3(0, 2.18, 0))
	ArtFactory.box(visual, Vector3(0.48, 1.2, 0.5), stone.darkened(0.06), Vector3(-0.92, 1.22, 0))
	ArtFactory.box(visual, Vector3(0.48, 1.2, 0.5), stone.darkened(0.06), Vector3(0.92, 1.22, 0))
	ArtFactory.box(visual, Vector3(0.48, 0.92, 0.55), stone.darkened(0.1), Vector3(-0.42, 0.36, 0))
	ArtFactory.box(visual, Vector3(0.48, 0.92, 0.55), stone.darkened(0.1), Vector3(0.42, 0.36, 0))
	var crystal_color := Color("#9f63ff") if boss else Color("#52d8ff")
	var crystal_mat := ArtFactory.mat(crystal_color, 0.2, crystal_color, 2.4)
	ArtFactory.cone(visual, 0.22, 0.72, crystal_color, Vector3(0, 1.52, -0.55), Vector3(deg_to_rad(90), 0, 0), crystal_mat)

func _physics_process(delta: float) -> void:
	if _dead:
		return
	_time += delta
	_attack_cooldown = maxf(0.0, _attack_cooldown - delta)
	_stun_left = maxf(0.0, _stun_left - delta)
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node3D
		return

	if enemy_type == "bat":
		_update_bat(delta)
	else:
		_update_ground_enemy(delta)

	move_and_slide()

func _update_ground_enemy(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = -0.4

	if _stun_left > 0.0:
		velocity.x = move_toward(velocity.x, 0.0, delta * 8.0)
		velocity.z = move_toward(velocity.z, 0.0, delta * 8.0)
		return

	var distance := global_position.distance_to(_player.global_position)
	var move_dir := Vector3.ZERO
	if distance <= detection_radius:
		move_dir = _player.global_position - global_position
		move_dir.y = 0.0
		if move_dir.length_squared() > 0.001:
			move_dir = move_dir.normalized()
		if distance <= attack_radius:
			move_dir = Vector3.ZERO
			_try_attack()
	else:
		_patrol_angle += delta * 0.7
		var target := _spawn + Vector3(cos(_patrol_angle), 0, sin(_patrol_angle)) * patrol_radius
		move_dir = target - global_position
		move_dir.y = 0.0
		if move_dir.length_squared() > 0.1:
			move_dir = move_dir.normalized()

	velocity.x = move_toward(velocity.x, move_dir.x * move_speed, delta * 8.0)
	velocity.z = move_toward(velocity.z, move_dir.z * move_speed, delta * 8.0)
	if move_dir.length_squared() > 0.02:
		visual.rotation.y = lerp_angle(visual.rotation.y, atan2(-move_dir.x, -move_dir.z), delta * 8.0)
	visual.position.y = sin(_time * (5.0 if enemy_type == "slime" else 7.0)) * (0.05 if enemy_type == "slime" else 0.025)

func _update_bat(delta: float) -> void:
	var desired_y := _spawn.y + 1.0 + sin(_time * 3.2) * 0.45
	var to_player := _player.global_position + Vector3.UP * 1.2 - global_position
	var distance := to_player.length()
	var dir := Vector3.ZERO
	if distance < detection_radius:
		dir = to_player.normalized()
		if distance < attack_radius:
			_try_attack()
	else:
		dir = Vector3(cos(_time * 0.7), 0, sin(_time * 0.7)) * 0.4
		dir.y = (desired_y - global_position.y) * 0.8
	velocity = velocity.lerp(dir * move_speed, clampf(delta * 3.0, 0.0, 1.0))
	if dir.length_squared() > 0.02:
		visual.rotation.y = lerp_angle(visual.rotation.y, atan2(-dir.x, -dir.z), delta * 8.0)

func _try_attack() -> void:
	if _attack_cooldown > 0.0:
		return
	_attack_cooldown = 1.05 if enemy_type != "golem" and enemy_type != "mini_boss" else 1.65
	var knock := global_position.direction_to(_player.global_position)
	knock.y = 0.45
	knock = knock.normalized() * (5.0 if enemy_type != "mini_boss" else 7.5)
	if _player.has_method("hurt"):
		_player.hurt(1, knock)

func take_hit(damage: int = 1, direction := Vector3.ZERO, source: Node = null) -> void:
	if _dead:
		return
	health -= damage
	_stun_left = 0.22 if enemy_type != "golem" and enemy_type != "mini_boss" else 0.12
	velocity += direction * (5.0 if enemy_type != "golem" and enemy_type != "mini_boss" else 2.0)
	velocity.y = 2.5
	var tween := create_tween()
	tween.tween_property(visual, "scale", visual.scale * 0.82, 0.06)
	tween.tween_property(visual, "scale", visual.scale, 0.12)
	if health <= 0:
		_die(source)

func _die(source: Node) -> void:
	_dead = true
	remove_from_group("enemy")
	collision_layer = 0
	collision_mask = 0
	if source != null and source.has_method("collect_coin"):
		source.collect_coin(5 if enemy_type == "mini_boss" else 1)
		if enemy_type == "mini_boss" and source.has_method("collect_shard"):
			source.collect_shard(3)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(visual, "scale", Vector3.ZERO, 0.35).set_trans(Tween.TRANS_BACK)
	tween.tween_property(visual, "position:y", 1.0, 0.35)
	tween.chain().tween_callback(queue_free)
