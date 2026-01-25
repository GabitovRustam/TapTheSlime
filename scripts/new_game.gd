extends Popup

@onready var close_sound: AudioStreamPlayer = %CloseSound
@onready var new_game_button: Button = $NewGame/MarginContainer/NinePatchRect/VBoxContainer/MarginContainer/HBoxContainer/NewGameButton

signal new_game
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	new_game_button.disabled = !GameManager.can_new_game


func _on_close_pressed() -> void:
	close_sound.play()
	visible = false

func _on_close_sound_finished() -> void:
	queue_free()

func _on_new_game_button_pressed() -> void:
	GameManager.coins = 0
	GameManager.gems = 0
	GameManager.purchased_goods.clear()
	GameManager.activated_goods.clear()
	GameManager.gem_probability = 4*GameManager.gem_probability
	GameManager.can_new_game = false
	GameManager.save_game()
	queue_free()
	new_game.emit()
	
