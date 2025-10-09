extends Node3D

const LAYER_ENV = 1 << 2   # слой "окружение"
const MASK_DEFAULT = 1     # маска для игрока (слой 1)
const GLASS_WINDOW = preload("uid://bitej6opd7qbd")

const GLASS_WINDOW_SIMPLE = preload("uid://bui502wsoub")
@export var mat : Material

func _ready():
	set_layers_recursively(self)
	setup_windows(self)
	set_material_recursively(self)
	
	
func set_layers_recursively(node: Node):
	for child in node.get_children():
		if child is CSGShape3D:
			child.use_collision = true
			#child.collision_layer = LAYER_ENV
			#child.collision_mask = MASK_DEFAULT
		elif child.get_child_count() > 0:
			set_layers_recursively(child)
		
func set_material_recursively(node: Node):
	for child in node.get_children():
		if child is CSGShape3D:
			child.material = mat
		elif child.get_child_count() > 0:
			set_material_recursively(child)	
			
func setup_windows(node: Node):
	# Рекурсивно проходим все дочерние ноды здания
	for child in node.get_children():
		if child is CSGShape3D and "window" in child.name.to_lower():
			# Клонируем стекло
			
			#print("+стекло")
			# Добавляем стекло в тот же родитель, что и окно
			fit_glass_to_window(child)
		setup_windows(child)
		
func fit_glass_to_window(csg_box: CSGBox3D):
	# Создаём стекло
	var glass_instance = GLASS_WINDOW.instantiate()
	#print("+стекло")
	csg_box.add_child(glass_instance)  # временно в иерархии окна


	# Вычисляем фактический размер окна в мире

	var box_size : Vector3
	box_size.x = csg_box.size.x * csg_box.scale.x
	
	box_size.y = csg_box.size.y * csg_box.scale.y
	box_size.z = csg_box.size.z * csg_box.scale.z
	# Устанавливаем стекло в центр рамки
	#glass_instance.global_transform.origin = box_transform.origin
	glass_instance.rotation_degrees.y = 90
	#print(csg_box.get_parent().get_parent().name)
	if "Room" in csg_box.get_parent().get_parent().name :
		glass_instance.scale = Vector3(0.25,0.5,0.25)
	if "Room2" in csg_box.get_parent().get_parent().name :
		
		glass_instance.scale = Vector3(0.25,0.5,0.45)
	
