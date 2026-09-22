class_name LumaHUD
extends CanvasLayer

var player: Node = null
var _health_label: Label
var _shard_label: Label
var _coin_label: Label
var _key_label: Label
var _objective_label: Label
var _map_position_label: Label
var _lock_label: Label
var _dialogue_panel: PanelContainer
var _dialogue_speaker: Label
var _dialogue_text: Label
var _inventory_panel: PanelContainer
var _map_panel: PanelContainer
var _pause_panel: PanelContainer
var _dialogue_timer := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()

func bind_player(target: Node) -> void:
	player = target
	if player == null:
		return
	player.health_changed.connect(_on_health_changed)
	player.shards_changed.connect(_on_shards_changed)
	player.coins_changed.connect(_on_coins_changed)
	player.keys_changed.connect(_on_keys_changed)
	player.lock_changed.connect(_on_lock_changed)
	player.dialogue_requested.connect(show_dialogue)
	player.sync_stats()

func _build_ui() -> void:
	var root := Control.new()
	root.name = "Root"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var stats_panel := _panel(Vector2(24, 22), Vector2(310, 150), Color(0.02, 0.045, 0.06, 0.88))
	root.add_child(stats_panel)
	_label_into(stats_panel, "LUMAQUEST  •  GREEN FIELDS", Vector2(18, 10), Vector2(275, 26), 18, Color("#d8f2ef"))
	_health_label = _label_into(stats_panel, "♥ ♥ ♥", Vector2(18, 42), Vector2(270, 34), 28, Color("#ff5368"))
	_coin_label = _label_into(stats_panel, "Coins  023", Vector2(18, 82), Vector2(110, 24), 18, Color("#ffd35a"))
	_shard_label = _label_into(stats_panel, "Shards  000", Vector2(136, 82), Vector2(140, 24), 18, Color("#77e7ff"))
	_key_label = _label_into(stats_panel, "Keys  0", Vector2(18, 111), Vector2(100, 22), 17, Color("#f4c657"))

	var map_box := _panel(Vector2(-282, 20), Vector2(258, 150), Color(0.02, 0.045, 0.06, 0.88))
	map_box.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	map_box.position = Vector2(-282, 20)
	root.add_child(map_box)
	_label_into(map_box, "GREEN FIELDS", Vector2(16, 9), Vector2(220, 25), 20, Color("#e9f5e7"))
	_label_into(map_box, "◢  Ancient Ruins\n      ◉ Castle\n  ✦  Hidden route", Vector2(18, 42), Vector2(215, 64), 16, Color("#b7d8cf"))
	_map_position_label = _label_into(map_box, "X 0   Z 0", Vector2(16, 115), Vector2(220, 22), 15, Color("#8ec8bf"))

	_objective_label = _label_into(root, "A BRIGHTER PATH\nFind the ruin key • Open the ancient gate", Vector2(-550, 190), Vector2(520, 70), 18, Color("#f2f0db"), HORIZONTAL_ALIGNMENT_RIGHT)
	_objective_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_objective_label.position = Vector2(-550, 190)

	var controls := _panel(Vector2(-510, -64), Vector2(485, 44), Color(0.01, 0.03, 0.045, 0.85))
	controls.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	controls.position = Vector2(-510, -64)
	root.add_child(controls)
	_label_into(controls, "[J] Sword   [K] Dodge   [L] Guard   [F] Luma   [E] Interact", Vector2(12, 10), Vector2(460, 26), 15, Color("#e4ece9"))

	_lock_label = _label_into(root, "", Vector2(-150, 30), Vector2(300, 30), 18, Color("#ffe07d"), HORIZONTAL_ALIGNMENT_CENTER)
	_lock_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_lock_label.position = Vector2(-150, 28)

	_dialogue_panel = PanelContainer.new()
	_dialogue_panel.position = Vector2(48, -150)
	_dialogue_panel.size = Vector2(620, 116)
	_dialogue_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_dialogue_panel.add_theme_stylebox_override("panel", _style(Color(0.01, 0.035, 0.055, 0.94), Color("#62d8ef"), 2))
	root.add_child(_dialogue_panel)
	var dialogue_root := Control.new()
	dialogue_root.custom_minimum_size = Vector2(610, 106)
	_dialogue_panel.add_child(dialogue_root)
	_dialogue_speaker = _label_into(dialogue_root, "Luma", Vector2(20, 12), Vector2(560, 24), 18, Color("#72e5ff"))
	_dialogue_text = _label_into(dialogue_root, "", Vector2(20, 42), Vector2(565, 58), 18, Color("#f1f5f0"))
	_dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dialogue_panel.visible = false

	_inventory_panel = _big_overlay(root, "INVENTORY", "Luma Shards unlock forgotten light techniques.\n\nQuick Slots\n[1] Empty    [2] Empty    [3] Empty    [4] Empty\n\nQuest Items\nAncient keys • Region maps • Heart pieces", Vector2(660, 380))
	_map_panel = _big_overlay(root, "GREEN FIELDS — REGION MAP", "Village  ←  Start Grove  →  Ancient Ruins\n\n            ✦ Hidden Luma Crossing\n\nRiver Gorge  ─────────────  Ruin Gate\n\n                       ▲ Distant Castle\n\nExplore landmarks instead of chasing a map full of icons.", Vector2(760, 450))
	_pause_panel = _big_overlay(root, "PAUSED", "Arrow Keys  Move\nSpace  Jump     Shift  Sprint\nJ  Sword     K  Dodge     L  Guard\nQ  Lock-on     E  Interact     F  Luma\nMouse  Camera     Wheel  Zoom\n\nESC  Resume", Vector2(560, 430))

func _process(delta: float) -> void:
	if player != null and is_instance_valid(player):
		_map_position_label.text = "X %d   Z %d" % [roundi(player.global_position.x), roundi(player.global_position.z)]
	if _dialogue_timer > 0.0:
		_dialogue_timer -= delta
		if _dialogue_timer <= 0.0:
			_dialogue_panel.visible = false

	if Input.is_action_just_pressed("inventory") and not get_tree().paused:
		_inventory_panel.visible = not _inventory_panel.visible
		_map_panel.visible = false
	if Input.is_action_just_pressed("world_map") and not get_tree().paused:
		_map_panel.visible = not _map_panel.visible
		_inventory_panel.visible = false
	if Input.is_action_just_pressed("pause"):
		var paused := GameManager.toggle_pause()
		_pause_panel.visible = paused
		_inventory_panel.visible = false
		_map_panel.visible = false

func _on_health_changed(value: int, maximum: int) -> void:
	var text := ""
	for i in range(maximum):
		text += "♥ " if i < value else "♡ "
	_health_label.text = text

func _on_shards_changed(value: int) -> void:
	_shard_label.text = "Shards  %03d" % value

func _on_coins_changed(value: int) -> void:
	_coin_label.text = "Coins  %03d" % value

func _on_keys_changed(value: int) -> void:
	_key_label.text = "Keys  %d" % value
	if value > 0:
		_objective_label.text = "THE ANCIENT GATE\nCarry the ruin key to the sealed arch"

func _on_lock_changed(target: Node3D) -> void:
	if target == null:
		_lock_label.text = ""
	else:
		_lock_label.text = "◆ LOCKED ◆"

func show_dialogue(speaker: String, message: String) -> void:
	_dialogue_speaker.text = speaker
	_dialogue_text.text = message
	_dialogue_panel.visible = true
	_dialogue_timer = 5.2

func _panel(pos: Vector2, panel_size: Vector2, color: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.position = pos
	panel.size = panel_size
	panel.custom_minimum_size = panel_size
	panel.add_theme_stylebox_override("panel", _style(color, Color(0.4, 0.65, 0.65, 0.5), 1))
	return panel

func _style(color: Color, border_color: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	return style

func _label_into(parent: Control, text_value: String, pos: Vector2, label_size: Vector2, font_size: int, color: Color, align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = text_value
	label.position = pos
	label.size = label_size
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func _big_overlay(parent: Control, title: String, body: String, panel_size: Vector2) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = panel_size
	panel.size = panel_size
	panel.position = -panel_size * 0.5
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.add_theme_stylebox_override("panel", _style(Color(0.015, 0.035, 0.055, 0.97), Color("#5a9aa5"), 2))
	parent.add_child(panel)
	var inner := Control.new()
	inner.custom_minimum_size = panel_size - Vector2(20, 20)
	panel.add_child(inner)
	_label_into(inner, title, Vector2(28, 22), Vector2(panel_size.x - 56, 48), 30, Color("#f0ead5"), HORIZONTAL_ALIGNMENT_CENTER)
	var body_label := _label_into(inner, body, Vector2(40, 88), Vector2(panel_size.x - 80, panel_size.y - 120), 19, Color("#cfe2dd"), HORIZONTAL_ALIGNMENT_CENTER)
	body_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.visible = false
	return panel
