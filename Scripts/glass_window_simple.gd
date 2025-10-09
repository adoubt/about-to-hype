extends Node3D

@export var broken_model: PackedScene
@export var INTENSITY: float = 0.1
@export var LIFETIME: float = 4.0
@export var active_limit :int = 82  # 💥 максимум активных кусков
@export var active_count :int = 0
@export var spread_deg := 15.0

func _on_area_3d_body_entered(body: Node) -> void:
	_break_glass(body)
	
	
func _break_glass(collider: Node) -> void:
	# Создаём экземпляр разбитого стекла
	
	
	#broken_instance.global_transform = global_transform
	var speed = 0.0
	var direction = Vector3.ZERO
	
	if "velocity" in collider:  # если дрон хранит скорость
		speed = collider.velocity.length()
		direction = collider.velocity.normalized()
	elif collider is RigidBody3D:
		speed = collider.linear_velocity.length()
		direction = collider.linear_velocity.normalized()
	else:
		speed = INTENSITY * 0.5  # запасная величина для обычных нод
		direction = (collider.global_transform.origin - self.global_transform.origin).normalized()
	
	var broken_instance: Node3D = broken_model.instantiate()
	get_parent().add_child(broken_instance)
	var pieces = broken_instance.model.get_children()
	self.queue_free()
	AudioManager.just_play_sound("glass_break", position)
	
	for rb in pieces:
		if rb is RigidBody3D:
			if active_count < active_limit:
				active_count+=1
				# Генерируем случайные небольшие углы для X и Z (Y оставляем направление движения)
				var angle_x = randf_range(-spread_deg, spread_deg)
				var angle_z = randf_range(-spread_deg, spread_deg)
				
				# Создаем копию направления и вращаем под углом
				var force_dir = direction.rotated(Vector3.RIGHT, deg_to_rad(angle_x))
				force_dir = force_dir.rotated(Vector3.FORWARD, deg_to_rad(angle_z))
				
				# Сила импульса (можно sqrt(speed) или линейно speed)
				var impulse_force = force_dir * INTENSITY * speed
				rb.apply_central_impulse(impulse_force)
			else:
				# 🧊 остальные остаются замороженными
				
				rb.sleeping = true
			
	get_tree().create_timer(LIFETIME).timeout.connect(Callable(broken_instance, "fade_and_delete"))
	
