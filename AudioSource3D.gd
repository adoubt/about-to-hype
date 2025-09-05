
extends AudioStreamPlayer3D


@export var wall_mask: int = 1 << 0
@export var occlusion_db: float = -20.0
@export var fade_speed: float = 5.0
var volume_local_db: float = 0.0       # управляется локально (движение, скорость)
var volume_occlusion_db: float =  0.0  # управляется AudioManager
func _ready():
	AudioManager.register_source(self)

func _exit_tree():
	AudioManager.unregister_source(self)
func update_volume():
	# итоговая громкость = локальная + occlusion
	volume_db = volume_local_db + volume_occlusion_db
