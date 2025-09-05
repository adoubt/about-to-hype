extends Label3D

var cam = Camera3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.billboard =BaseMaterial3D.BILLBOARD_ENABLED
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible:
		cam = ControllerManager.get_active()
		look_at(cam.global_transform.origin, Vector3.UP)
