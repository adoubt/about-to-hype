extends Node
class_name UIManager  # важно, чтобы был доступ как глобальный класс

@onready var escape_menu: Control = $Escape
@onready var panels: Dictionary = {
	"Wallet_USDT": $Wallet_USDT,
	"Shop": $Shop,
	"Settings": $Settings
	# новые панели добавляй сюда
}

var ui_open: bool = false

# ========== PUBLIC API ==========

func toggle_escape_menu():
	if escape_menu.visible:
		close_escape_menu()
	else:
		open_escape_menu()

func open_escape_menu():
	escape_menu.visible = true
	_update_ui_state()

func close_escape_menu():
	escape_menu.visible = false
	_update_ui_state()

func open_panel(name: String):
	if panels.has(name):
		if panels[name] == $Wallet_USDT:
			$Wallet_USDT.open_wallet()
		panels[name].visible = true
		_update_ui_state()

func close_panel(name: String):
	if panels.has(name):
		panels[name].visible = false
		_update_ui_state()

func close_all():
	escape_menu.visible = false
	for p in panels.values():
		p.visible = false
	_update_ui_state()

# ========== INTERNAL ==========
func _ready():
	_update_ui_state()
	

func _update_ui_state():
	var open = _any_ui_open()
	if Engine.has_singleton("ControllerManager"):
		var mgr = Engine.get_singleton("ControllerManager") as ControllerManager
		mgr.set_all_input_enabled(not open)
	_show_mouse(open)
	
func _any_ui_open() -> bool:
	if escape_menu.visible:
		return true
	for p in panels.values():
		if p.visible:
			return true
	return false

func _show_mouse(visible: bool):
	Input.set_mouse_mode(
		Input.MOUSE_MODE_VISIBLE if visible else Input.MOUSE_MODE_CAPTURED
	)
