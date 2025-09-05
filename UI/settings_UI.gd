extends Control
@onready var tab_container: TabContainer = $Control/HBoxContainer/TABCustom/TabContainer
# Базовое разрешение, под которое ты верстал



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
