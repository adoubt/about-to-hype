extends Interactable
class_name Loot

@export var item: InventoryItem
@export var particles_scene: PackedScene
@export var particles_delay: float = 2.0

@export var loot_sound: AudioStream
@export var loot_unit_size: float = 15.0
@export var loot_max_distance: float = 50.0
@export var loot_volume: float = -10.0
@export var rigid_body : RigidBody3D 
@export var velocity_threshold: float = 0.5
@export var ground_check_distance: float = 0.6
@export var fade_in_time: float = 2.0  # секунда fade-in
var fx: Node3D = null
var audio_player: AudioStreamPlayer3D = null

var landed: bool = false
var effects_started: bool = false


func _ready() -> void:
	set_physics_process(true)
	


func _physics_process(_delta: float) -> void:
	if effects_started:
		_update_effects_position()
		return

	# уже приземлились → запускаем эффекты
	if landed and not effects_started:
		start_effects()
		return

	# проверка состояния rigidbody
	if self.sleeping:
		_on_landed()
		return

	if self.linear_velocity.length() <= velocity_threshold:
		var from_pos = global_position
		var to_pos = from_pos + Vector3.DOWN * ground_check_distance

		var space = get_world_3d().direct_space_state
		var params = PhysicsRayQueryParameters3D.new()
		params.from = from_pos
		params.to = to_pos
		params.exclude = [self]

		var result = space.intersect_ray(params)
		if result:
			_on_landed()


func _on_landed() -> void:
	if landed:
		return
	landed = true
	start_effects()


func start_effects() -> void:
	if effects_started:
		return
	effects_started = true

	await get_tree().create_timer(particles_delay).timeout
	if not is_instance_valid(self):
		return

	_spawn_particles()
	_setup_audio()
	_update_effects_position()
	set_physics_process(false) # дальше проверки не нужны


func _spawn_particles() -> void:
	if not particles_scene:
		return
	fx = particles_scene.instantiate()
	fx.global_position = global_position
	get_tree().current_scene.add_child(fx)


func _setup_audio() -> void:
	if not loot_sound:
		return

	audio_player = AudioStreamPlayer3D.new()
	if loot_sound is AudioStreamOggVorbis:
		loot_sound.loop = true
	elif loot_sound is AudioStreamWAV:
		loot_sound.loop_mode = AudioStreamWAV.LOOP_FORWARD

	audio_player.stream = loot_sound
	audio_player.unit_size = loot_unit_size
	audio_player.max_distance = loot_max_distance
	audio_player.volume_db = -80  # стартуем с тишины
	audio_player.autoplay = true
	add_child(audio_player)
	audio_player.play()

	# Fade-in через встроенный Tween Godot 4
	var tween = create_tween()
	tween.tween_property(audio_player, "volume_db", loot_volume, 1.0).set_trans(Tween.TRANS_LINEAR)



func _update_effects_position() -> void:
	if fx and is_instance_valid(fx):
		fx.global_position = global_position
	if audio_player and is_instance_valid(audio_player):
		audio_player.global_position = global_position


func _on_interacted(body: Node) -> void:
	var hud = get_tree().get_root().get_node("game/HUDManager")
	if hud:
		hud.add_item_to_inventory(item, 0)
	if body and body.has_method("equip_item"):
		body.equip_item(item)

	if fx and is_instance_valid(fx):
		fx.queue_free()

	if audio_player and is_instance_valid(audio_player):
		var tween = create_tween()
		# плавный fade-out до -80 дБ за 0.5 секунды
		tween.tween_property(audio_player, "volume_db", -80.0, 0.5)
		tween.tween_callback(Callable(audio_player, "queue_free"))

	queue_free()
