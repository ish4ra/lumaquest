extends Node

signal pause_changed(paused: bool)

const SAVE_PATH := "user://lumaquest_save_v1.json"

var input_ready := false

func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_configure_input()

func _configure_input() -> void:
	if input_ready:
		return
	input_ready = true
	_add_key_action("move_forward", KEY_UP, 11)
	_add_key_action("move_backward", KEY_DOWN, 12)
	_add_key_action("move_left", KEY_LEFT, 13)
	_add_key_action("move_right", KEY_RIGHT, 14)
	_add_key_action("jump", KEY_SPACE, 0)
	_add_key_action("sprint", KEY_SHIFT, 7)
	_add_key_action("crouch", KEY_C, -1)
	_add_key_action("attack", KEY_J, 1)
	_add_key_action("dodge", KEY_K, 0)
	_add_key_action("guard", KEY_L, 9)
	_add_key_action("lock_on", KEY_Q, 10)
	_add_key_action("interact", KEY_E, 2)
	_add_key_action("luma", KEY_F, 3)
	_add_key_action("item", KEY_R, 4)
	_add_key_action("inventory", KEY_TAB, 6)
	_add_key_action("world_map", KEY_M, -1)
	_add_key_action("pause", KEY_ESCAPE, 6)

func _add_key_action(action: StringName, keycode: Key, joy_button: int = -1) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var key := InputEventKey.new()
	key.physical_keycode = keycode
	if not _has_matching_event(action, key):
		InputMap.action_add_event(action, key)
	if joy_button >= 0:
		var joy := InputEventJoypadButton.new()
		joy.button_index = joy_button
		if not _has_matching_event(action, joy):
			InputMap.action_add_event(action, joy)

func _has_matching_event(action: StringName, event: InputEvent) -> bool:
	for existing in InputMap.action_get_events(action):
		if existing.as_text() == event.as_text():
			return true
	return false

func toggle_pause() -> bool:
	get_tree().paused = not get_tree().paused
	pause_changed.emit(get_tree().paused)
	if get_tree().paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	return get_tree().paused

func save_player(player: Node) -> void:
	if player == null:
		return
	var data := {
		"version": 1,
		"position": [player.global_position.x, player.global_position.y, player.global_position.z],
		"health": player.health,
		"max_health": player.max_health,
		"shards": player.shards,
		"coins": player.coins,
		"keys": player.keys
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))

func load_player(player: Node) -> bool:
	if player == null or not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	if int(parsed.get("version", 0)) != 1:
		return false
	var p = parsed.get("position", [])
	if p is Array and p.size() == 3:
		player.global_position = Vector3(float(p[0]), float(p[1]), float(p[2]))
	player.max_health = int(parsed.get("max_health", player.max_health))
	player.health = clampi(int(parsed.get("health", player.max_health)), 1, player.max_health)
	player.shards = int(parsed.get("shards", 0))
	player.coins = int(parsed.get("coins", 0))
	player.keys = int(parsed.get("keys", 0))
	player.sync_stats()
	return true

func new_game() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
