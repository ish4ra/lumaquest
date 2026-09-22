class_name LumaCompanion
extends Node3D

@export var follow_speed := 7.0
@export var reveal_radius := 7.0

var target: Node3D = null
var _time := 0.0
var _pulse_cooldown := 0.0
var _pulse_mesh: MeshInstance3D
var _pulse_material: StandardMaterial3D
var _wings: Array[Node3D] = []

func _ready() -> void:
	_build_visual()
	target = get_tree().get_first_node_in_group("player") as Node3D

func _build_visual() -> void:
	var glow := ArtFactory.mat(Color("#8cf4ff"), 0.15, Color("#52dcff"), 3.8)
	ArtFactory.sphere(self, 0.19, Color.WHITE, Vector3.ZERO, glow, "Core")
	var wing_mat := ArtFactory.mat(Color(0.55, 0.92, 1.0, 0.72), 0.25, Color("#7deaff"), 1.8)
	for side in [-1.0, 1.0]:
		var wing_root := Node3D.new()
		wing_root.position = Vector3(0.16 * side, 0.05, 0)
		add_child(wing_root)
		var wing := ArtFactory.box(wing_root, Vector3(0.34, 0.07, 0.18), Color.WHITE, Vector3(0.14 * side, 0, 0), Vector3(0, deg_to_rad(22 * side), deg_to_rad(-22 * side)), wing_mat, "Wing")
		_wings.append(wing_root)
	var light := OmniLight3D.new()
	light.light_color = Color("#67dcff")
	light.light_energy = 2.0
	light.omni_range = 4.2
	light.shadow_enabled = false
	add_child(light)

	var sphere := SphereMesh.new()
	sphere.radius = 1.0
	sphere.height = 2.0
	sphere.radial_segments = 24
	sphere.rings = 12
	_pulse_material = ArtFactory.mat(Color(0.25, 0.8, 1.0, 0.0), 0.2, Color("#46d5ff"), 1.2)
	_pulse_mesh = ArtFactory.mesh_instance(sphere, _pulse_material, self, Vector3.ZERO, Vector3.ZERO, Vector3.ONE * 0.1, "RevealPulse")
	_pulse_mesh.visible = false

func _process(delta: float) -> void:
	_time += delta
	_pulse_cooldown = maxf(0.0, _pulse_cooldown - delta)
	if target == null or not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player") as Node3D
	if target != null:
		var side := -0.8
		var desired := target.global_position + target.global_transform.basis.x * side + Vector3(0, 2.35 + sin(_time * 3.6) * 0.16, 0.15)
		global_position = global_position.lerp(desired, clampf(delta * follow_speed, 0.0, 1.0))

	for i in range(_wings.size()):
		var wing_root := _wings[i]
		var side_sign := -1.0 if i == 0 else 1.0
		wing_root.rotation.z = side_sign * (0.25 + sin(_time * 15.0) * 0.35)

	if Input.is_action_just_pressed("luma") and _pulse_cooldown <= 0.0:
		reveal()

func reveal() -> void:
	_pulse_cooldown = 0.75
	get_tree().call_group("luma_reveal", "luma_reveal", global_position, reveal_radius)
	_pulse_mesh.visible = true
	_pulse_mesh.scale = Vector3.ONE * 0.12
	_pulse_material.albedo_color = Color(0.25, 0.85, 1.0, 0.24)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(_pulse_mesh, "scale", Vector3.ONE * reveal_radius, 0.46).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(_pulse_material, "albedo_color:a", 0.0, 0.48)
	tween.chain().tween_callback(func(): _pulse_mesh.visible = false)
