extends Control
class_name MainMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	SceneManager.go_to_game()

func _on_settings_pressed() -> void:
	UIManager.open_settings()


func _on_exit_pressed() -> void:
	SceneManager.exit()


func _on_test_pressed() -> void:
	SceneManager.go_to_test_polygon()
