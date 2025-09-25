extends Node3D
var input_enabled: bool = false
@onready var street_camera :=  $Camera

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ControllerManager.register(self, false) 


func set_input_enabled(state: bool) -> void:

	input_enabled = state

		
func get_current_camera() -> Camera3D:
	return street_camera
