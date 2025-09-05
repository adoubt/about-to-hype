extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	UIManager.open_main_menu()
	ControllerManager.refresh()
	ControllerManager.register($SubViewportContainer/SubViewport/MenuCameraFlow,false)
