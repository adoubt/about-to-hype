extends Control

var pressed := false

func _ready():
	$Label.modulate.a = 0.0
	var tween = create_tween()
	tween.set_loops() # у самого Tween есть, а не у PropertyTweener
	tween.tween_property($Label, "modulate:a", 1.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Label, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _input(event):
	if not pressed and event.is_pressed():
		pressed = true
		start_transition()

func start_transition():
	var fade = ColorRect.new()
	fade.color = Color.BLACK
	fade.size = get_viewport_rect().size
	add_child(fade)
	fade.modulate.a = 0.0

	var t = create_tween()
	t.tween_property(fade, "modulate:a", 1.0, 1.0).set_trans(Tween.TRANS_SINE)
	t.tween_callback(Callable(self, "_go_to_menu"))

func _go_to_menu():
	get_tree().change_scene_to_file("res://Menu.tscn")
