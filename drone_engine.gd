extends CharacterBody3D

@export var move_speed := 20.0
@export var time_to_max_speed := 2.0
@export var ascend_speed := 10.0
@export var rotation_speed := 220.0
@export var tilt_amount := 40.0
@export var tilt_smoothness := 5.0
@export var vertical_smoothness := 5.0

@onready var camera1 := $CameraMount/Camera3D
@onready var camera2 := $CameraMount/Camera3D2
@onready var label_hint := $"../drop/Label_Interact"
@onready var label_status := $"../label2"
@onready var grab_area := $Area3D
@onready var blade1 := $Model/Blade1pivot
@onready var blade2 := $Model/Blade2pivot
@onready var blade3 := $Model/Blade3pivot
@onready var blade4 := $Model/Blade4pivot

var joint: PinJoint3D = null
var current_tilt := Vector3.ZERO
var grabbed_box: RigidBody3D = null
var is_grabbing := false
var grab_offset := Vector3(0, -0.5, 0)
var engine_enabled := true
var mouse_joystick_active := false
var mouse_delta := Vector2.ZERO
var mouse_sensitivity := 0.2
var pitch := 0.0
var pitch_limit := 45.0
var default_pitch := 0.0
var blade_speed := 0.0

func _ready():
	grab_area.body_entered.connect(_on_grab_area_body_entered)
	grab_area.body_exited.connect(_on_grab_area_body_exited)
	label_hint.visible = false
	label_status.visible = false

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
		mouse_joystick_active = not mouse_joystick_active
		if mouse_joystick_active:
			pitch = $Model.rotation_degrees.x
	elif event is InputEventMouseMotion and mouse_joystick_active:
		mouse_delta = event.relative

func _on_grab_area_body_entered(body):
	if body.is_in_group("grabbable") and not is_grabbing:
		grabbed_box = body
		label_hint.visible = true

func _on_grab_area_body_exited(body):
	if body == grabbed_box and not is_grabbing:
		grabbed_box = null
		label_hint.visible = false

func _physics_process(delta):
	var input_dir := Vector3.ZERO
	if Input.is_action_pressed("drone_forward"):
		input_dir -= transform.basis.z
		engine_enabled = true
	if Input.is_action_pressed("drone_back"):
		input_dir += transform.basis.z
		engine_enabled = true
	if Input.is_action_pressed("drone_left"):
		input_dir -= transform.basis.x
		engine_enabled = true
	if Input.is_action_pressed("drone_right"):
		input_dir += transform.basis.x
		engine_enabled = true

	input_dir = input_dir.normalized()
	var target_velocity_x = input_dir.x * move_speed
	var target_velocity_z = input_dir.z * move_speed
	var accel_factor = delta / time_to_max_speed
	velocity.x = lerp(velocity.x, target_velocity_x, accel_factor)
	velocity.z = lerp(velocity.z, target_velocity_z, accel_factor)

	var target_y := 0.0
	if Input.is_action_pressed("drone_up"):
		engine_enabled = true
		target_y = ascend_speed
	elif Input.is_action_pressed("drone_down"):
		engine_enabled = true
		target_y = -ascend_speed
	elif not engine_enabled:
		target_y = -9.8
	velocity.y = lerp(velocity.y, target_y, vertical_smoothness * delta)
	move_and_slide()

	var yaw_input := Input.get_action_strength("drone_turn_right") - Input.get_action_strength("drone_turn_left")
	if yaw_input != 0.0:
		rotate_object_local(Vector3.UP, deg_to_rad(rotation_speed * yaw_input * delta))

	var local_input = global_transform.basis.inverse() * input_dir
	var target_tilt_x = local_input.z * tilt_amount
	var target_tilt_z = -local_input.x * tilt_amount
	current_tilt.x = lerp(current_tilt.x, target_tilt_x, delta * tilt_smoothness)
	current_tilt.z = lerp(current_tilt.z, target_tilt_z, delta * tilt_smoothness)
	$Model.rotation_degrees.x = current_tilt.x
	$Model.rotation_degrees.z = current_tilt.z

	if is_grabbing and grabbed_box:
		var direction = (global_transform.origin + grab_offset) - grabbed_box.global_transform.origin
		grabbed_box.linear_velocity = direction * 10.0

func _process(delta):
	if Input.is_action_just_pressed("drone_camera_switch"):
		if camera1.current:
			camera2.make_current()
		else:
			camera1.make_current()

	if mouse_joystick_active:
		rotate_object_local(Vector3.UP, -deg_to_rad(mouse_delta.x * mouse_sensitivity))
		mouse_delta = Vector2.ZERO
	else:
		rotation_degrees.x = lerp(rotation_degrees.x, default_pitch, delta * 2.0)

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
			var joint = PinJoint3D.new()
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

	if Input.is_action_just_pressed("drone_engine_toggle"):
		engine_enabled = not engine_enabled

	var target_blade_speed = 3000.0 if engine_enabled else 0.0
	blade_speed = lerp(blade_speed, target_blade_speed, delta * 5.0)
	var rotation_amount = deg_to_rad(blade_speed * delta)
	blade1.rotate_y(rotation_amount)
	blade2.rotate_y(rotation_amount)
	blade3.rotate_y(rotation_amount)
	blade4.rotate_y(rotation_amount)

func _rotate_camera(direction: int):
	var new_rot = camera2.rotation.x + deg_to_rad(direction * rotation_speed * get_process_delta_time())
	new_rot = clamp(new_rot, deg_to_rad(-90), deg_to_rad(45))
	camera2.rotation.x = new_rot
