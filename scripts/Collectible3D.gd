class_name LumaCollectible
extends Area3D

@export_enum("shard", "coin", "key", "heart") var kind := "shard"
@export var value := 1

var _time := 0.0
var _start_y := 0.0

func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	_start_y = position.y
	body_entered.connect(_on_body_entered)
	var shape := SphereShape3D.new()
	shape.radius = 0.5
	var collider := CollisionShape3D.new()
	collider.shape = shape
	add_child(collider)
	_build_visual()

func _build_visual() -> void:
	match kind:
		"coin":
			var gold := ArtFactory.mat(Color("#ffd35a"), 0.28, Color("#ffb733"), 0.65)
			var coin := ArtFactory.cylinder(self, 0.28, 0.07, Color.WHITE, Vector3.ZERO, Vector3(deg_to_rad(90), 0, 0), gold, "Coin")
			coin.scale.z = 0.8
		"key":
			var key_mat := ArtFactory.mat(Color("#f5c44d"), 0.25, Color("#ffca4d"), 0.8)
			ArtFactory.box(self, Vector3(0.1, 0.75, 0.1), Color.WHITE, Vector3(0, -0.08, 0), Vector3(0, 0, deg_to_rad(-25)), key_mat, "KeyStem")
			ArtFactory.sphere(self, 0.25, Color.WHITE, Vector3(-0.16, 0.3, 0), key_mat, "KeyRing")
		"heart":
			var heart_mat := ArtFactory.mat(Color("#ff4e63"), 0.28, Color("#ff334f"), 1.0)
			ArtFactory.sphere(self, 0.22, Color.WHITE, Vector3(-0.16, 0.1, 0), heart_mat)
			ArtFactory.sphere(self, 0.22, Color.WHITE, Vector3(0.16, 0.1, 0), heart_mat)
			ArtFactory.cone(self, 0.32, 0.55, Color.WHITE, Vector3(0, -0.22, 0), Vector3(0, 0, PI), heart_mat)
		_:
			var crystal := ArtFactory.mat(Color("#71ddff"), 0.15, Color("#43cfff"), 2.4)
			ArtFactory.cone(self, 0.26, 0.8, Color.WHITE, Vector3.ZERO, Vector3.ZERO, crystal, "Shard")

func _process(delta: float) -> void:
	_time += delta
	position.y = _start_y + sin(_time * 3.0) * 0.14
	rotation.y += delta * 1.8

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	match kind:
		"coin":
			body.collect_coin(value)
		"key":
			body.collect_key(value)
		"heart":
			body.heal(value)
		_:
			body.collect_shard(value)
	queue_free()
