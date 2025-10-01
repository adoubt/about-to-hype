extends HeldItem

# Возможные состояния крышки
enum ZippoState { OPEN, CLOSED }

var current_state = ZippoState.OPEN
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	open_zippo()  # открываем зажигалку сразу

# ЛКМ → огонь
func use():
	if current_state != ZippoState.OPEN:
		return  # ничего не делаем, если крышка закрыта
	fire_zippo()
	# Здесь можно добавить спаун пламени или эффекты

# ПКМ → открыть/закрыть
func use2():
	if current_state == ZippoState.OPEN:
		close_zippo()
	else:
		open_zippo()

# Открыть крышку
func open_zippo():
	current_state = ZippoState.OPEN
	AudioManager.just_play_sound("zippo_open", position)
	animation_player.play("open")

# Закрыть крышку
func close_zippo() -> void:
	current_state = ZippoState.CLOSED
	animation_player.play("close")
	await animation_player.animation_finished
	AudioManager.just_play_sound("zippo_close", position)


# Зажечь зажигалку
func fire_zippo():
	AudioManager.just_play_sound("zippo_fire", position)
	# TODO: добавить визуальное пламя
	
