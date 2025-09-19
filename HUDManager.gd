extends Control
class_name HUDManager
@onready var card_balance = $HUD/InventoryBar/HBoxContainer2/Control3/CardBalance



var game_time: float = 0.0    # В секундах с начала игры
var time_scale: float = 60.0  # 1 секунда реального времени = 1 минута игрового времени
@onready var game_time_label = $HUD/GameTime

# формируем строку, например "08:23"


func _ready():
	_update_ui()
	
	
func _update_ui():
	card_balance.text = "Card: %.2f USD" % GameState.card_usd
	
func _input(event):
	
	if event.is_action_pressed("Esc"):
		UIManager.toggle_escape_menu()	


func _process(delta: float) -> void:

	game_time += delta * time_scale
	update_game_time_label()

	_update_ui()
	
	
func update_game_time_label():
	var total_seconds = int(game_time)
	var hours = (total_seconds / 3600) % 24
	var minutes = (total_seconds / 60) % 60
	game_time_label.text = str(hours).pad_zeros(2) + ":" + str(minutes).pad_zeros(2)
