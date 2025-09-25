extends Node3D

@onready var camera := $Camera3D
var input_enabled :=false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_input_enabled(state: bool) -> void:
	input_enabled = state
# Called every frame. 'delta' is the elapsed time since the previous frame.

	
func get_current_camera() -> Camera3D:
	return camera
