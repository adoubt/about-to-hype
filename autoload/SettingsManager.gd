extends Node

var save_path := "user://settings.cfg"
var values := {
	"draw_audio_path": false,        # bool
	"language": "English",          # String
	"resolution": Vector2(1920,1080), # Vector2
	"sensitivity": 1.0    ,
	"drone_new_control" :false        # float
}

# ------------------
# PUBLIC API
# ------------------
func set_value(key: String, val: Variant) -> void:
	values[key] = val
	save()  # сразу сохраняем

func get_value(key: String) -> Variant:
	return values.get(key, null)

# ------------------
# INTERNAL
# ------------------
func _ready():
	load_settings()                   # 1️⃣ подгружаем при старте

	
func load_settings():
	var cfg = ConfigFile.new()
	if cfg.load(save_path) != OK:
		return # нет файла — остаются дефолтные
	for key in values.keys():
		values[key] = cfg.get_value("settings", key, values[key])
func save():
	var cfg = ConfigFile.new()
	for key in values.keys():
		cfg.set_value("settings", key, values[key])
	cfg.save(save_path)
