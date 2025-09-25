extends Interactable
class_name Loot


@export var item: InventoryItem

func _ready() -> void:
	item = load("res://Resources/Items/drone_remote_controller.tres")
	
func _on_interacted(body):
	# body — это игрок, если нужно
	# на HUDManager кидаем айтем
	
	var hud = get_tree().get_root().get_node("game/HUDManager") 
	if hud:
		hud.add_item_to_inventory(item,0)
	if body.has_method("equip_item"):  # body = игрок
		body.equip_item(item)
	queue_free()  # убираем объект с уровня после поднятия
