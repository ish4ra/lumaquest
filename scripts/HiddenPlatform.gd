class_name HiddenLumaPlatform
extends StaticBody3D

@export var platform_size := Vector3(3.2, 0.35, 2.4)
@export var reveal_duration := 6.0

var _visible_left := 0.0
var _mesh: MeshInstance3D
var _material: StandardMaterial3D
var _collider: CollisionShape3D

func _ready() -> void:
	add_to_group("luma_reveal")
	collision_layer = 1
	collision_mask = 1
	_material = ArtFactory.mat(Color(0.26, 0.78, 0.9, 0.04), 0.45, Color("#46d7ff"), 0.45)
	_mesh = ArtFactory.box(self, platform_size, Color.WHITE, Vector3.ZERO, Vector3.ZERO, _material, "HiddenPlatform")
	_collider = ArtFactory.add_box_collider(self, platform_size)
	_collider.disabled = true

func luma_reveal(origin: Vector3, radius: float) -> void:
	if global_position.distance_to(origin) > radius:
		return
	_visible_left = reveal_duration
	_collider.set_deferred("disabled", false)

func _process(delta: float) -> void:
	_visible_left = maxf(0.0, _visible_left - delta)
	var target_alpha := 0.88 if _visible_left > 0.0 else 0.04
	_material.albedo_color.a = lerpf(_material.albedo_color.a, target_alpha, clampf(delta * 6.0, 0.0, 1.0))
	if _visible_left <= 0.0 and _material.albedo_color.a < 0.08:
		_collider.set_deferred("disabled", true)
