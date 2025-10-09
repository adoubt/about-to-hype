extends Node3D

@export var shader_material: ShaderMaterial
#@export var run_setup := false:
	#set(value):
		#if value:
			#setup_glass_pieces()
			#run_setup = false

@onready var model: Node3D = $Model


#func setup_glass_pieces() -> void:
	#if not model:
		#push_error("❌ Не найден узел Model")
		#return
#
	#var editor_root = get_tree().edited_scene_root
	#if not editor_root:
		#push_warning("⚠️ Нет edited_scene_root (возможно, не в редакторе?)")
		#return
#
	#print("⚙️ setup_glass_pieces() запущен — найдено %d детей" % model.get_child_count())
#
	##if has_node("Shards_Rigids"):
		##get_node("Shards_Rigids").queue_free()
#
	#var container := Node3D.new()
	#container.name = "Model"
	#add_child(container)
	#container.set_owner(editor_root)
#
	#for child in model.get_children():
		#if child is MeshInstance3D and child.mesh:
			#var mesh: Mesh = child.mesh
#
			#var rb := RigidBody3D.new()
			#rb.mass = 0.1
			#rb.name = child.name + "_RB"
			#rb.collision_layer = 1 << 5
			#rb.collision_mask = (1 << 0) | (1 << 4) 
			#container.add_child(rb)
			#rb.set_owner(editor_root)
			#rb.global_transform = child.global_transform
#
			#var shape := mesh.create_convex_shape()
			#var col := CollisionShape3D.new()
			#col.shape = shape
			#rb.add_child(col)
			#col.set_owner(editor_root)
			#
			#var mesh_copy := child.duplicate(false) as MeshInstance3D
			## ❗ здесь просто ссылка на материал, без дубликатов
			#if shader_material:
				#mesh_copy.material_override = shader_material
#
			#rb.add_child(mesh_copy)
			#mesh_copy.set_owner(editor_root)
			#mesh_copy.transform = transform
#
	#print("✅ setup_glass_pieces() завершён — Shards_Rigids сохранён (Ctrl+S теперь сохранит всё)")


func fade_and_delete():
	if not model:
		push_error("❌ Не найден узел Model")
		return

	if not shader_material:
		push_warning("⚠️ shader_material не задан в инспекторе!")
		return

	# Создаём только один дубликат, чтобы анимация не трогала оригинал
	var shared_mat: ShaderMaterial = shader_material.duplicate(true)

	# Назначаем его всем мешам внутри ригидов
	for rb in model.get_children():
		if rb is RigidBody3D:
			for c in rb.get_children():
				if c is MeshInstance3D:
					c.material_override = shared_mat

	# Анимируем dissolve для общего материала
	var tween = get_tree().create_tween()
	tween.tween_property(shared_mat, "shader_parameter/dissolveSlider", 1.5, 5.0)
	tween.tween_callback(Callable(self, "queue_free"))
