class_name LumaInteractable
extends StaticBody3D

@export_enum("npc", "gate", "checkpoint", "sign") var kind := "npc"
@export var title := "Traveler"
@export_multiline var message := "The castle watches over every road in Green Fields."
@export var requires_key := false

var opened := false

func _ready() -> void:
	add_to_group("interactable")
	if kind == "npc":
		_build_npc()
	elif kind == "gate":
		_build_gate()
	elif kind == "checkpoint":
		_build_checkpoint()
	else:
		_build_sign()

func _build_npc() -> void:
	ArtFactory.box(self, Vector3(0.7, 0.95, 0.45), Color("#7b5a93"), Vector3(0, 0.95, 0))
	ArtFactory.sphere(self, 0.34, Color("#d8aa86"), Vector3(0, 1.65, 0))
	ArtFactory.add_box_collider(self, Vector3(0.8, 1.8, 0.7), Vector3(0, 0.9, 0))

func _build_gate() -> void:
	var stone := ArtFactory.mat(Color("#59645d"), 0.95)
	ArtFactory.box(self, Vector3(0.65, 4.6, 0.75), Color.WHITE, Vector3(-2.15, 2.3, 0), Vector3.ZERO, stone)
	ArtFactory.box(self, Vector3(0.65, 4.6, 0.75), Color.WHITE, Vector3(2.15, 2.3, 0), Vector3.ZERO, stone)
	ArtFactory.box(self, Vector3(4.95, 0.65, 0.75), Color.WHITE, Vector3(0, 4.35, 0), Vector3.ZERO, stone)
	var bars := ArtFactory.mat(Color("#3a443d"), 0.75)
	for x in [-1.4, -0.7, 0.0, 0.7, 1.4]:
		ArtFactory.box(self, Vector3(0.14, 3.7, 0.18), Color.WHITE, Vector3(x, 1.85, 0), Vector3.ZERO, bars)
	ArtFactory.add_box_collider(self, Vector3(4.3, 3.8, 0.55), Vector3(0, 1.9, 0))

func _build_checkpoint() -> void:
	var stone := ArtFactory.mat(Color("#66736a"), 0.9)
	var light := ArtFactory.mat(Color("#7ceaff"), 0.2, Color("#42d9ff"), 2.2)
	ArtFactory.cylinder(self, 0.55, 1.0, Color.WHITE, Vector3(0, 0.5, 0), Vector3.ZERO, stone)
	ArtFactory.cone(self, 0.3, 1.0, Color.WHITE, Vector3(0, 1.45, 0), Vector3.ZERO, light)

func _build_sign() -> void:
	ArtFactory.box(self, Vector3(0.18, 1.6, 0.18), Color("#63452b"), Vector3(0, 0.8, 0))
	ArtFactory.box(self, Vector3(1.7, 0.65, 0.18), Color("#805b33"), Vector3(0, 1.55, 0))

func interact(player: Node) -> void:
	if opened:
		return
	match kind:
		"gate":
			if requires_key and not player.consume_key():
				player.dialogue_requested.emit("Luma", "The old lock is still sealed. A ruin key should open it.")
				return
			opened = true
			player.dialogue_requested.emit("Luma", "The ancient gate is open. Something heavy is moving ahead...")
			var tween := create_tween()
			tween.tween_property(self, "position:y", position.y + 5.0, 0.85).set_trans(Tween.TRANS_QUAD)
			tween.tween_callback(func(): collision_layer = 0)
		"checkpoint":
			player.set_checkpoint(global_position + Vector3(0, 0.2, 2.2))
			player.dialogue_requested.emit("Luma", "This light remembers our path. We'll return here if we fall.")
		_:
			player.dialogue_requested.emit(title, message)
