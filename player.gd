extends CharacterBody3D

@export var speed: float = 13.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.003

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var input_enabled: bool = true

@onready var head: Node3D = $Head
@onready var player_camera := $Head/Camera3D

func _ready() -> void:
	pass


func set_input_enabled(state: bool) -> void:
	input_enabled = state
	
func get_active_camera() -> Camera3D:
	return player_camera
	
func _unhandled_input(event: InputEvent) -> void:
	if not input_enabled:
		return
	# Движение мышкой
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)

		# Ограничим наклон головы, чтобы не ломался
		head.rotation_degrees.x = clamp(head.rotation_degrees.x, -80, 80)

	

func _physics_process(delta: float) -> void:
	if not input_enabled:
		return
	var direction = Vector3.ZERO
	
	# WASD
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_back"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x

	direction.y = 0
	direction = direction.normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# гравитация
	if not is_on_floor():
		velocity.y -= gravity * delta

	# прыжок
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	move_and_slide()
