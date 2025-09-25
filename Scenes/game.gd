extends Node3D
@onready var order_manager = $OrderManager

func _ready():
	
	pass
	

func _input(event):

	if event.is_action_pressed("test"):  # например, Enter
		var random_pos = Vector3(randi()%20-10, 0, randi()%20-10)
		order_manager.create_order(random_pos, 100, 6000)	
