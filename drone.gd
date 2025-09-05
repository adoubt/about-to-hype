extends CharacterBody3D


const GRAVITY := -40 # м/с², на глаз или через тесты
const MAX_FALL_SPEED := 40.0

@export var base_mass := 1.0  # масса пустого дрона
var current_mass := base_mass  # масса с учётом груза
@export var move_speed := 40.0
@export var time_to_max_speed := 2.0
@export var ascend_speed := 15.0 #правность горизонтального разгона
@export var rotation_speed := 360.0
@export var tilt_amount := 30.0 #угол наклона
@export var tilt_smoothness := 5.0 #правлность наклона
@export var vertical_smoothness := 2.0 #правлность ветикального разгона
@export var factor_stop = 0.4 #чем больше тем плавнее остановка 0.4
@onready var ui_manager = UIManager

@onready var camera_pivot = $CameraPivot
@onready var camera_pivot2 = $CameraPivot2
@onready var camera1 := $CameraPivot/Camera3D
@onready var camera2 := $CameraPivot2/Camera3D2
@onready var model = $Model
var control_yaw: float = 0.0       # мгновенный отклик мыши
var model_lag_speed: float = 5.0   # скорость плавного поворота модели (настройка)
@onready var label_hint := $"../drop/Label_Interact"
@onready var label_status := $"../HUD/GrabLabel"

@onready var grab_area := $Area3D
@onready var blade1 := $Model/Blade1pivot
@onready var blade2 := $Model/Blade2pivot
@onready var blade3 := $Model/Blade3pivot
@onready var blade4 := $Model/Blade4pivot
@onready var blade_sound := $BladeSound
@onready var flashlight: SpotLight3D = $Model/SpotLight3D
@onready var flashlight2: SpotLight3D = $Model/SpotLight3D2
@onready var front_left_flashlight:= $Model/FrontLeftFlashlight
@onready var front_right_flashlight:= $Model/FrontRightFlashlight

var camera_yaw := 0.0
@export var camera_lag := 1.7
# дистанции (отрицательная Z — камера позади pivot)
var base_distance : float    # нормальная дистанция (настроится в _ready)
@export var far_distance := 3.0   # насколько дальше отойти при max speed
@export var zoom_speed := 5.0      # скорость интерполяции дистанции

# альтернативы: изменение FOV
@export var use_fov := true
@export var base_fov : float
@export var far_fov : float
@export var drone_new_control :bool = true
@export var flight_assistant: bool = false
var volume_occlusion_db: float = 0.0 # от AudioManager
var volume_local_db: float = -30.0   # от скорости винтов
var joint: PinJoint3D = null
var current_camera_index: int = 1
var current_tilt := Vector3.ZERO
var input_dir := Vector3.ZERO
var grabbed_box: RigidBody3D = null
var is_grabbing := false
var grab_offset := Vector3(0, -0.22, 0)
var engine_enabled := false
var mouse_joystick_active := true
var mouse_delta := Vector2.ZERO
var mouse_sensitivity := 0.2
var pitch := 0.0
var default_pitch := 0.0
var blade_speed := 0.9
var moving := false
var input_enabled: bool = false
var target_volume_db := -80.0  # тихо, когда мотор выключен
var max_volume_db := 0.0       # громко, когда мотор включен
var fade_speed := 1.5          # скорость изменения громкости
var min_volume_db := -80.0
var max_pitch := 1.3
var min_pitch := 0.4
func _ready():
	grab_area.body_entered.connect(_on_grab_area_body_entered)
	grab_area.body_exited.connect(_on_grab_area_body_exited)
	label_hint.visible = false
	camera_yaw = model.rotation.y
	camera_pivot.rotation.y = camera_yaw
	base_distance = camera1.position.z
	if use_fov:
		base_fov = camera1.fov	
		far_fov = base_fov + 90



func set_input_enabled(state: bool) -> void:
	input_enabled = state
	
func toggle_camera() -> void:
	if current_camera_index == 1:
		camera2.make_current()
		current_camera_index = 2
	else:
		camera1.make_current()
		current_camera_index = 1
		
func get_current_camera() -> Camera3D:
	return camera1 if current_camera_index == 1 else camera2
		
func _input(event):
	if not input_enabled:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
		mouse_joystick_active = not mouse_joystick_active
		if mouse_joystick_active:
			pitch = model.rotation_degrees.x
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


func _rotate_camera(direction: int):
	var new_rot = camera2.rotation.x + deg_to_rad(direction * rotation_speed * get_process_delta_time())
	new_rot = clamp(new_rot, deg_to_rad(-90), deg_to_rad(45))
	camera2.rotation.x = new_rot
	
func _physics_process(delta):
	# --- Физика дрона всегда работает ---

	_apply_physics(delta)
	
	# --- Управление дроном только если input_enabled ---
	if input_enabled:
		
		_process_rotation_and_tilt(delta)
		_process_mouse_camera(delta)
		_process_interaction(delta)
		_process_engine_and_blades(delta)
	_process_movement(delta)
	# --- тут обрабатываем камеру ---
	_update_camera_follow(delta)
func _apply_physics(delta):
	
	if not engine_enabled:
		velocity.y +=GRAVITY * delta
		velocity.y = max(velocity.y, -MAX_FALL_SPEED)
		
	move_and_slide()
	

func _process_movement(delta):
	moving = false
	
	input_dir = Vector3.ZERO
	var target_velocity_y := 0.0	
	if input_enabled:
		if Input.is_action_pressed("drone_forward"):
			input_dir -= model.global_transform.basis.z
			engine_enabled = true
			moving = true
		if Input.is_action_pressed("drone_back"):
			input_dir += model.global_transform.basis.z
			engine_enabled = true
			moving = true
		if Input.is_action_pressed("drone_left"):
			input_dir -= model.global_transform.basis.x
			engine_enabled = true
			moving = true
		if Input.is_action_pressed("drone_right"):
			input_dir += model.global_transform.basis.x
			engine_enabled = true
			moving = true
		
		if Input.is_action_pressed("drone_up"):
			target_velocity_y = +ascend_speed
			engine_enabled = true
			moving = true
		if Input.is_action_pressed("drone_down"):
			target_velocity_y = -ascend_speed
			engine_enabled = true
			moving = true
		
	
	# целевые скорости
	input_dir = input_dir.normalized()
	
	var target_velocity_x = input_dir.x * move_speed
	var target_velocity_z = input_dir.z * move_speed
	
	# сглаживание
	var accel_factor = delta / time_to_max_speed
	if input_dir == Vector3.ZERO:
		accel_factor = delta / factor_stop
	var accel_factor_y =  delta / factor_stop if model.global_transform.basis.y !=Vector3.ZERO else accel_factor
	
	velocity.x = lerp(velocity.x, target_velocity_x, accel_factor)
	velocity.y = lerp(velocity.y, target_velocity_y, vertical_smoothness *delta)
	velocity.z = lerp(velocity.z, target_velocity_z, accel_factor)	
	
	
	
func _process_rotation_and_tilt(delta):
	var yaw_input = Input.get_action_strength("drone_turn_right") - Input.get_action_strength("drone_turn_left")
	if yaw_input != 0.0:
		engine_enabled = true
		moving = true
		
		# крутим только модель, а не весь дрон
		model.rotate_y(deg_to_rad(rotation_speed * yaw_input * delta))


	# наклон при движении
	var local_input = model.global_transform.basis.inverse() * input_dir
	var target_tilt_x = local_input.z * tilt_amount
	var target_tilt_z = -local_input.x * tilt_amount
	current_tilt.x = lerp(current_tilt.x, target_tilt_x, delta * tilt_smoothness)
	current_tilt.z = lerp(current_tilt.z, target_tilt_z, delta * tilt_smoothness)
	model.rotation_degrees.x = current_tilt.x
	model.rotation_degrees.z = current_tilt.z

	
func _process_mouse_camera(delta):
	if !SettingsManager.values["drone_new_control"]: 
		if mouse_joystick_active:
			rotate_object_local(Vector3.UP, -deg_to_rad(mouse_delta.x * mouse_sensitivity))
			mouse_delta = Vector2.ZERO
		else:
			rotation_degrees.x = lerp(rotation_degrees.x, default_pitch, delta * 2.0)
	# --- управляем направлением мгновенно ---
	else: 
		control_yaw += -deg_to_rad(mouse_delta.x * mouse_sensitivity)
		mouse_delta = Vector2.ZERO

		# --- визуальная модель догоняет с лагом ---
		var target_yaw = control_yaw
		model.rotation.y = lerp_angle(model.rotation.y, target_yaw, delta * model_lag_speed)
	if Input.is_action_pressed("rotate_camera_up"):
		_rotate_camera(-1)
	if Input.is_action_pressed("rotate_camera_down"):
		_rotate_camera(1)

func _process_interaction(delta):
	if Input.is_action_just_pressed("Interact") and grabbed_box:
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
	if Input.is_action_just_pressed("flashlight"):
		flashlight.visible = !flashlight.visible
		front_left_flashlight.visible = flashlight.visible
		await get_tree().create_timer(0.3).timeout
		flashlight2.visible = flashlight.visible
		front_right_flashlight.visible = flashlight2.visible
	if Input.is_action_just_pressed("drone_engine_toggle"):
		engine_enabled = not engine_enabled
	# удерживаемые объекты
	if is_grabbing and grabbed_box:
		var direction = (global_transform.origin + grab_offset) - grabbed_box.global_transform.origin
	
		grabbed_box.linear_velocity = direction * 10.0

func _process_engine_and_blades(delta):
	# --- вращение лопастей ---
	var target_blade_speed = 3000.0 if engine_enabled else 0.0
	blade_speed = lerp(blade_speed, target_blade_speed, delta * 5.0)
	var rotation_amount = deg_to_rad(blade_speed * delta)
	blade1.rotate_y(rotation_amount)
	blade2.rotate_y(rotation_amount)
	blade3.rotate_y(rotation_amount)
	blade4.rotate_y(rotation_amount)

	# --- запуск звука ---
	if engine_enabled and not blade_sound.playing:
		blade_sound.play()

	# --- локальная громкость ---
	var target_local_db = max_volume_db if moving else (-30.0 if engine_enabled else min_volume_db)
	blade_sound.volume_local_db = lerp(blade_sound.volume_local_db, target_local_db, delta * fade_speed)

	# --- локальный питч ---
	var target_pitch = (max_pitch if moving else 0.7) if engine_enabled else min_pitch
	blade_sound.pitch_scale = lerp(blade_sound.pitch_scale, target_pitch, delta * fade_speed)

	# --- применяем итоговую громкость (локальная + occlusion) ---
	#blade_sound.volume_db = volume_local_db + volume_occlusion_db

	# --- остановка звука ---
	if not engine_enabled and blade_sound.volume_db <= min_volume_db + 1.0 and blade_sound.playing:
		blade_sound.stop()

func _update_camera_follow(delta):
	# --- лаг поворота (как было) ---
	if current_camera_index == 2:
		camera_pivot2.rotation.y = model.rotation.y
	else:
		var target_yaw = model.rotation.y
		camera_yaw = lerp_angle(camera_yaw, target_yaw, delta * camera_lag)
		camera_pivot.rotation.y = camera_yaw

		# --- вычисляем нормализованную скорость (0..1) по горизонтали ---
		var horiz_speed = Vector3(velocity.x, velocity.y, velocity.z).length()
		var t = clamp(horiz_speed / move_speed, 0.0, 1.0)

		if use_fov:
			# плавно меняем FOV (альтернатива, безопаснее — не клипает)
			var target_fov = lerp(base_fov, far_fov, t)
			camera1.fov = lerp(camera1.fov, target_fov, delta * zoom_speed)
		else:
			# отдаляем камеру по Z (чем быстрее — тем дальше)
			var target_dist = lerp(base_distance, far_distance, t)
			var cur_z = camera1.position.z   # вместо translation.z
			cur_z = lerp(cur_z, target_dist, delta * zoom_speed)

			var pos = camera1.position
			pos.z = cur_z
			camera1.position = pos
