extends CheckButton

@export var settings_key: String

func _ready():
	# Инициализация из конфига
	button_pressed = SettingsManager.get_value(settings_key) # false по умолчанию
	_update_text()

	# Подключаем сигнал через Callable
	toggled.connect(Callable(self, "_on_toggled"))

func _on_toggled(button_pressed: bool) -> void:
	_update_text()
	SettingsManager.set_value(settings_key, button_pressed)

func _update_text():
	text = "ON" if button_pressed else "OFF"
