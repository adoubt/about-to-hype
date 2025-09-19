extends Node3D


func _ready():
	
	ControllerManager.refresh()
	ControllerManager.register($Player)   
	ControllerManager.register($Base_Drone)    

	
