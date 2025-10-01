extends CharacterBody3D
class_name PlayerController

@export var speed: float = 13.0
@export var jump_velocity: float = 4.5

@onready var camera_controller_anchor: Marker3D = $CameraControllerAnchor
@onready var player_camera := $CameraController/Camera3D
@onready var right_hand: BoneAttachment3D = $rigman/Armature/GeneralSkeleton/RightHandHeld
@onready var look_at_modifier_3d: LookAtModifier3D = $rigman/Armature/GeneralSkeleton/LookAtModifier3D

@onready var default_look_at_target: Marker3D = $CameraController/DefaulLookAtTarget
var right_hand_held: HeldItem = null
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var input_enabled: bool = false



func _ready() -> void:
	ControllerManager.register(self) 
	ControllerManager._handle_object_hotkey(name) # где name = "Player"
	look_at_modifier_3d.target_node = default_look_at_target.get_path()
func _unhandled_input(event: InputEvent) -> void:
	if not input_enabled:
		return

	if Input.is_action_just_pressed("use_item") and right_hand_held:
		
		right_hand_held.use()

	if Input.is_action_just_pressed("use2_item") and right_hand_held:
		right_hand_held.use2()
		
	if Input.is_action_just_pressed("throw") and right_hand_held:
		right_hand_held.throw()	
		
func set_input_enabled(state: bool) -> void:
	input_enabled = state
	
func get_current_camera() -> Camera3D:
	return player_camera
	

func _physics_process(delta: float) -> void:
	if not input_enabled:
		return
	#if velocity.length() == 0:
		#$AnimationPlayer.play("Angry")
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
	

func equip_item(item : InventoryItem):
	if not right_hand:
		push_error("RightHandAttachment не найден!")
		return
		
	# Убираем старый HeldItem
	if right_hand.get_child_count() > 0:
		right_hand.get_child(0).queue_free()

	# Загружаем сцену из пути
	var scene_res: PackedScene = load(item.scene_item_held)
	if not scene_res:
		push_error("Не удалось загрузить сцену: %s" % item.scene_item_held)
		return
	print("scene_res loaded:", scene_res)
	# Создаём новый HeldItem
	var held_item = scene_res.instantiate() as HeldItem
	right_hand.add_child(held_item)
	#held_item.transform = right_hand.global_transform

	# Сохраняем ссылку на предмет в руке
	right_hand_held = held_item
	right_hand_held.loot_data = item
	


func _on_area_3d_body_entered(body: CharacterBody3D) -> void:
	look_at_modifier_3d.target_node = body.get_path()

	



func _on_area_3d_body_exited(body: CharacterBody3D) -> void:
	look_at_modifier_3d.target_node = default_look_at_target.get_path()
	
