extends Node3D

var sources: Array = []

func register_source(source):
	if source not in sources:
		sources.append(source)

func unregister_source(source):
	sources.erase(source)

func _process(delta):
	var listener = ControllerManager.get_current_camera()
	if not listener:
		return

	var space_state = get_world_3d().direct_space_state

	for source in sources:
		var from_pos = source.global_transform.origin
		
		var to_pos = listener.global_transform.origin - listener.global_transform.basis.z * 0.5
		var params = PhysicsRayQueryParameters3D.new()
		params.from = from_pos
		params.to = to_pos
		params.collision_mask = source.wall_mask
		params.exclude = []

		var result = space_state.intersect_ray(params)
		#source.volume_occlusion_db = float(source.occlusion_db) if not result.is_empty() else 0.0
		var target_db = 0.0 if result.is_empty() else source.occlusion_db
		source.volume_occlusion_db = lerp(source.volume_occlusion_db, target_db, delta * 5.0)
		source.update_volume()
		# 🎨 DEBUG линия (зелёная — чистый путь, красная — есть стена)
		
		if SettingsManager.values["draw_audio_path"]:
			var color = Color.GREEN if result.is_empty() else Color.RED
			DebugDraw3D.draw_line(from_pos, to_pos, color,0.3)
