extends RayCast3D

@onready var prompt = $Prompt
@export var outline_material : ShaderMaterial

var last_highlighted: MeshInstance3D = null

func _physics_process(_delta):
	prompt.text = ""

	# убираем подсветку с предыдущего объекта
	if last_highlighted:
		_remove_highlight(last_highlighted)
		last_highlighted = null

	if is_colliding():
		var collider = get_collider()
		
		if collider is Interactable:
			prompt.text = collider.get_prompt()

			# ищем в дереве collider-а MeshInstance3D (или все сразу)
			var meshes = collider.get_children()
			for child in meshes:
				if child is MeshInstance3D:
					_apply_highlight(child)
					last_highlighted = child

			# взаимодействие
			if Input.is_action_just_pressed(collider.prompt_action):
				collider.interact(owner)


func _apply_highlight(mesh: MeshInstance3D):
	if outline_material:
		mesh.set_surface_override_material(0, outline_material)


func _remove_highlight(mesh: MeshInstance3D):
	# Сбрасываем материал обратно (можно null или базовый из ресурсов)
	mesh.set_surface_override_material(0, null)
