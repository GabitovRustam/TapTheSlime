extends Node

var coins: int = 0
var gems: int = 0
var purchased_goods: Array[String] = []
var activated_goods: Array[String] = []
var user_id: String = ''
var user_name: String = ''
var music_mode: int = 2
var can_new_game: bool = false
var gem_probability: float = 1
var response_json: Variant

var ura_texts = ["Молодец!", "Умничка!", "Красавчик!", "Молоток!", "Талантище!", "Молодчина!", "Ура!"]

signal coin_overflow
signal request_completed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_game()
	get_lidership()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if coins > get_max_coins():
		coin_overflow.emit()
		
	
func save_game() -> void:
	var save_dict = {
		"coins": coins,
		"gems": gems,
		"purchased_goods": purchased_goods, 
		"activated_goods": activated_goods,
		"user_id": user_id,
		"user_name": user_name,
		"music_mode": music_mode,
		"gem_probability": gem_probability
	}
	var json_string = JSON.stringify(save_dict)

	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	save_file.store_line(json_string)

func load_game() -> void:
	if FileAccess.file_exists("user://savegame.save"):
		var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
		var json_string = save_file.get_line()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			return

		var save_dict = json.data
		if !save_dict is Dictionary:
			print("JSON Parse Error: not a dictionary in ", json_string, " at line ", json.get_error_line())
			return
			
		coins = save_dict.get("coins", 0)
		gems = save_dict.get("gems", 0)
		gem_probability = save_dict.get("gem_probability", 1)
		user_id = save_dict.get("user_id", '')
		if user_id == '':
			user_id = OS.get_unique_id()
		user_name = save_dict.get("user_name", '')
		if user_name == '':
			user_name = 'Игрок' + user_id.substr(0, 5)
		var array = save_dict.get("purchased_goods", [])
		purchased_goods.assign(array)
		array = save_dict.get("activated_goods", [])
		activated_goods.assign(array)
		music_mode = save_dict.get("music_mode", 2)

func get_coin_count() -> int:
	var coin_count = 1
	if activated_goods.has("CC1"):
		coin_count *= 2
	if activated_goods.has("CC2"):
		coin_count *= 2
	if activated_goods.has("CC3"):
		coin_count *= 2
	return coin_count
	
func get_max_coins() -> int:
	var max_coins = 100
	if activated_goods.has("MC1"):
		max_coins *= 2
	if activated_goods.has("MC2"):
		max_coins *= 2
	if activated_goods.has("MC3"):
		max_coins *= 2
	if activated_goods.has("MC4"):
		max_coins *= 2
	if activated_goods.has("MC5"):
		max_coins *= 2
	if activated_goods.has("MC6"):
		max_coins *= 2
	if activated_goods.has("MC7"):
		max_coins *= 2
	if activated_goods.has("MC8"):
		max_coins *= 2
	if activated_goods.has("MC9"):
		max_coins *= 2
	if activated_goods.has("MC10"):
		max_coins *= 2
	return max_coins
	
func get_grow_speed() -> float:
	var grow_speed = 1
	if activated_goods.has("GS1"):
		grow_speed *= 2
	if activated_goods.has("GS2"):
		grow_speed *= 2
	if activated_goods.has("GS3"):
		grow_speed *= 2
	return grow_speed
	
func get_click_power() -> float:
	var click_power = 1
	if activated_goods.has("CP1"):
		click_power *= 2
	if activated_goods.has("CP2"):
		click_power *= 2
	if activated_goods.has("CP3"):
		click_power *= 2
	return click_power

func has_auto_kill() -> bool:
	return activated_goods.has("AK")

func add_gems(add: int) -> void:
	gems = gems + add
	if gems < 0:
		gems = 0
		
	save_game()
	
func add_coins(add: int) -> void:
	coins = coins + add
	
	if coins < 0:
		coins = 0
		
	save_game()
	
	if coins % 100 == 99:
		# Retrieve the AndroidRuntime singleton.
		var android_runtime = Engine.get_singleton("AndroidRuntime")
		if android_runtime:
			# Retrieve the Android Activity instance.
			var activity = android_runtime.getActivity()

			# Create a Godot Callable to wrap the toast display logic.
			var toast_callable = func():
				# Use JavaClassWrapper to retrieve the android.widget.Toast class, then make and show a toast using the class APIs.
				var ToastClass = JavaClassWrapper.wrap("android.widget.Toast")
				var dialog_num = randi() % ura_texts.size()
				var ura_text = ura_texts[dialog_num]
				ToastClass.makeText(activity, ura_text, ToastClass.LENGTH_LONG).show()

			# Wrap the Callable in a Java Runnable and run it on the Android UI thread to show the toast.
			activity.runOnUiThread(android_runtime.createRunnableFromGodotCallable(toast_callable))

func get_lidership() -> void:
	if %HTTPRequest:
		var encoded_user_id = user_id.uri_encode()
		var encoded_user_name = user_name.uri_encode()
		var url = "https://alcotimer.ru/taptheslime?id=" + encoded_user_id + "&name=" + encoded_user_name + "&gems=" + str(gems) + "&coins=" + str(coins)
		%HTTPRequest.request(url)

func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var body_str = body.get_string_from_utf8()
	response_json = JSON.parse_string(body_str)
	request_completed.emit()
		
func get_last_response() -> Variant:
	return response_json
