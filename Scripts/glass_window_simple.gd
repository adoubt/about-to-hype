extends Node3D

@export var broken_model: PackedScene
@export var INTENSITY: float = 100.0


func _on_area_3d_body_entered(body: Node) -> void:
	# Проверяем, что объект принадлежит группе "drone"
	if body.is_in_group("drone"):
		print("Это дрон, стекло ломается")
		_break_glass(body)

func _break_glass(collider: Node) -> void:
	# Создаём экземпляр разбитого стекла
	var broken_instance = broken_model.instantiate()
	get_parent().add_child(broken_instance)
	broken_instance.global_transform = self.global_transform
	self.queue_free()
	
	# Определяем направление движения дрона
	var direction = Vector3.ZERO
	if "velocity" in collider:  # если дрон хранит скорость
		direction = collider.velocity.normalized()
	elif collider is RigidBody3D:
		direction = collider.linear_velocity.normalized()
	else:
		direction = (collider.global_transform.origin - self.global_transform.origin).normalized()
	
	# Перебираем все куски разбитого стекла
	for child in broken_instance.get_children():
		if child is RigidBody3D:
			
				
			# Применяем импульс в направлении дрона с небольшим рандомом
			var random_offset = Vector3(randf()-0.5, randf()*0.2, randf()-0.5) * 0.1
			var force = (direction + random_offset).normalized() * INTENSITY
			child.apply_central_impulse(force)
