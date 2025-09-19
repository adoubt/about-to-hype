extends Node

# Жёстко прописанные пути сцен
const SCENES := {
	"Intro": "uid://bsoxxlhnjn45f",
	"MainMenu": "uid://dcirc02tx3del",
	"Game": "uid://cs3guckxlcjyi",
	"TestPolygon": "uid://dhl6fkkhp3dy8"
}

# текущая сцена
var current_scene_name: String = ""

# ---------------- PUBLIC API ----------------

func go_to_intro():
	_change_scene("Intro")

func go_to_main_menu():
	_change_scene("MainMenu")

func go_to_game():
	_change_scene("Game")
	
func go_to_test_polygon():
	_change_scene("TestPolygon")
	
func exit():
	get_tree().quit()
# ---------------- INTERNAL ----------------

func _change_scene(name: String):
	if not SCENES.has(name):
		push_error("SceneManager: сцена не найдена: %s" % name)
		return
	current_scene_name = name
	ControllerManager.refresh()
	get_tree().change_scene_to_file(SCENES[name])
	_update_ui_for_scene()
	UIManager.close_all()
func _update_ui_for_scene():

	# форс курсор через UIManager
	if current_scene_name in ["MainMenu"]:
		UIManager.force_cursor_visible = true
	else:
		UIManager.force_cursor_visible = false
	#UIManager._update_ui_state()
