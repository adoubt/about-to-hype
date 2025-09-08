extends Node

const SAVE_PATH := "user://settings.cfg"
var values : Dictionary = {
	"draw_audio_path": false,       
	"language": "English",          
	"resolution": Vector2(1920,1080),
	"sensitivity": 1.0,
	"drone_new_control" :false ,
	"use_fov_effect" : true     
}

# ------------------
# PUBLIC API
# ------------------

func set_value(key: String, val) -> void:
	values[key] = val
	save() # сразу сохраняем на диск

func get_value(key: String, default_value = null):
	if values.has(key):
		return values[key]
	return default_value

# ------------------
# INTERNAL
# ------------------
func _ready():
	load_settings()                   # 1️⃣ подгружаем при старте

	
func load_settings() -> void:
	var cfg := ConfigFile.new()
	var err = cfg.load(SAVE_PATH)
	if err != OK:
		print("Settings file not found, using defaults")
		save() # создаём новый файл с дефолтами
		return

	# Обновляем словарь тем, что нашли в конфиге
	for key in values.keys():
		values[key] = cfg.get_value("settings", key, values[key])


func save() -> void:
	var cfg := ConfigFile.new()
	# Записываем все значения в секцию "settings"
	for key in values.keys():
		cfg.set_value("settings", key, values[key])
	var err = cfg.save(SAVE_PATH)
	if err != OK:
		push_error("Не удалось сохранить настройки! Код: %s" % err)
