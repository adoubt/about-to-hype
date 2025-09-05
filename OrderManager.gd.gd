# OrderManager.gd
extends Node

signal order_created(order)
signal order_completed(order)
signal order_failed(order)

@onready var game = get_node("/root/game")  # Game.gd
@onready var player = $"../Player"


var active_orders: Array = []

# Создание нового заказа
func create_order(address: Vector3, payment: float, duration_seconds: float):
	var order = {
		"address": address,
		"payment": payment,
		"start_time": game.game_time,
		"deadline": game.game_time + duration_seconds,
		"delivered": false
	}
	active_orders.append(order)
	emit_signal("order_created", order)

# Обработка доставки и дедлайнов
func _process(delta):
	var current_time = game.game_time
	var to_remove: Array = []

	for order in active_orders:
		if not order.delivered:
			var player_pos = player.global_transform.origin
			# Проверка зоны доставки
			if player_pos.distance_to(order.address) < 2.0:
				order.delivered = true
				GameState.wallet_usdt += order.payment
				emit_signal("order_completed", order)
				to_remove.append(order)
			# Проверка дедлайна
			elif current_time > order.deadline:
				emit_signal("order_failed", order)
				to_remove.append(order)

	# Удаляем завершённые или просроченные заказы после итерации
	for order in to_remove:
		active_orders.erase(order)
