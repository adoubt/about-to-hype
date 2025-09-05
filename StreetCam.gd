extends Node3D
var input_enabled: bool = true
@onready var street_camera := $Camera3 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func set_input_enabled(state: bool) -> void:
	input_enabled = state

		
func get_current_camera() -> Camera3D:
	return street_camera
