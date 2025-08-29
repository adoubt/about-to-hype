extends Node3D


@onready var card_balance = $CardBalance
var wallet_usdt: float = 100.0
@onready var card_usd: float 
var pending_deals: Array = []
@onready var mgr = $ControllerManager
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
	print(card_usd)
	_update_ui()
	card_usd = $UIManager/Wallet_USDT.card_usd
	#var now = Time.get_ticks_msec()
	#for deal in pending_deals:
		#if deal["status"] == "pending" and now - deal["start_time"] >= deal["wait_ms"]:
			#_finish_deal(deal)

func _finish_deal(deal: Dictionary) -> void:
	var seller = deal["seller"]
	var amount = deal["amount"]

	var chance = seller["success"] - max(0, (seller["rate"] - 1.0) * 100)
	var roll = randf() * 100
	if roll <= chance:
		var usd = amount * seller["rate"]
		card_usd += usd
		deal["status"] = "success"
	else:
		deal["status"] = "fail"
	_update_ui()
