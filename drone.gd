extends CharacterBody3D

@export var move_speed: float = 2.0
@export var ascend_speed: float = 1.0
@export var rotation_speed: float = 100.0 # градусов в секунду
@export var tilt_amount: float = 20.0     # Макс угол наклона
@export var tilt_smoothness: float = 5.0  # Скорость интерполяции наклона

@onready var camera1: Camera3D = $CameraMount/Camera3D
@onready var camera2: Camera3D = $CameraMount/Camera3D2
var camera_rotation_speed := 30.0  # скорость поворота в градусах
var min_angle := deg_to_rad(-90)
var max_angle := deg_to_rad(45)
@onready var label_hint: Label3D = $"../drop/Label_Interact"
@onready var label_status: Label = $"../label2"
#наклон
var current_tilt := Vector3.ZERO

var joint: PinJoint3D = null
#захват
@onready var grab_area = $Area3D
var grabbed_box: RigidBody3D = null
var is_grabbing := false
var grab_offset = Vector3(0, -0.5, 0) # положение коробки относительно дрона

#@onready var blade1 = $Model/blade1
#@onready var blade2 = $Model/blade2
#@onready var blade3 = $Model/blade3
#@onready var blade4 = $Model/blade4


func _ready():
	grab_area.body_entered.connect(_on_grab_area_body_entered)
	grab_area.body_exited.connect(_on_grab_area_body_exited)
	label_hint.visible = false
	label_status.visible = false

func _on_grab_area_body_entered(body):
	print('1')
	if body.is_in_group("grabbable") and not is_grabbing:
		print('2')
		grabbed_box = body
		label_hint.visible = true

func _on_grab_area_body_exited(body):
	print('3')
	if body == grabbed_box and not is_grabbing:
		print('4')
		grabbed_box = null
		label_hint.visible = false
	
func _physics_process(delta):
	var input_dir = Vector3.ZERO

	# Движение в локальных осях
	if Input.is_action_pressed("drone_forward"):
		input_dir -= transform.basis.z
	if Input.is_action_pressed("drone_back"):
		input_dir += transform.basis.z
	if Input.is_action_pressed("drone_left"):
		input_dir -= transform.basis.x
	if Input.is_action_pressed("drone_right"):
		input_dir += transform.basis.x

	input_dir = input_dir.normalized()

	# Горизонтальная скорость
	velocity.x = input_dir.x * move_speed
	velocity.z = input_dir.z * move_speed

	# Вертикальное движение
	if Input.is_action_pressed("drone_up"):
		velocity.y = ascend_speed
	elif Input.is_action_pressed("drone_down"):
		velocity.y = -ascend_speed
	else:
		velocity.y = 0.0

	move_and_slide()

	# Вращение дрона вокруг собственной оси Y (локально)
	var yaw_input := Input.get_action_strength("drone_turn_right") - Input.get_action_strength("drone_turn_left")
	if yaw_input != 0.0:
		var rotation_amount = rotation_speed * yaw_input * delta
		rotate_object_local(Vector3.UP, deg_to_rad(rotation_amount))

	# === НАКЛОНЫ ===
	# input_dir пока в мировых координатах, переведём его в локальные:
	var local_input = global_transform.basis.inverse() * input_dir

	# Получаем нужный наклон
	var target_tilt_x = local_input.z * tilt_amount  # Вперёд/назад => наклон по X
	var target_tilt_z = -local_input.x * tilt_amount # Влево/вправо => наклон по Z

	# Плавная интерполяция
	current_tilt.x = lerp(current_tilt.x, target_tilt_x, delta * tilt_smoothness)
	current_tilt.z = lerp(current_tilt.z, target_tilt_z, delta * tilt_smoothness)

	# Применяем наклоны
	rotation_degrees.x = current_tilt.x
	rotation_degrees.z = current_tilt.z
	if is_grabbing and grabbed_box:
		var target_pos = global_transform.origin + grab_offset
		# Перемещаем коробку плавно
		var direction = target_pos - grabbed_box.global_transform.origin
		grabbed_box.linear_velocity = direction * 10.0  # сила притяжения
	
func _process(_delta):
	if Input.is_action_just_pressed("drone_camera_switch"):
		if camera1.current:
			camera2.make_current()
		else:
			camera1.make_current()
	if Input.is_action_pressed("rotate_camera_up"):
		_rotate_camera(-1)
	if Input.is_action_pressed("rotate_camera_down"):
		_rotate_camera(1)	
	if Input.is_action_just_pressed("grab") and grabbed_box:
		is_grabbing = not is_grabbing

		if is_grabbing:
			label_hint.visible = false
			label_status.visible = true
			label_status.text = "Grabbed: %s" % grabbed_box.name

			joint = PinJoint3D.new()
			joint.node_a = get_path()
			joint.node_b = grabbed_box.get_path()
			joint.position = grabbed_box.global_transform.origin
			add_child(joint)
		else:
			label_status.visible = false
			if joint:
				joint.queue_free()
				joint = null
			grabbed_box = null
func _rotate_camera(direction: int):
	var new_rot = camera2.rotation.x + deg_to_rad(direction * rotation_speed * get_process_delta_time())
	new_rot = clamp(new_rot, min_angle, max_angle)
	camera2.rotation.x = new_rot
