extends Control
class_name HUDManager

@onready var card_balance: Label = $HUD/InventoryBar/HBoxContainer2/Control3/CardBalance
@onready var fps_label: Label = $HUD/FPS
@onready var game_time_label: Label = $HUD/GameTime

@onready var inventory_bar: MarginContainer = $HUD/InventoryBar

var _time_passed := 0.0
var _refresh_interval := 0.5  # обновляем FPS раз в 0.5 сек

var game_time: float = 0.0    # В секундах с начала игры
var time_scale: float = 60.0  # 1 секунда реального времени = 1 минута игрового времени

func add_item_to_inventory(item: InventoryItem, slot_index: int) -> void:
	if slot_index >= 0 and slot_index < inventory_bar.slots.size():
		inventory_bar.slots[slot_index].set_item(item)
		inventory_bar.update_selection()  # обновляем выделение
		

func clear_current_slot() -> void:
	var slot_index = inventory_bar.current_index
	inventory_bar.slots[slot_index].clear_item()
	
func _ready() -> void:
	_update_card()
	update_game_time_label()
	# FPS обновится на первом цикле _process


func _process(delta: float) -> void:
	# Игровое время
	game_time += delta * time_scale
	update_game_time_label()

	# FPS с интервалом
	_update_fps(delta)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Esc"):
		UIManager.toggle_escape_menu()


func _update_card() -> void:
	card_balance.text = "Card: %.2f USD" % GameState.card_usd


func _update_fps(delta: float) -> void:
	_time_passed += delta
	if _time_passed >= _refresh_interval:
		_time_passed = 0.0
		fps_label.text = "FPS " + str(int(Engine.get_frames_per_second()))


func update_game_time_label() -> void:
	var total_seconds: int = int(game_time)
	@warning_ignore("integer_division")
	var hours: int = (total_seconds / 3600) % 24
	@warning_ignore("integer_division")
	var minutes: int = (total_seconds / 60) % 60
	game_time_label.text = str(hours).pad_zeros(2) + ":" + str(minutes).pad_zeros(2)
