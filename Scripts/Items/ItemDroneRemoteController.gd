#ItemDroneRemoteController.gd
extends HeldItem

@export var target_drone_name : String = ""  # имя дрона, который управляется этим пультом

func use():
	if target_drone_name == "":
		print("Remote not connected")
		return

	ControllerManager._handle_object_hotkey(target_drone_name)

func use2() -> Variant:
	# ищем ближайший дрон к пульту (или к родительскому игроку)
	var drones = get_tree().get_nodes_in_group("drone")
	if drones.is_empty():
		print("Нет дронов на сцене")
		return null
	
	# для позиции используем глобальное положение пульта
	var my_pos = global_transform.origin
	var nearest_drone = null
	var nearest_dist = INF
	for drone in drones:
		var dist = my_pos.distance_to(drone.global_transform.origin)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest_drone = drone
	
	if nearest_drone:
		target_drone_name = nearest_drone.name
		print("Remote connected to: ", target_drone_name)
		return nearest_drone
	else:
		print("Не удалось найти дрон")
		return null
