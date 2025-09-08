extends Control
@onready var tab_container: TabContainer = $Control/HBoxContainer/TABCustom/TabContainer
# Базовое разрешение, под которое ты верстал


func _ready() -> void:
	_apply_settings(self)
	
func _apply_settings(node: Node) -> void:
	# Проверяем у текущей ноды
	if "setting_key" in node:
		var key: String = node.setting_key
		if key != null and key != "":
			if SettingsManager.has_value(key):
				node.set("setting_value", SettingsManager.get_value(key))
	
	# Рекурсивно обходим детей
	for child in node.get_children():
		if child is Node:
			_apply_settings(child)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_pressed() -> void:
	
	UIManager.close_settings()


func _on_general_pressed() -> void:
	tab_container.set_current_tab(0)


func _on_accessibility_pressed() -> void:
	tab_container.set_current_tab(1)


func _on_graphics_pressed() -> void:
	tab_container.set_current_tab(2)


func _on_audio_pressed() -> void:
	tab_container.set_current_tab(3)


func _on_debug_pressed() -> void:
	tab_container.set_current_tab(4)


func _on_option_button_item_selected(index: int) -> void:
	pass # Replace with function body.
