extends Popup

@onready var close_sound: AudioStreamPlayer = %CloseSound
@onready var my_name: LineEdit = %MyName
@onready var my_position: Label = %MyPosition
@onready var my_gems: Label = %MyGems
@onready var my_coins: Label = %MyCoins

func update_top() -> void:
	var response_json = GameManager.get_last_response()
	if response_json != null:
		my_position.text = str(int(response_json.player_position))
		my_gems.text = str(int(response_json.player.gems))
		my_coins.text = str(int(response_json.player.coins))
		my_name.text = response_json.player.name
		
		for i in range(response_json.leadership.size()):
			var player_name = get_node("%NamePlayer" + str(i+1))
			if player_name:
				player_name.text = response_json.leadership[i].name
			var player_gems = get_node("%GemsPlayer" + str(i+1))
			if player_gems:
				player_gems.text = str(int(response_json.leadership[i].gems))
			var player_coins = get_node("%CoinsPlayer" + str(i+1))
			if player_coins:
				player_coins.text = str(int(response_json.leadership[i].coins))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	my_name.text = GameManager.user_name
	my_gems.text = str(GameManager.gems)
	my_coins.text = str(GameManager.coins)
	GameManager.request_completed.connect(_on_request_completed)
	update_top()
	GameManager.get_lidership()

func _on_request_completed() -> void:
	update_top()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_close_pressed() -> void:
	close_sound.play()
	visible = false


func _on_close_sound_finished() -> void:
	queue_free()


func _on_max_button_pressed() -> void:
	OS.shell_open("https://max.ru/join/GQPn5IdAEzbaHsl0QfCobv4oD27vzXvfFiPE-koBl0Q")


func _on_cloud_tips_button_pressed() -> void:
	OS.shell_open("https://pay.cloudtips.ru/p/8ab40392")


func _on_refresh_pressed() -> void:
	GameManager.get_lidership() 


func _on_my_name_text_submitted(new_text: String) -> void:
	if my_name.text:
		my_name.text = my_name.text.substr(0, 15)
		GameManager.user_name = my_name.text
		GameManager.get_lidership()
