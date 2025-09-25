# InventoryItem.gd
extends Resource
class_name InventoryItem

@export var name: String
@export var icon: Texture2D
@export var stack_size: int = 1
@export var scene_item_held: String # сцена предмета для поднятия в руки
@export var scene_item_loot: String # сцена предмета для спавна на уровне
