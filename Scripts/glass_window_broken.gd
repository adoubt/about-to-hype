extends Node3D

@export var shader_material : ShaderMaterial 
@onready var glass_sound: AudioStreamPlayer3D = $GlassSound
@onready var model: Node3D = $Model
func _ready() -> void:
	setup_glass_pieces()
	

		
func setup_glass_pieces() -> void:
	for child in model.get_children():
		if child is MeshInstance3D:
			# Назначаем шейдерный материал сразу
			var mat_instance = shader_material.duplicate() as ShaderMaterial
			child.material_override = mat_instance

			var mesh = child.mesh
			if mesh:
				# Создаём RigidBody3D
				var rb = RigidBody3D.new()
				rb.name = child.name + "_RB"
				rb.global_transform = child.transform
				rb.collision_layer = 1 << 4
				# Перемещаем меш внутрь RigidBody
				child.get_parent().add_child(rb)
				child.get_parent().remove_child(child)
				rb.add_child(child)
				child.transform = Transform3D.IDENTITY

				## Создаём коллизию
				var col_shape = CollisionShape3D.new()
				var shape = mesh.create_convex_shape()
				col_shape.shape = shape
				rb.add_child(col_shape)
				col_shape.transform = Transform3D.IDENTITY



func fade_and_delete():
	for rb in model.get_children():
		if rb is RigidBody3D:
			var mesh = null
			for c in rb.get_children():
				if c is MeshInstance3D:
					mesh = c
					break
			if mesh and mesh.material_override is ShaderMaterial:
				var mat: ShaderMaterial = mesh.material_override
				var tween = get_tree().create_tween()
				tween.tween_property(mat, "shader_parameter/dissolveSlider", 1.5, 5.0)
				tween.tween_callback(Callable(rb, "queue_free"))
