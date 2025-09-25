extends MarginContainer

var current_index := 0
var slots: Array
var data = null   # заглушка, пока нет InventoryData

func _ready():
	slots = %Slots.get_children()
	update_selection()


func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		var index = event.keycode - KEY_1
		if index >= 0 and index < slots.size():
			current_index = index
			update_selection()

func update_selection():
	for i in range(slots.size()):
		slots[i].set_selected(i == current_index)






func _update_visuals():
	for i in range(slots.size()):
		var slot = slots[i]
		slot.set_selected(i == current_index)
		if data and i < data.slots.size():
			slot.set_item(data.slots[i])
		else:
			slot.clear_item()
			
