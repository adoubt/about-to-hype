extends Node3D

@onready var mirror_cam: Camera3D = $CSGBox3D/SubViewport/Camera3D

func _process(delta):
	var current_cam = ControllerManager.get_current_camera()
	if not current_cam:
		return
	
	# Копируем FOV и прочее
	mirror_cam.fov = current_cam.fov
	mirror_cam.near = current_cam.near
	mirror_cam.far = current_cam.far
	mirror_cam.projection = current_cam.projection

	# нормаль и позиция зеркала
	var n = global_transform.basis.z.normalized() # нормаль (ось Z зеркала)
	var p = $Marker3D.global_transform.origin               # точка на плоскости

	# отражаем позицию камеры
	var cam_pos = current_cam.global_transform.origin
	var to_cam = cam_pos - p
	var mirrored_pos = cam_pos - 2.0 * to_cam.dot(n) * n

	# отражаем basis камеры
	var cam_basis = current_cam.global_transform.basis
	var mirrored_basis = Basis(
		cam_basis.x - 2.0 * cam_basis.x.dot(n) * n,
		cam_basis.y - 2.0 * cam_basis.y.dot(n) * n,
		cam_basis.z - 2.0 * cam_basis.z.dot(n) * n
	)
	mirrored_basis.x = -mirrored_basis.x

	# собираем новый трансформ
	mirror_cam.global_transform = Transform3D(mirrored_basis.orthonormalized(), mirrored_pos)
