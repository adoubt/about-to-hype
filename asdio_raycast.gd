extends Node3D

@onready var audio = $"../../../AudioStreamPlayer3D"

# Слой, на котором находятся стены
const WALL_MASK = 1 << 1  

# Насколько приглушать звук через стены
var occlusion_db: float = -20.0
# Скорость плавного изменения громкости
var fade_speed: float = 5.0

func _process(delta):
	var from_pos = audio.global_transform.origin
	var to_pos = global_transform.origin
	var space_state = get_world_3d().direct_space_state

	# Создаём параметры луча
	var params = PhysicsRayQueryParameters3D.new()
	params.from = from_pos
	params.to = to_pos
	params.collision_mask = WALL_MASK
	params.exclude = [audio]  # исключаем сам источник

	var result = space_state.intersect_ray(params)

	# Если луч что-то задел — приглушаем, иначе — полный звук
	var target_db = occlusion_db if result else 0.0

	# Плавное изменение громкости
	audio.volume_db = lerp(audio.volume_db, target_db, delta * fade_speed)
