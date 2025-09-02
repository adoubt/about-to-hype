extends MeshInstance3D


# Panel3D.gd на MeshInstance3D
@onready var viewport = $"../../OrderScreenViewport"

func _ready():
	var mat = StandardMaterial3D.new()
	mat.albedo_texture = viewport.get_texture()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	self.material_override = mat
