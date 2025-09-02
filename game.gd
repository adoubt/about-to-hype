extends Node3D


@onready var card_balance = $HUD/CardBalance
var wallet_usdt: float = 100.0
@onready var card_usd: float 
var pending_deals: Array = []
@onready var mgr = $ControllerManager
@onready var order_manager = $OrderManager

var game_time: float = 0.0    # В секундах с начала игры
var time_scale: float = 60.0  # 1 секунда реального времени = 1 минута игрового времени
@onready var game_time_label = $HUD/GameTime

# формируем строку, например "08:23"


func _ready():
	_update_ui()
	mgr.register($Player)   
	mgr.register($Base_Drone)     
	mgr.register($StreetCam)
	
func _update_ui():
	card_balance.text = "Card: %.2f USD" % card_usd

func _input(event):
	
	if event.is_action_pressed("Esc"):
		$UIManager.toggle_escape_menu()	

	if event.is_action_pressed("test"):  # например, Enter
		var random_pos = Vector3(randi()%20-10, 0, randi()%20-10)
		order_manager.create_order(random_pos, 100, 6000)	


#func request_deal(amount: float, seller: Dictionary, card: String) -> Dictionary:
	#if amount <= 0 or amount > wallet_usdt:
		#return {}
	#
	## списали крипту
	#wallet_usdt -= amount
	#
	##var deal = {
		##"amount": amount,
		##"rate": seller["rate"],
		##"seller": seller,
		##"card": card,
		##"start_time": Time.get_ticks_msec(),
		##"wait_ms": 10000, # 10 сек
		##"status": "pending"  # pending / success / fail
	##}
	##
	##pending_deals.append(deal)
	#_update_ui()
	#return deal  # вернём, чтобы ноутбук знал про него

func _process(delta: float) -> void:

	game_time += delta * time_scale
	update_game_time_label()
	
	card_usd = $UIManager/Wallet_USDT.card_usd
	_update_ui()
	#var now = Time.get_ticks_msec()
	#for deal in pending_deals:
		#if deal["status"] == "pending" and now - deal["start_time"] >= deal["wait_ms"]:
			#_finish_deal(deal)



func update_game_time_label():
	var total_seconds = int(game_time)
	var hours = (total_seconds / 3600) % 24
	var minutes = (total_seconds / 60) % 60
	game_time_label.text = str(hours).pad_zeros(2) + ":" + str(minutes).pad_zeros(2)
