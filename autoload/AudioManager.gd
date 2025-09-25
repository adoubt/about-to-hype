extends Node3D
# Синглтон
@export var audio_source_script_path: String = "uid://wxb573o058my"
# Все источники
var dynamic_sources: Array = []        # создаются и удаляются автоматически
var persistent_sources: Dictionary = {
	"loot_dust" : "uid://dca1cajfu4p1s"
} # музыка, постоянные объекты


# Максимальная слышимость
@export var max_hearing_distance: float = 50.0

# Словарь UID -> ресурс
var sounds = {
	"flashlight_on": "uid://yjis7oplnmw5",
	"glass_break": "uid://byj1v8aaq3drc",
	"theme_music": "uid://abcd1234",
	"game_start" : "uid://c5d2108v7d0ka"
}
func _ready():
	pass
	# теперь можно безопасно включать _process
# ================= Динамические/разовые звуки =================
func just_play_sound(name: String, position: Vector3, volume_db: float = 0.0, pitch_range: Vector2 = Vector2(0.9, 1.1)):
	if not sounds.has(name):
		push_error("AudioManager: sound not found: %s" % name)
		return

	var player = AudioStreamPlayer3D.new()
	player.stream = load(sounds[name])
	player.transform.origin = position
	player.volume_db = volume_db
	
	# Случайный питч
	player.pitch_scale = randf_range(pitch_range.x, pitch_range.y)
	
	player.set_script(load(audio_source_script_path))
	add_child(player)
	player.play()

	dynamic_sources.append(player)
	player.connect("finished", Callable(self, "_on_dynamic_finished").bind(player))

func play_ui_sound(name: String, volume_db: float = -20.0, pitch_range: Vector2 = Vector2(1.0, 1.0)):
	if not sounds.has(name):
		push_error("AudioManager: sound not found: %s" % name)
		return

	var player = AudioStreamPlayer.new() # ⚡ не 3D, а 2D вариант
	player.stream = load(sounds[name])
	player.volume_db = volume_db
	player.pitch_scale = randf_range(pitch_range.x, pitch_range.y)

	add_child(player)
	player.play()
	
	player.connect("finished", Callable(self, "_on_ui_finished").bind(player))

func _on_ui_finished(player: AudioStreamPlayer):
	if is_instance_valid(player):
		player.queue_free()

func _on_dynamic_finished(player: AudioStreamPlayer3D):
	if dynamic_sources.has(player):
		dynamic_sources.erase(player)
	player.queue_free()

# ================= Постоянные источники (музыка, магнитофон и т.д.) =================
func play_persistent(uid: String, volume_db: float = 0.0, loop: bool = true):
	if persistent_sources.has(uid):
		var player = persistent_sources[uid]
		player.volume_db = volume_db
		if not player.playing:
			player.play()
		return

	if not sounds.has(uid):
		push_error("AudioManager: sound not found: %s" % uid)
		return

	var player = AudioStreamPlayer3D.new()
	player.stream = load(sounds[uid])
	player.volume_db = volume_db
	player.loop = loop
	player.play()
	add_child(player)
	persistent_sources[uid] = player
	register_source(player)

func stop_persistent(uid: String):
	if persistent_sources.has(uid):
		var player = persistent_sources[uid]
		player.stop()
		unregister_source(player)
		player.queue_free()
		persistent_sources.erase(uid)

# ================= Регистрация/обновление объектных источников =================
var object_sources: Array = [] # например магнитофоны, вентиляторы

func register_source(player: AudioStreamPlayer3D):
	if not object_sources.has(player):
		object_sources.append(player)

func unregister_source(player: AudioStreamPlayer3D):
	object_sources.erase(player)

# ================= Occlusion и громкость =================
func _process(delta: float):
	var listener = ControllerManager.get_current_camera()
	if not listener:
		return
	var listener_pos = listener.global_transform.origin
	var space_state = get_world_3d().direct_space_state

	# Обновляем все динамические и объектные источники
	for source in dynamic_sources + object_sources:
		if not is_instance_valid(source):
			continue
		var from_pos = source.global_transform.origin
		if from_pos.distance_to(listener_pos) > max_hearing_distance:
			continue

		var to_pos = listener_pos - listener.global_transform.basis.z * 0.5
		var params = PhysicsRayQueryParameters3D.new()
		params.from = from_pos
		params.to = to_pos
		params.collision_mask = source.wall_mask
		params.exclude = []

		var result = space_state.intersect_ray(params)
		var target_db = 0.0 if result.is_empty() else source.occlusion_db
		source.volume_occlusion_db = lerp(source.volume_occlusion_db, target_db, delta * 5.0)
		source.update_volume()

		# 🎨 DEBUG линия (зелёная — чистый путь, красная — есть стена)
		if SettingsManager.values["draw_audio_path"]:
			var color = Color.GREEN if result.is_empty() else Color.RED
			DebugDraw3D.draw_line(from_pos, to_pos, color, 0.3)
