extends Interactable
class_name Usable

@export_enum("Laptop", "Door", "Workbench", "Terminal") var use_type: String = "Laptop"

var is_occupied: bool = false
var occupied_by: int = -1

	

@rpc("any_peer", "call_local")
func set_occupied_state(occupied: bool, player_id: int):
	is_occupied = occupied
	occupied_by = player_id

func release():
	rpc("set_occupied_state", false, -1)

func _toggle_door():
	if has_node("AnimationPlayer"):
		get_node("AnimationPlayer").play("open")


func _on_interacted(body: Variant) -> void:
	if not enabled:
		return

	var id = body.get_multiplayer_authority()

	if is_occupied and occupied_by != id:
		print("⛔ Object already used by another player")
		return

	rpc("set_occupied_state", true, id)

	match use_type:
		"Laptop":
			UIManager.open_wallet_usdt()
		"Door":
			_toggle_door()
		_:
			print("🧩 Unknown use type:", use_type)
