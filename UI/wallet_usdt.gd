extends Control


# Данные продавцов
var sellers = [
	{"name": "Trader_A", "success": 95, "rate": 0.97},
	{"name": "Trader_B", "success": 82, "rate": 0.99},
	{"name": "Trader_C", "success": 60, "rate": 1.02},
]
# UI refs
@onready var wallet_panel = %WalletPanel
@onready var usdt_label = %WalletPanel/USDTLabel
@onready var card_label = %WalletPanel/CardLabel
@onready var market_panel = %MarketPanel
@onready var seller_list = %MarketPanel/SellerList
@onready var deal_panel = %DealPanel
@onready var deal_info = %DealPanel/DealInfo
@onready var amount_edit = %DealPanel/AmountEdit
@onready var card_edit = %DealPanel/CardEdit
@onready var wait_panel = %WaitPanel
@onready var wait_label = %WaitPanel/WaitLabel
@onready var timer_label = %WaitPanel/TimerLabel
@onready var pb = %WaitPanel/PB
@onready var texture_rect = %TextureRect
@onready var timer: Timer = %Timer
var current_deal: Dictionary
var current_seller: Dictionary
@export var wait_time: float = 4.0 # секунды
var pending_deals: Array = []
var card
func _ready():
	
	%WalletPanel/ToMarketBtn.pressed.connect(_open_market)
	%MarketPanel/BackBtn.pressed.connect(_back_wallet)
	%DealPanel/CancelDealBtn.pressed.connect(_back_market)
	%DealPanel/ConfirmDealBtn.pressed.connect(_confirm_deal)
	$TextureRect/Header/Close_wallet.pressed.connect(func(): UIManager.close_panel("Wallet_USDT"))
	%WaitPanel/Close_wallet.pressed.connect(func(): UIManager.close_panel("Wallet_USDT"))
	#texture_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	timer.timeout.connect(_on_timer_timeout)

func refresh():
	_refresh_wallet()
	if current_deal and current_deal["status"] == "pending":
		wallet_panel.visible = false
		market_panel.visible = false
		deal_panel.visible = false
		wait_panel.visible = true
	else:
		wallet_panel.visible = true
		market_panel.visible = false
		deal_panel.visible = false
		wait_panel.visible = false
		_back_wallet()

	
func _refresh_wallet():
	usdt_label.text = "%.2f USDT" % GameState.wallet_usdt

# --- Market ---
func _open_market():
	wallet_panel.visible = false
	market_panel.visible = true
	_populate_sellers()

func _back_wallet():
	market_panel.visible = false
	wallet_panel.visible = true
	_refresh_wallet()

func _populate_sellers():
	for child in seller_list.get_children():
		child.queue_free()
	for s in sellers:
		var h = HBoxContainer.new()
		var l1 = Label.new()
		l1.text = s["name"]
		h.add_child(l1)
		var l2 = Label.new()
		l2.text = "%d%%" % s["success"]
		h.add_child(l2)
		var l3 = Label.new()
		l3.text = "Rate %.3f" % s["rate"]
		h.add_child(l3)
		var btn = Button.new()
		btn.text = "SELL"
		btn.pressed.connect(func(): _open_deal(s))
		h.add_child(btn)
		seller_list.add_child(h)

# --- Deal ---
func _open_deal(seller: Dictionary):
	current_seller = seller
	market_panel.visible = false
	deal_panel.visible = true
	deal_info.text = "Sell to %s | %d%% | Rate %.3f" % [seller["name"], seller["success"], seller["rate"]]
	
func _back_market():
	deal_panel.visible = false
	market_panel.visible = true

func _confirm_deal():
	var amount = amount_edit.text.to_float()
	card = card_edit.text
	if amount <= 0:
		_notify("❌ Неверная сумма")
		return
	if card.length() < 4:
		_notify("❌ Введите карту")
		return



	if amount <= 0 or amount > GameState.wallet_usdt:
		_notify("❌ Недостаточно USDT")
		return
	_start_wait(amount,current_seller)

	deal_panel.visible = false
	wait_panel.visible = true

# --- Wait ---
func _start_wait(amount: float, seller: Dictionary):

	wait_panel.visible = true
	pb.value = 0
	pb.max_value = wait_time

	current_deal = {
		"amount": amount,
		"rate": seller["rate"],
		"seller": seller,
		"card": card,
		"start_time": Time.get_ticks_msec(),
		"wait_ms": wait_time, 
		"status": "pending"  # pending / success / fail
	}
	timer.stop()
	timer.wait_time = wait_time
	set_process(true)
	timer.start()
	
func _process(delta: float) -> void:
	if current_deal and wait_panel.visible:
		var elapsed = (Time.get_ticks_msec() - current_deal["start_time"]) / 1000.0
		var left = int(ceil(wait_time - elapsed))
		if left > 0 and current_deal["status"] == "pending":
			timer_label.text = "00:%02d" % left
			pb.max_value = wait_time
			pb.value = min(elapsed, wait_time)
	var now = Time.get_ticks_msec()
	for deal in pending_deals:
		if deal["status"] == "pending" and now - deal["start_time"] >= deal["wait_ms"]:
			_finish_deal(current_deal["amount"], current_deal["seller"])

func _finish_deal(amount: float, seller: Dictionary):
	set_process(false)
	wait_panel.visible = false
	var chance = seller["success"] - max(0, (seller["rate"] - 1.0) * 100)
	var roll = randf() * 100
	if roll <= chance:
		current_deal["status"] = "success"
		var sum = amount * seller["rate"]
		GameState.card_usd + sum
		GameState.wallet_usdt -sum
		_notify("✅ Успех! На карту пришло %.2f USD" % sum)
	else:
		current_deal["status"] = "fail"
		_notify("❌ Сделка сорвалась")
		
	_refresh_wallet()
	_back_wallet()

func _notify(text: String):
	var d = AcceptDialog.new()
	d.dialog_text = text
	add_child(d)
	d.popup_centered()


func _on_timer_timeout():
	if current_deal:
		_finish_deal(current_deal["amount"], current_deal["seller"])
