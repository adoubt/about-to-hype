extends HBoxContainer

@export var min_value: float = 60.00
@export var max_value: float = 100.00

@onready var slider: HSlider = $Slider
@onready var input: LineEdit = $Input

func _ready():
	# Настраиваем слайдер по границам
	slider.min_value = min_value
	slider.max_value = max_value

	# Сразу обновляем поле
	input.text = str(slider.value)

	# Подписываемся на события
	slider.value_changed.connect(_on_slider_changed)
	input.text_submitted.connect(_on_input_submitted)
	input.focus_exited.connect(_on_input_submitted.bind(input.text)) # если ушёл с фокуса

func _on_slider_changed(value: float) -> void:
	# При движении слайдера обновляем текст
	input.text = str(round(value * 100) / 100.0) # округлим до 2 знаков

func _on_input_submitted(text: String) -> void:
	var num = text.to_float()
	# Ограничиваем число границами
	num = clamp(num, min_value, max_value)
	slider.value = num
	input.text = str(round(num * 100) / 100.0)
