extends Node3D

@export var material : StandardMaterial3D


func _ready() -> void:
	setup_glass_pieces()
	

		
func setup_glass_pieces() -> void:
	for child in get_children():
		if child is MeshInstance3D:
			var mesh = child.mesh
			if mesh:
				# Создаём RigidBody3D
				var rb = RigidBody3D.new()
				rb.name = child.name + "_RB"
				rb.global_transform = child.global_transform
				
				# Перемещаем меш внутрь RigidBody
				child.get_parent().add_child(rb)
				child.get_parent().remove_child(child)
				rb.add_child(child)
				child.transform = Transform3D.IDENTITY  # локальные координаты
				
				# Применяем материал ко всем поверхностям
				for surface_idx in range(mesh.get_surface_count()):
					mesh.surface_set_material(surface_idx, material)
				
				# Создаём CollisionShape3D
				var col_shape = CollisionShape3D.new()
				var shape = mesh.create_convex_shape()  # Single Convex
				col_shape.shape = shape
				rb.add_child(col_shape)
				col_shape.transform = Transform3D.IDENTITY
