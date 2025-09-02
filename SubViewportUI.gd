extends MarginContainer

@onready var order_list = $OrderList
@onready var order_manager = $"../../../OrderManager"

func _ready():
	# Находим OrderManager в игре

	order_manager.connect("order_created", Callable(self, "_on_order_created"))
	order_manager.connect("order_completed", Callable(self, "_on_order_completed"))
	order_manager.connect("order_failed", Callable(self, "_on_order_failed"))

func _on_order_created(order):
	var label = Label.new()
	label.name = str(order.address)  # уникальный идентификатор
	label.text = "New Order: $" + str(order.payment)
	order_list.add_child(label)

func _on_order_completed(order):
	var label = order_list.get_node(str(order.address))
	if label:
		label.text += " ✅"

func _on_order_failed(order):
	var label = order_list.get_node(str(order.address))
	if label:
		label.text += " ❌"
