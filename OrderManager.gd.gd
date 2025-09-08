extends Node

signal order_created(order)
signal order_completed(order)
signal order_failed(order)

@onready var hud_manager = $"../HUDManager"
@onready var player = $"../Player"

var active_orders: Array = []
var order_markers: Dictionary = {}  # Для хранения визуальных маркеров

# Создание нового заказа
func create_order(address: Vector3, payment: float, duration_seconds: float) -> Dictionary:
	var order = {
		"address": address,
		"payment": payment,
		"start_time": hud_manager.game_time,
		"deadline": hud_manager.game_time + duration_seconds,
		"delivered": false
	}
	active_orders.append(order)

	# Визуальный маркер точки доставки
	var marker = MeshInstance3D.new()
	marker.mesh = SphereMesh.new()
	marker.mesh.radius = 0.5
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color.MEDIUM_VIOLET_RED
	marker.material_override = mat
	marker.position = address + Vector3.UP * 0.5
	add_child(marker)

	order_markers[order] = marker

	emit_signal("order_created", order)
	return order

# Завершение заказа вручную (или автоматически)
func complete_order(order: Dictionary) -> void:
	if order in active_orders and not order.delivered:
		order.delivered = true
		GameState.wallet_usdt += order.payment
		emit_signal("order_completed", order)
		_remove_order(order)
		
# Отмена / просрочка заказа
func fail_order(order: Dictionary) -> void:
	if order in active_orders and not order.delivered:
		emit_signal("order_failed", order)
		_remove_order(order)

# Внутренний метод для удаления ордера и маркера
func _remove_order(order: Dictionary) -> void:
	if order in active_orders:
		active_orders.erase(order)
	if order in order_markers:
		order_markers[order].queue_free()
		order_markers.erase(order)

# Проверка доставки и дедлайнов каждый кадр
func _process(delta: float) -> void:
	var current_time = hud_manager.game_time
	for order in active_orders.duplicate():
		if not order.delivered:
			var player_pos = ControllerManager.get_active().global_transform.origin
			if player_pos.distance_to(order.address) < 2.0:
				complete_order(order)
			elif current_time > order.deadline:
				fail_order(order)
