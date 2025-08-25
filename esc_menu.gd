extends Control
class_name EscapeMenu   # чтобы UIManager мог зарегистрировать

@onready var vbox = $VBoxContainer

# --- Цвета ---
var normal_color: Color = Color(0.2, 0.6, 1.0)
var hover_color: Color = Color(0.35, 0.7, 1.0)
var pressed_color: Color = Color(0.15, 0.45, 0.9)
var border_color: Color = Color(1,1,1,0)
var corner_radius: float = 14.0

# --- Tween параметры ---
var hover_scale: Vector2 = Vector2(1.15, 1.15)
var pressed_scale: Vector2 = Vector2(0.95, 0.95)
var anim_time: float = 0.32
@onready var ui_manager = $".."
func _ready():
	visible = false  # панели всегда стартуют скрытыми
	for btn in vbox.get_children():
		if btn is Button:
			_apply_style(btn)
			_connect_animation(btn)

	# Подключаем кнопки к действиям
	$VBoxContainer/Continue.pressed.connect(
		func(): ui_manager.close_escape_menu()
	)
	#$VBoxContainer/Restart.pressed.connect(_on_restart_pressed)
	#$VBoxContainer/Menu.pressed.connect(_on_menu_pressed)
	#$VBoxContainer/Exit.pressed.connect(_on_exit_pressed)

func _apply_style(btn: Button) -> void:
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = normal_color
	style_normal.border_color = border_color
	style_normal.corner_radius_top_left = corner_radius
	style_normal.corner_radius_top_right = corner_radius
	style_normal.corner_radius_bottom_left = corner_radius
	style_normal.corner_radius_bottom_right = corner_radius

	var style_hover = style_normal.duplicate()
	style_hover.bg_color = hover_color

	var style_pressed = style_normal.duplicate()
	style_pressed.bg_color = pressed_color

	btn.add_theme_stylebox_override("normal", style_normal)
	btn.add_theme_stylebox_override("hover", style_hover)
	btn.add_theme_stylebox_override("pressed", style_pressed)
	btn.add_theme_color_override("font_color", Color(1,1,1))

func _connect_animation(btn: Button) -> void:
	btn.mouse_entered.connect(Callable(self, "_tween_scale").bind(btn, hover_scale))
	btn.mouse_exited.connect(Callable(self, "_tween_scale").bind(btn, Vector2(1,1)))
	btn.pressed.connect(Callable(self, "_tween_scale").bind(btn, pressed_scale))
	btn.button_up.connect(Callable(self, "_tween_scale").bind(btn, hover_scale))

func _tween_scale(btn: Button, target_scale: Vector2) -> void:
	var tween = create_tween()
	tween.tween_property(btn, "scale", target_scale, anim_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# --- Кнопки ---
func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://Game.tscn")

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Menu.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
