extends Control

# Балансы
var wallet_usdt: float = 100.0
var card_usd: float = 0.0

# Данные продавцов
var sellers = [
	{"name": "Trader_A", "success": 95, "rate": 0.97},
	{"name": "Trader_B", "success": 82, "rate": 0.99},
	{"name": "Trader_C", "success": 60, "rate": 1.02},
]

# UI refs
@onready var ui_manager = $".."
@onready var wallet_panel = $WalletPanel
@onready var usdt_label = $WalletPanel/USDTLabel
@onready var card_label = $WalletPanel/CardLabel
@onready var market_panel = $MarketPanel
@onready var seller_list = $MarketPanel/SellerList
@onready var deal_panel = $DealPanel
@onready var deal_info = $DealPanel/DealInfo
@onready var amount_edit = $DealPanel/AmountEdit
@onready var card_edit = $DealPanel/CardEdit
@onready var wait_panel = $WaitPanel
@onready var wait_label = $WaitPanel/WaitLabel
@onready var timer_label = $WaitPanel/TimerLabel
@onready var pb = $WaitPanel/PB

var current_deal: Dictionary
var current_seller: Dictionary
var wait_time: int = 10 # секунд для теста
var timer: Timer

func _ready():
	_refresh_wallet()
	$WalletPanel/ToMarketBtn.pressed.connect(_open_market)
	$MarketPanel/BackBtn.pressed.connect(_back_wallet)
	$DealPanel/CancelDealBtn.pressed.connect(_back_market)
	$DealPanel/ConfirmDealBtn.pressed.connect(_confirm_deal)
	$WalletPanel/Close_wallet.pressed.connect(func(): ui_manager.close_panel("Wallet_USDT"))
	$WaitPanel/Close_wallet.pressed.connect(func(): ui_manager.close_panel("Wallet_USDT"))
func open_wallet():
	visible = true
	# Если сделка идёт → сразу открываем WaitPanel
	if current_deal and current_deal["status"] == "pending":
		wallet_panel.visible = false
		market_panel.visible = false
		deal_panel.visible = false
		wait_panel.visible = true
	else:
		# если сделки нет → обычная главная страница
		_back_wallet()
	
func _refresh_wallet():
	usdt_label.text = "Balance: %.2f USDT" % wallet_usdt
	card_label.text = "Card: %.2f USD" % card_usd

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
	# очищаем старый список
	for child in seller_list.get_children():
		child.queue_free()

	# создаём новые строки
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
	var card = card_edit.text
	if amount <= 0:
		_notify("❌ Неверная сумма")
		return
	if card.length() < 4:
		_notify("❌ Введите карту")
		return

	var game = get_tree().current_scene
	current_deal = game.request_deal(amount, current_seller, card)

	if current_deal.is_empty():
		_notify("❌ Недостаточно USDT")
		return

	deal_panel.visible = false
	wait_panel.visible = true

# --- Wait ---
func _start_wait(amount: float, seller: Dictionary):
	print('start wait')
	wait_panel.visible = true
	pb.value = 0
	pb.max_value = wait_time
	timer = Timer.new()
	timer.wait_time = wait_time
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(func(): _finish_deal(amount, seller))
	set_process(true)
	timer.start()

func _process(delta: float) -> void:
	if current_deal and wait_panel.visible:
		
		var now = Time.get_ticks_msec()
		var left = int(ceil((current_deal["wait_ms"] - (now - current_deal["start_time"])) / 1000.0))
		if left > 0 and current_deal["status"] == "pending":
			timer_label.text = "00:%02d" % left
			pb.max_value = current_deal["wait_ms"] / 1000
			pb.value = pb.max_value - left
		else:
			# сделка завершена
			wait_panel.visible = false
			if current_deal["status"] == "success":
				_notify("✅ Сделка завершена")
			elif current_deal["status"] == "fail":
				_notify("❌ Сделка сорвалась")

func _finish_deal(amount: float, seller: Dictionary):
	set_process(false)
	wait_panel.visible = false
	var chance = seller["success"] - max(0, (seller["rate"] - 1.0) * 100)
	var roll = randf() * 100
	if roll <= chance:
		wallet_usdt -= amount
		var usd = amount * seller["rate"]
		card_usd += usd
		_notify("✅ Успех! На карту пришло %.2f USD" % usd)
	else:
		_notify("❌ Сделка сорвалась")
	_refresh_wallet()
	_back_wallet()

# --- Уведомление ---
func _notify(text: String):
	var d = AcceptDialog.new()
	d.dialog_text = text
	add_child(d)
	d.popup_centered()
