extends Node

var controllables: Array = []
var current_index: int = -1  # -1 значит никто не активен

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_next"):
		switch_next() 
	elif event.is_action_pressed("drone_select"):
		_handle_object_hotkey("Base_Drone") 
	elif event.is_action_pressed("player_select"):
		_handle_object_hotkey("Player") 
	elif event.is_action_pressed("streetcam_select"):
		_handle_object_hotkey("StreetCam")


		
func _handle_object_hotkey(name: String) -> void:
	for obj_dict in controllables:
		var obj = obj_dict["node"]  # достаём Node из словаря
		if obj.name == name:
			if get_active() == obj and obj.has_method("toggle_camera"):
				obj.toggle_camera()  # только для дрона
			else:
				if get_active() == obj and obj.has_method("toggle_camera"):
					obj.toggle_camera()
				else:
					if get_active() and obj_dict["requires_input"]:  # <-- блокируем только если объект требует ввода
						get_active().set_input_enabled(false)
					current_index = controllables.find(obj_dict)
					if obj_dict["requires_input"]:
						obj.set_input_enabled(true)
					_set_camera(obj)
			break

# Регистрируем объект в менеджере
func register(obj: Node, requires_input: bool = true) -> void:
	if not controllables.any(func(c): return c["node"] == obj):
		controllables.append({
			"node": obj,
			"requires_input": requires_input
		})
		# если это первый объект — сразу активируем
		if current_index == -1 and requires_input:
			current_index = 0
			obj.set_input_enabled(true)
			_set_camera(obj)

func refresh():
	controllables = []
	current_index = -1
	
func unregister(obj: Node) -> void:
	pass
# Переключение на следующего активного игрока/дрон (по кругу)
func switch_next() -> void:
	if controllables.is_empty():
		return

	var current = controllables[current_index]
	if current["requires_input"]:
		current["node"].set_input_enabled(false)

	# ищем следующий объект, которому требуется ввод
	var next_index = current_index
	for i in range(1, controllables.size() + 1):
		var idx = (current_index + i) % controllables.size()
		if controllables[idx]["requires_input"]:
			next_index = idx
			break

	current_index = next_index
	controllables[current_index]["node"].set_input_enabled(true)
	_set_camera(controllables[current_index]["node"])

# Переключение на конкретный объект (например, уличная камера)
func switch_to(obj: Node) -> void:
	if not controllables.any(func(c): return c["node"] == obj):
		return
	_set_camera(obj)

# Включение/отключение ввода у всех объектов, которым нужен ввод
func set_all_input_enabled(enabled: bool):
	for c in controllables:
		if c["requires_input"]:
			c["node"].set_input_enabled(enabled)

# Получение активного контролируемого
func get_active() -> Node:
	if current_index >= 0 and current_index < controllables.size():
		return controllables[current_index]["node"]
	return null

func get_current_camera() -> Camera3D:
	var obj = get_active()
	if obj and obj.has_method("get_current_camera"):
		return obj.get_current_camera()
	return null
# --- Внутреннее ---
func _set_camera(obj: Node):
	if obj.has_method("get_current_camera"):
		var cam = obj.get_current_camera()
		if cam:
			cam.make_current()
			
