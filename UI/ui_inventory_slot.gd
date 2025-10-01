extends Panel
class_name Slot
@export var normal_style: StyleBox 
@export var selected_style: StyleBox
@onready var slot_index_label: Label =  $MarginContainer/SlotId
@onready var icon: TextureRect = $Icon  # TextureRect внутри Panel

var item: InventoryItem


func _ready():
	var parent = get_parent()
	if parent:
		var index = parent.get_children().find(self)
		if index != -1:
			slot_index_label.text = str(index + 1)

func set_item(new_item: InventoryItem) -> void:
	item = new_item
	icon.texture = item.icon if item and item.icon else null

func clear_item():
	item = null
	icon.texture = null

func set_selected(on: bool) -> void:
	add_theme_stylebox_override("panel", selected_style if on else normal_style)
