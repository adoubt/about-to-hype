extends Node3D

var sources: Array = []
@onready var controller_manager = $"../ControllerManager"

func register_source(source):
	if source not in sources:
		sources.append(source)

func unregister_source(source):
	sources.erase(source)

func _process(delta):
	var listener = controller_manager.get_active()
	if not listener:
		return

	var space_state = get_world_3d().direct_space_state

	for source in sources:
		var from_pos = source.global_transform.origin
		var to_pos = listener.global_transform.origin

		var params = PhysicsRayQueryParameters3D.new()
		params.from = from_pos
		params.to = to_pos
		params.collision_mask = source.wall_mask
		params.exclude = []

		var result = space_state.intersect_ray(params)
		source.volume_occlusion_db = float(source.occlusion_db) if not result.is_empty() else 0.0

		# применяем итоговую громкость
		source.update_volume()
