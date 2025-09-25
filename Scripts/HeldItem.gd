# HeldItem.gd
extends Node3D
class_name HeldItem
var loot_data: InventoryItem = null

signal used  # сигнал для сторонних эффектов, если нужно

func use():
	# базовый вариант - должен быть переопределён для конкретного предмета
	print("Использую предмет: ")

func use2():
	# базовый вариант - должен быть переопределён для конкретного предмета
	#Альтернативное действие
	pass

func throw():
	if not loot_data:
		print("Нет данных предмета для выброса")
		return
	
	# Загружаем сцену для Loot
	var scene_res: PackedScene = load(loot_data.scene_item_loot)
	if not scene_res:
		push_error("Не удалось загрузить сцену: %s" % loot_data.scene_item_loot)
		return

	var thrown_item = scene_res.instantiate() as Loot
	if not thrown_item:
		push_error("Не удалось создать ноду Loot из сцены!")
		return

	# Ставим в позицию руки
	var hand_global = global_transform
	thrown_item.global_transform.origin = hand_global.origin + hand_global.basis.z * 1.0  # чуть вперед

	# Если нужен физический выброс
	if thrown_item is RigidBody3D:
		var forward_dir = -hand_global.basis.z.normalized()
		thrown_item.linear_velocity = forward_dir * 10
		thrown_item.angular_velocity = Vector3(randf(), randf(), randf()) * 5

	# Добавляем на сцену
	get_tree().current_scene.add_child(thrown_item)

	# Убираем предмет из руки
	queue_free()
