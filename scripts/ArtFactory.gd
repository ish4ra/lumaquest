class_name ArtFactory
extends RefCounted

static func mat(color: Color, roughness: float = 0.9, emission: Color = Color(0, 0, 0, 1), emission_energy: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	if color.a < 0.999:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	if emission_energy > 0.0:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = emission_energy
	return material

static func mesh_instance(mesh: Mesh, material: Material, parent: Node3D, pos := Vector3.ZERO, rot := Vector3.ZERO, scale_value := Vector3.ONE, node_name := "Mesh") -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.material_override = material
	instance.position = pos
	instance.rotation = rot
	instance.scale = scale_value
	parent.add_child(instance)
	return instance

static func box(parent: Node3D, size: Vector3, color: Color, pos := Vector3.ZERO, rot := Vector3.ZERO, material: Material = null, node_name := "Box") -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var use_material := material if material != null else mat(color)
	return mesh_instance(mesh, use_material, parent, pos, rot, Vector3.ONE, node_name)

static func sphere(parent: Node3D, radius: float, color: Color, pos := Vector3.ZERO, material: Material = null, node_name := "Sphere") -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 16
	mesh.rings = 8
	var use_material := material if material != null else mat(color)
	return mesh_instance(mesh, use_material, parent, pos, Vector3.ZERO, Vector3.ONE, node_name)

static func cylinder(parent: Node3D, radius: float, height: float, color: Color, pos := Vector3.ZERO, rot := Vector3.ZERO, material: Material = null, node_name := "Cylinder") -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius * 1.04
	mesh.height = height
	mesh.radial_segments = 10
	var use_material := material if material != null else mat(color)
	return mesh_instance(mesh, use_material, parent, pos, rot, Vector3.ONE, node_name)

static func cone(parent: Node3D, radius: float, height: float, color: Color, pos := Vector3.ZERO, rot := Vector3.ZERO, material: Material = null, node_name := "Cone") -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.0
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 8
	var use_material := material if material != null else mat(color)
	return mesh_instance(mesh, use_material, parent, pos, rot, Vector3.ONE, node_name)

static func add_box_collider(body: CollisionObject3D, size: Vector3, pos := Vector3.ZERO) -> CollisionShape3D:
	var shape := BoxShape3D.new()
	shape.size = size
	var collider := CollisionShape3D.new()
	collider.shape = shape
	collider.position = pos
	body.add_child(collider)
	return collider

static func add_sphere_collider(body: CollisionObject3D, radius: float, pos := Vector3.ZERO) -> CollisionShape3D:
	var shape := SphereShape3D.new()
	shape.radius = radius
	var collider := CollisionShape3D.new()
	collider.shape = shape
	collider.position = pos
	body.add_child(collider)
	return collider
