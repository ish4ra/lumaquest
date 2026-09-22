extends Node3D

const PLAYER_SCENE := preload("res://scenes/Player.tscn")
const LUMA_SCENE := preload("res://scenes/Luma.tscn")
const ENEMY_SCENE := preload("res://scenes/Enemy.tscn")
const HUD_SCENE := preload("res://scenes/HUD.tscn")
const COLLECTIBLE_SCENE := preload("res://scenes/Collectible.tscn")
const INTERACTABLE_SCENE := preload("res://scenes/Interactable.tscn")
const HIDDEN_PLATFORM_SCRIPT := preload("res://scripts/HiddenPlatform.gd")

var player: LumaQuestPlayer
var luma: LumaCompanion
var hud: LumaHUD

var grass_mat: StandardMaterial3D
var grass_light_mat: StandardMaterial3D
var stone_mat: StandardMaterial3D
var stone_dark_mat: StandardMaterial3D
var wood_mat: StandardMaterial3D
var water_mat: StandardMaterial3D
var ruin_mat: StandardMaterial3D
var leaf_mat: StandardMaterial3D
var leaf_light_mat: StandardMaterial3D

func _ready() -> void:
	_build_materials()
	_build_environment()
	_build_green_fields()
	_spawn_gameplay()
	_intro()

func _build_materials() -> void:
	grass_mat = ArtFactory.mat(Color("#4f8f42"), 0.95)
	grass_light_mat = ArtFactory.mat(Color("#76ad55"), 0.92)
	stone_mat = ArtFactory.mat(Color("#59645b"), 0.96)
	stone_dark_mat = ArtFactory.mat(Color("#39463f"), 0.98)
	wood_mat = ArtFactory.mat(Color("#714a2b"), 0.9)
	water_mat = ArtFactory.mat(Color(0.2, 0.66, 0.82, 0.72), 0.18, Color("#4cc8e8"), 0.25)
	ruin_mat = ArtFactory.mat(Color("#747d68"), 0.96)
	leaf_mat = ArtFactory.mat(Color("#255c38"), 0.98)
	leaf_light_mat = ArtFactory.mat(Color("#3f7d43"), 0.96)

func _build_environment() -> void:
	var world_environment := WorldEnvironment.new()
	var env := Environment.new()
	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("#2c78b9")
	sky_material.sky_horizon_color = Color("#b9e4f4")
	sky_material.ground_bottom_color = Color("#334b49")
	sky_material.ground_horizon_color = Color("#9bc8bf")
	sky_material.sun_angle_max = 22.0
	sky_material.sun_curve = 0.08
	sky.sky_material = sky_material
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_color = Color("#c7e5dc")
	env.ambient_light_energy = 0.72
	env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	env.fog_enabled = true
	env.fog_light_color = Color("#a9d6d8")
	env.fog_light_energy = 0.55
	env.fog_density = 0.0048
	env.fog_height = -4.0
	env.fog_height_density = 0.12
	world_environment.environment = env
	add_child(world_environment)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-51, -32, 0)
	sun.light_color = Color("#fff0cb")
	sun.light_energy = 1.18
	sun.shadow_enabled = true
	add_child(sun)

	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-25, 145, 0)
	fill.light_color = Color("#8fc9e4")
	fill.light_energy = 0.28
	fill.shadow_enabled = false
	add_child(fill)

func _build_green_fields() -> void:
	# Main traversable landmasses: broad enough for combat, separated enough to feel like a journey.
	_add_land("StartGrove", Vector3(0, 0, 5), Vector2(22, 22), 7.0)
	_add_bridge(Vector3(0, 0.15, -11.5), 11.0, 3.2)
	_add_land("GoblinMeadow", Vector3(0, 0, -25), Vector2(24, 15), 7.5)
	_add_land("AncientRuinPlateau", Vector3(0, 0.7, -41), Vector2(25, 16), 8.5)
	_add_land("BossArena", Vector3(0, 0, -59), Vector2(28, 18), 8.0)

	# Small platforming route around the ruins.
	_add_land("StepA", Vector3(9.0, 1.3, -34.5), Vector2(3.2, 3.2), 3.5, grass_light_mat)
	_add_land("StepB", Vector3(10.8, 2.3, -39.0), Vector2(3.0, 3.0), 4.5, grass_light_mat)
	_add_land("StepC", Vector3(8.2, 3.2, -43.5), Vector2(3.4, 3.4), 5.4, grass_light_mat)

	_build_river()
	_build_trees()
	_build_ruins()
	_build_distant_landmarks()
	_build_path_details()

func _add_land(name_value: String, top_position: Vector3, footprint: Vector2, depth: float, top_material: Material = null) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = name_value
	body.position = Vector3(top_position.x, top_position.y - depth * 0.5, top_position.z)
	body.collision_layer = 1
	body.collision_mask = 1
	add_child(body)
	ArtFactory.box(body, Vector3(footprint.x, depth, footprint.y), Color.WHITE, Vector3.ZERO, Vector3.ZERO, stone_dark_mat, "Cliff")
	var chosen_top := top_material if top_material != null else grass_mat
	ArtFactory.box(body, Vector3(footprint.x + 0.08, 0.22, footprint.y + 0.08), Color.WHITE, Vector3(0, depth * 0.5 + 0.11, 0), Vector3.ZERO, chosen_top, "GrassTop")
	ArtFactory.add_box_collider(body, Vector3(footprint.x, depth, footprint.y))
	return body

func _add_bridge(center: Vector3, length: float, width: float) -> void:
	var body := StaticBody3D.new()
	body.name = "OldBridge"
	body.position = center
	body.collision_layer = 1
	add_child(body)
	ArtFactory.add_box_collider(body, Vector3(width, 0.34, length), Vector3(0, 0, 0))
	var plank_count := 12
	for i in range(plank_count):
		var z := -length * 0.5 + (float(i) + 0.5) * (length / plank_count)
		var angle := deg_to_rad(sin(float(i) * 2.3) * 1.8)
		ArtFactory.box(body, Vector3(width, 0.18, length / plank_count * 0.9), Color.WHITE, Vector3(0, 0.14, z), Vector3(0, angle, 0), wood_mat, "Plank%02d" % i)
	for side in [-1.0, 1.0]:
		for i in range(6):
			var z := -length * 0.45 + float(i) * length / 5.0
			ArtFactory.cylinder(body, 0.06, 1.2, Color("#4e3524"), Vector3(side * (width * 0.5 + 0.18), 0.55, z))
		ArtFactory.box(body, Vector3(0.1, 0.1, length), Color.WHITE, Vector3(side * (width * 0.5 + 0.18), 1.0, 0), Vector3.ZERO, wood_mat)

func _build_river() -> void:
	var river := Node3D.new()
	river.name = "RiverGorge"
	add_child(river)
	ArtFactory.box(river, Vector3(42, 0.16, 24), Color.WHITE, Vector3(0, -5.3, -12), Vector3.ZERO, water_mat, "River")
	for x in [-8.0, 7.5]:
		var waterfall := ArtFactory.box(river, Vector3(3.0, 8.0, 0.16), Color.WHITE, Vector3(x, -1.4, -73), Vector3.ZERO, water_mat, "Waterfall")
		waterfall.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _build_trees() -> void:
	var trees := [
		[Vector3(-8.2, 0, 9), 1.7],
		[Vector3(8.7, 0, 7), 1.3],
		[Vector3(-9.2, 0, -23), 1.25],
		[Vector3(8.6, 0, -27), 1.45],
		[Vector3(-9.5, 0.7, -41), 1.4],
		[Vector3(9.4, 0.7, -45), 1.1],
		[Vector3(-11.0, 0, -60), 1.15],
		[Vector3(11.2, 0, -57), 1.35]
	]
	for entry in trees:
		_add_tree(entry[0], entry[1])

func _add_tree(pos: Vector3, scale_value: float) -> void:
	var root := Node3D.new()
	root.position = pos
	root.scale = Vector3.ONE * scale_value
	add_child(root)
	ArtFactory.cylinder(root, 0.42, 4.1, Color("#513c29"), Vector3(0, 2.05, 0), Vector3.ZERO, null, "Trunk")
	ArtFactory.sphere(root, 1.75, Color.WHITE, Vector3(-0.75, 4.2, 0), leaf_mat, "CanopyA")
	ArtFactory.sphere(root, 1.55, Color.WHITE, Vector3(0.85, 4.45, 0.1), leaf_light_mat, "CanopyB")
	ArtFactory.sphere(root, 1.35, Color.WHITE, Vector3(0.0, 5.15, -0.25), leaf_mat, "CanopyC")
	ArtFactory.box(root, Vector3(3.0, 0.24, 0.28), Color("#513c29"), Vector3(0.3, 3.1, 0), Vector3(0, 0, deg_to_rad(-18)), null, "Branch")

func _build_ruins() -> void:
	# Start grove broken arch.
	_add_ruin_arch(Vector3(-5.8, 0, 0.2), 0.85)
	# Ruin plateau centerpiece.
	_add_ruin_arch(Vector3(-3.5, 0.7, -42.5), 1.35)
	for p in [
		Vector3(-8, 0.7, -37),
		Vector3(7, 0.7, -38),
		Vector3(-7, 0.7, -46),
		Vector3(6, 0.7, -45)
	]:
		_add_ruin_pillar(p, 3.0 + abs(sin(p.x)) * 1.5)
	# Arena stones.
	for p in [Vector3(-10,0,-55), Vector3(10,0,-55), Vector3(-10,0,-64), Vector3(10,0,-64)]:
		_add_ruin_pillar(p, 2.8)

func _add_ruin_arch(pos: Vector3, scale_value: float) -> void:
	var root := Node3D.new()
	root.position = pos
	root.scale = Vector3.ONE * scale_value
	add_child(root)
	ArtFactory.box(root, Vector3(0.9, 4.8, 1.0), Color.WHITE, Vector3(-2.1, 2.4, 0), Vector3.ZERO, ruin_mat)
	ArtFactory.box(root, Vector3(0.9, 4.1, 1.0), Color.WHITE, Vector3(2.1, 2.05, 0), Vector3.ZERO, ruin_mat)
	ArtFactory.box(root, Vector3(5.0, 0.8, 1.0), Color.WHITE, Vector3(0, 4.55, 0), Vector3(0, 0, deg_to_rad(-2)), ruin_mat)
	var moss := ArtFactory.mat(Color("#3e7143"), 0.98)
	ArtFactory.box(root, Vector3(5.0, 0.12, 1.05), Color.WHITE, Vector3(0, 4.98, 0), Vector3.ZERO, moss)

func _add_ruin_pillar(pos: Vector3, height: float) -> void:
	var root := Node3D.new()
	root.position = pos
	add_child(root)
	ArtFactory.box(root, Vector3(1.0, height, 1.0), Color.WHITE, Vector3(0, height * 0.5, 0), Vector3.ZERO, ruin_mat)
	ArtFactory.box(root, Vector3(1.25, 0.28, 1.25), Color.WHITE, Vector3(0, height + 0.1, 0), Vector3.ZERO, stone_mat)

func _build_distant_landmarks() -> void:
	var distant := Node3D.new()
	distant.name = "DistantLandmarks"
	add_child(distant)
	# Mountains.
	for data in [
		[Vector3(-38, 8, -120), 24.0, 34.0, Color("#5c7e83")],
		[Vector3(36, 10, -132), 30.0, 42.0, Color("#496d77")],
		[Vector3(0, 13, -148), 36.0, 52.0, Color("#46666e")]
	]:
		ArtFactory.cone(distant, data[1], data[2], data[3], data[0], Vector3.ZERO, null, "Mountain")
	# Castle island/cliff.
	ArtFactory.box(distant, Vector3(30, 9, 22), Color.WHITE, Vector3(0, -1.5, -94), Vector3.ZERO, stone_dark_mat, "CastleCliff")
	var castle_mat := ArtFactory.mat(Color("#879899"), 0.92)
	for x in [-8.0, -3.5, 0.0, 3.5, 8.0]:
		var h := 12.0 + (5.0 if x == 0.0 else 0.0) + (2.0 if abs(x) == 3.5 else 0.0)
		ArtFactory.box(distant, Vector3(3.0, h, 3.0), Color.WHITE, Vector3(x, 9.0 + h * 0.5, -94), Vector3.ZERO, castle_mat, "Tower")
		ArtFactory.cone(distant, 2.2, 4.2, Color("#335a76"), Vector3(x, 9.0 + h + 2.0, -94), Vector3.ZERO, null, "Roof")
	ArtFactory.box(distant, Vector3(19, 7.0, 6.5), Color.WHITE, Vector3(0, 12.2, -94), Vector3.ZERO, castle_mat, "Keep")

	# Large soft cloud clusters, intentionally geometric/stylized.
	var cloud_mat := ArtFactory.mat(Color(0.9, 0.97, 1.0, 0.82), 0.9)
	for center in [Vector3(-28, 28, -105), Vector3(28, 31, -118), Vector3(4, 36, -145)]:
		for offset in [Vector3(-4,0,0), Vector3(0,1.5,0), Vector3(4,0.4,0), Vector3(1,-1.2,0)]:
			var cloud := ArtFactory.sphere(distant, 4.4, Color.WHITE, center + offset, cloud_mat, "Cloud")
			cloud.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _build_path_details() -> void:
	# Lanterns and flowers give the foreground the dense illustrated feeling from the concept.
	for p in [Vector3(-3.5,0,8), Vector3(4.5,0,-22), Vector3(-5.5,0.7,-39), Vector3(5,0,-56)]:
		_add_lantern(p)
	for i in range(42):
		var z := 10.0 - float(i) * 1.7
		var x := sin(float(i) * 2.17) * 7.8
		var y := 0.05
		if z < -32.0 and z > -49.0:
			y = 0.75
		var color := Color("#f4d96d") if i % 3 == 0 else Color("#e86c8b") if i % 3 == 1 else Color("#75d7ff")
		ArtFactory.sphere(self, 0.08, color, Vector3(x, y + 0.13, z), ArtFactory.mat(color, 0.8, color, 0.2), "Flower")

func _add_lantern(pos: Vector3) -> void:
	var root := Node3D.new()
	root.position = pos
	add_child(root)
	ArtFactory.cylinder(root, 0.07, 2.6, Color("#40352a"), Vector3(0, 1.3, 0))
	ArtFactory.box(root, Vector3(0.55, 0.62, 0.55), Color("#352e28"), Vector3(0, 2.35, 0))
	var glow := ArtFactory.mat(Color("#ffd66a"), 0.2, Color("#ffbf45"), 2.4)
	ArtFactory.sphere(root, 0.18, Color.WHITE, Vector3(0, 2.35, -0.29), glow)
	var light := OmniLight3D.new()
	light.position = Vector3(0, 2.3, 0)
	light.light_color = Color("#ffc25b")
	light.light_energy = 1.2
	light.omni_range = 4.0
	light.shadow_enabled = false
	root.add_child(light)

func _spawn_gameplay() -> void:
	player = PLAYER_SCENE.instantiate() as LumaQuestPlayer
	player.name = "Player"
	player.position = Vector3(0, 0.3, 9.0)
	player.add_to_group("player")
	add_child(player)

	luma = LUMA_SCENE.instantiate() as LumaCompanion
	luma.position = Vector3(-0.8, 2.4, 9.0)
	add_child(luma)

	hud = HUD_SCENE.instantiate() as LumaHUD
	add_child(hud)
	hud.bind_player(player)
	GameManager.load_player(player)

	_spawn_enemy("slime", Vector3(4.5, 0.3, -22.5))
	_spawn_enemy("goblin", Vector3(-4.5, 0.3, -25.0))
	_spawn_enemy("goblin", Vector3(5.8, 0.3, -28.0))
	_spawn_enemy("bat", Vector3(-3.0, 2.3, -38.0))
	_spawn_enemy("skeleton", Vector3(3.0, 1.0, -44.0))
	_spawn_enemy("mini_boss", Vector3(0, 0.4, -60.0))

	for data in [
		["shard", Vector3(-2,0.8,2), 1],
		["shard", Vector3(3,0.8,-4), 1],
		["coin", Vector3(-3,0.7,-22), 3],
		["coin", Vector3(3,0.7,-27), 3],
		["shard", Vector3(8.2,4.0,-43.5), 2],
		["heart", Vector3(-6.5,1.4,-45), 1],
		["key", Vector3(5.8,1.55,-43.2), 1]
	]:
		_spawn_collectible(data[0], data[1], data[2])

	# Luma-only secret crossing off the left side of the start grove.
	_spawn_hidden_platform(Vector3(-12.5, -0.1, 1.5), Vector3(3.0, 0.35, 2.5))
	_spawn_hidden_platform(Vector3(-15.5, 0.65, -0.5), Vector3(3.0, 0.35, 2.5))
	_spawn_hidden_platform(Vector3(-18.2, 1.35, -2.5), Vector3(3.0, 0.35, 2.5))
	_spawn_collectible("shard", Vector3(-18.2, 2.2, -2.5), 3)

	var npc := _spawn_interactable("npc", Vector3(-3.8, 0.2, 6.0))
	npc.title = "Mara"
	npc.message = "The old road ends at a sealed gate. Search the high ruins for a key — and trust Luma when the path disappears."

	var sign := _spawn_interactable("sign", Vector3(3.7, 0.0, 4.8))
	sign.title = "Weathered Sign"
	sign.message = "Village ←     Ancient Ruins ↑     Lake →"

	var checkpoint := _spawn_interactable("checkpoint", Vector3(-4.0, 0.7, -45.2))
	checkpoint.title = "Memory Light"

	var gate := _spawn_interactable("gate", Vector3(0, 0, -49.1))
	gate.requires_key = true
	gate.title = "Ancient Gate"

	# Funnel the arena entrance so the gate matters.
	_add_land("GateWallL", Vector3(-9.0, 3.5, -49.0), Vector2(8.0, 2.4), 7.0, stone_mat)
	_add_land("GateWallR", Vector3(9.0, 3.5, -49.0), Vector2(8.0, 2.4), 7.0, stone_mat)

func _spawn_enemy(kind: String, pos: Vector3) -> LumaEnemy:
	var enemy := ENEMY_SCENE.instantiate() as LumaEnemy
	enemy.enemy_type = kind
	enemy.position = pos
	add_child(enemy)
	return enemy

func _spawn_collectible(kind: String, pos: Vector3, value: int) -> LumaCollectible:
	var item := COLLECTIBLE_SCENE.instantiate() as LumaCollectible
	item.kind = kind
	item.value = value
	item.position = pos
	add_child(item)
	return item

func _spawn_hidden_platform(pos: Vector3, size: Vector3) -> HiddenLumaPlatform:
	var platform := HIDDEN_PLATFORM_SCRIPT.new() as HiddenLumaPlatform
	platform.position = pos
	platform.platform_size = size
	add_child(platform)
	return platform

func _spawn_interactable(kind: String, pos: Vector3) -> LumaInteractable:
	var interactable := INTERACTABLE_SCENE.instantiate() as LumaInteractable
	interactable.kind = kind
	interactable.position = pos
	add_child(interactable)
	return interactable

func _intro() -> void:
	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(player):
		player.dialogue_requested.emit("Luma", "There's something hidden nearby... Look closely. Press F when my light begins to shimmer.")
