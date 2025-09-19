# SaveManager.gd
extends Node
class_name SaveManager

const SAVE_PATH := "user://world_save.json"

var save_data: Dictionary = {
	"world": {
		"time": 0.0,
		"objects": []   # деревья, сундуки, постройки и т.п.
	},
	"players": {}       # словарь игроков {player_id: {позиция, инвентарь, статы}}
}

# ==========================
# PUBLIC API
# ==========================

func new_world():
	save_data = {
		"world": {"time": 0.0, "objects": []},
		"players": {}
	}
	save_game()

func load_world():
	save_data = _load_json(SAVE_PATH, {
		"world": {"time": 0.0, "objects": []},
		"players": {}
	})

func save_game():
	_save_json(SAVE_PATH, save_data)


# --- Игроки ---
func register_player(id: String):
	if not save_data["players"].has(id):
		save_data["players"][id] = {
			"position": Vector3.ZERO,
			"stats": {"hp": 100, "stamina": 100},
			"inventory": []
		}
	return save_data["players"][id]

func get_player(id: String) -> Dictionary:
	return save_data["players"].get(id, {})

func update_player(id: String, new_data: Dictionary):
	save_data["players"][id] = new_data


# --- Мир ---
func get_world() -> Dictionary:
	return save_data["world"]

func update_world(data: Dictionary):
	save_data["world"] = data


# ==========================
# INTERNAL HELPERS
# ==========================
func _save_json(path: String, data: Dictionary):
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func _load_json(path: String, default_value = {}):
	if not FileAccess.file_exists(path):
		return default_value
	var file = FileAccess.open(path, FileAccess.READ)
	if not file: 
		return default_value
	var text = file.get_as_text()
	file.close()
	var result = JSON.parse_string(text)
	return result if typeof(result) == TYPE_DICTIONARY else default_value
