extends Node3D

const LAYER_ENV = 1 << 2   # слой "окружение"
const MASK_DEFAULT = 1     # маска для игрока (слой 1)

func _ready():
	set_layers_recursively(self)

func set_layers_recursively(node: Node):
	for child in node.get_children():
		if child is CSGShape3D:
			child.use_collision = true
			#child.collision_layer = LAYER_ENV
			#child.collision_mask = MASK_DEFAULT
		elif child.get_child_count() > 0:
			set_layers_recursively(child)
