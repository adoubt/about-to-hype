extends Node3D

@onready var ui_manager = $"../UIManager"   # ссылка на твой UIManager
@onready var prompt_label: Label3D = $PromptLabel
@onready var area: Area3D = $Area3D

var player_in_area: bool = false

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	prompt_label.visible = false
	set_process_input(false)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_area = true
		prompt_label.visible = true
		set_process_input(true)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_area = false
		prompt_label.visible = false
		set_process_input(false)

func _input(event: InputEvent) -> void:
	if player_in_area and event.is_action_pressed("Interact"):
		ui_manager.open_panel("Wallet_USDT")
