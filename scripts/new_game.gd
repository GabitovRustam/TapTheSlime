extends Popup

@export var game_manager: Node
@onready var close_sound: AudioStreamPlayer = %CloseSound
@onready var new_game_button: Button = $NewGame/MarginContainer/NinePatchRect/VBoxContainer/MarginContainer/HBoxContainer/NewGameButton

signal new_game
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	new_game_button.disabled = !game_manager.can_new_game


func _on_close_pressed() -> void:
	close_sound.play()
	visible = false

func _on_close_sound_finished() -> void:
	queue_free()

func _on_new_game_button_pressed() -> void:
	game_manager.coins = 0
	game_manager.gems = 0
	game_manager.purchased_goods.clear()
	game_manager.activated_goods.clear()
	game_manager.gem_probability = 4*game_manager.gem_probability
	game_manager.can_new_game = false
	game_manager.save_game()
	queue_free()
	new_game.emit()
	
