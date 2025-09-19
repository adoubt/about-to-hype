extends Panel

@export var normal_style: StyleBox 
@export var selected_style: StyleBox

@onready var icon = $Icon  # TextureRect внутри Panel

var item: InventoryItem

func set_item(new_item: InventoryItem) -> void:
	item = new_item
	if item and item.icon:
		icon.texture = item.icon
	else:
		icon.texture = null


func clear_item():
	item = null
	icon.texture = null

func set_selected(on: bool) -> void:
	add_theme_stylebox_override("panel", selected_style if on else normal_style)
