extends Node
# Автозагруженный Singleton

# ========== PANELS ==========
@onready var escape_menu  = preload("res://UI/esc_menu.tscn").instantiate()
@onready var settings_menu = preload("res://UI/Settings.tscn").instantiate()
@onready var wallet_usdt   = preload("res://UI/wallet_usdt.tscn").instantiate()
@onready var shop          = preload("res://UI/shop.tscn").instantiate()
@onready var main_menu     = preload("res://UI/main_menu.tscn").instantiate()

var panels: Dictionary = {}
var force_cursor_visible: bool = false
var last_mouse_state: bool = false
const BASE_RESOLUTION := Vector2(1152, 648)

# ========== PUBLIC API ==========
func open_wallet_usdt() -> void:
	open_panel("Wallet_USDT")
func close_wallet_usdt() -> void:
	close_panel("Wallet_USDT")
func open_main_menu() -> void:
	open_panel("MainMenu")

func toggle_escape_menu() -> void:
	if escape_menu.visible:
		close_escape_menu()
	else:
		open_escape_menu()

func open_settings() -> void:
	var in_main_menu := SceneManager.current_scene_name == "MainMenu"
	open_panel("Settings")
	if in_main_menu:
		close_panel("MainMenu")
	else:
		close_panel("EscapeMenu")

func close_settings() -> void:
	var in_main_menu := SceneManager.current_scene_name == "MainMenu"
	if in_main_menu:
		open_main_menu()
	else:
		open_escape_menu()
	close_panel("Settings")
	
func open_escape_menu() -> void:
	open_panel("EscapeMenu")

func close_escape_menu() -> void:
	close_panel("EscapeMenu")

func open_panel(name: String) -> void:
	if panels.has(name):
		var panel = panels[name]
		panel.visible = true
		if panel.has_method("refresh"):
			panel.refresh()
		_update_ui_state()

func close_panel(name: String) -> void:
	if panels.has(name):
		panels[name].visible = false
		_update_ui_state()

func close_all() -> void:
	for p in panels.values():
		p.visible = false
	_update_ui_state()


# ========== INTERNAL ==========
func _ready() -> void:
	var canvas = CanvasLayer.new()
	add_child(canvas)

	canvas.add_child(escape_menu)
	canvas.add_child(main_menu)
	canvas.add_child(settings_menu)
	canvas.add_child(wallet_usdt)
	canvas.add_child(shop)

	panels = {
		"EscapeMenu": escape_menu,
		"MainMenu": main_menu,
		"Settings": settings_menu,
		"Wallet_USDT": wallet_usdt,
		"Shop": shop
	}

	close_all()
	scale_margins_for_resolution()  # стартовая подгонка
	#connect("resized", Callable(self, "_on_resize"))  # если Control
	get_viewport().connect("size_changed", Callable(self, "_on_resize"))
func _update_ui_state() -> void:
	var open := _any_ui_open() or force_cursor_visible
	ControllerManager.set_all_input_enabled(not open)
	_show_mouse(open)

func _any_ui_open() -> bool:
	for p in panels.values():
		if p.visible:
			return true
	return false

func _show_mouse(visible: bool) -> void:
	if visible == last_mouse_state:
		return
	last_mouse_state = visible
	Input.set_mouse_mode(
		Input.MOUSE_MODE_VISIBLE if visible else Input.MOUSE_MODE_CAPTURED
	)



func _on_resize():
	scale_margins_for_resolution()

func scale_margins_for_resolution():
	var current_res = get_viewport().get_visible_rect().size
	# коэффициенты по X и Y (берём среднее, чтобы сохранять пропорции)
	var scale_x = current_res.x / BASE_RESOLUTION.x
	var scale_y = current_res.y / BASE_RESOLUTION.y
	var scale = (scale_x + scale_y) / 2.0

	_apply_margin_scaling(self, scale)


func _apply_margin_scaling(node: Node, scale: float):
	# Если это MarginContainer, меняем его Constants
	if node is MarginContainer:
		for side in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
			if node.has_theme_constant_override(side):
				var value = node.get_theme_constant(side)
				node.add_theme_constant_override(side, int(value * scale))
	# Рекурсивно обходим детей
	for child in node.get_children():
		if child is Control:
			_apply_margin_scaling(child, scale)
