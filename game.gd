extends Node3D

@onready var esc_menu =  $Escape

func _input(event):
	if event.is_action_pressed("Esc"): # по умолчанию привязано к Esc
		esc_menu.visible = not esc_menu.visible
