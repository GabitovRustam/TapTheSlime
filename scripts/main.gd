extends Node3D

var shop_scene = preload("res://scenes/shop.tscn")
var cafe_scene = preload("res://scenes/cafe.tscn")
var new_game_scene = preload("res://scenes/new_game.tscn")

@onready var game_manager: Node = %GameManager
@onready var braid_kill: AnimationPlayer = $MeshInstance3D/BraidKill
@onready var audio_braid_kill: AudioStreamPlayer = $MeshInstance3D/AudioBraidKill
@onready var add_coins: Node3D = $AddCoins
@onready var drop_coins: Node3D = $DropCoins
@onready var camera_pivot: Node3D = $cameraPivot
@onready var cafe_open: AudioStreamPlayer = $Cafe/CafeOpen
@onready var cafe_sign: Label3D = %CafeSign
@onready var present_sign: Label3D = %PresentSign
@onready var present_timer: Timer = %PresentTimer
@onready var audio_present_ready: AudioStreamPlayer = %AudioPresentReady
@onready var animation_present: AnimationPlayer = %AnimationPresent
@onready var audio_present_open: AudioStreamPlayer = $Present/AudioPresentOpen
@onready var present_coins: Node3D = %PresentCoins
@onready var animation_jbl: AnimationPlayer = %AnimationJbl
@onready var black_hole_animation: AnimationPlayer = %BlackHoleAnimation
@onready var ground: MeshInstance3D = %Ground


var last_gems: int = 0
var last_coins: int = 0
var presents_count: int = 0
var present_coins_count: int = 0

func change_texture_of_ground(new_texture_path: String):
	var image = load(new_texture_path)
	var material_one = ground.mesh.surface_get_material(0)
	material_one.albedo_texture = image
	ground.mesh.surface_set_material(0, material_one)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var random = RandomNumberGenerator.new()
	random.randomize()
	set_music_mode()

	if game_manager.gem_probability / 16384 >= 1:
		change_texture_of_ground("res://textures/grass.jpg")
		$Egg7.visible = true
		$Egg6.visible = true
		$Egg5.visible = true
		$Egg4.visible = true
		$Egg3.visible = true
		$Egg2.visible = true
		$Egg1.visible = true
	elif game_manager.gem_probability / 4096 >= 1:
		change_texture_of_ground("res://textures/ground.jpg")
		$Egg6.visible = true
		$Egg5.visible = true
		$Egg4.visible = true
		$Egg3.visible = true
		$Egg2.visible = true
		$Egg1.visible = true
	elif game_manager.gem_probability / 1024 >= 1:
		change_texture_of_ground("res://textures/sand.jpg")
		$Egg5.visible = true
		$Egg4.visible = true
		$Egg3.visible = true
		$Egg2.visible = true
		$Egg1.visible = true
	elif game_manager.gem_probability / 256 >= 1:
		change_texture_of_ground("res://textures/breakstone.jpg")
		$Egg4.visible = true
		$Egg3.visible = true
		$Egg2.visible = true
		$Egg1.visible = true
	elif game_manager.gem_probability / 64 >= 1:
		change_texture_of_ground("res://textures/rocks.jpg")
		$Egg3.visible = true
		$Egg2.visible = true
		$Egg1.visible = true
	elif game_manager.gem_probability / 16 >= 1:
		change_texture_of_ground("res://textures/snow.jpg")
		$Egg2.visible = true
		$Egg1.visible = true
	elif game_manager.gem_probability / 4 >= 1:
		change_texture_of_ground("res://textures/ice.jpg")
		$Egg1.visible = true
	else:
		change_texture_of_ground("res://textures/marble.jpg")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	get_node("shop/sign").text = str(game_manager.gems) + "💎 " + str(game_manager.coins) + "🟡"
	cafe_sign.text = "🧒" + str(game_manager.user_name)
	var response_json = game_manager.get_last_response()
	if response_json != null:
		cafe_sign.text = "⚔️" + str(int(response_json.player_position)) + "/" + str(int(response_json.all_players_count)) + "\n🧒" + str(game_manager.user_name)
	if present_timer.time_left > 0:
		var minutes := present_timer.time_left / 60
		var seconds := fmod(present_timer.time_left, 60)
		var time_string := "%02d:%02d" % [minutes, seconds]
		present_sign.text = time_string
	else:
		present_sign.text = str(present_coins_count) + "🟡"
		
	if game_manager.can_new_game:
		black_hole_animation.play('new_game')
	else:
		black_hole_animation.play('rotate')
		
func set_music_mode() -> void:
	if game_manager.music_mode == 0:
		get_node("/root/Music").set_stream_paused(true)
		animation_jbl.play("RESET")
		
	if game_manager.music_mode == 1:
		get_node("/root/Music").set_stream_paused(false)
		animation_jbl.play("music_low")
		get_node("/root/Music").set_volume_db(-10.0)
		
	if game_manager.music_mode == 2:
		get_node("/root/Music").set_stream_paused(false)
		animation_jbl.play("music_on")
		get_node("/root/Music").set_volume_db(0.0)
	
	game_manager.save_game()

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			game_manager.music_mode = (game_manager.music_mode - 1)
			if game_manager.music_mode < 0:
				game_manager.music_mode = 2
			set_music_mode()


func _on_magaz_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			camera_pivot.is_panning = false
			camera_pivot.is_panning_2 = false
			get_node("shop/ShopOpen").play()
			var new_shop_scene = shop_scene.instantiate()
			new_shop_scene.game_manager = game_manager
			get_tree().root.add_child(new_shop_scene)

func _on_slime_died() -> void:
	add_coins.start(game_manager.get_coin_count())


func _on_coins_finished() -> void:
	game_manager.add_coins(1)


func _on_slime_autokill() -> void:
	braid_kill.play("kill")
	audio_braid_kill.play()


func _on_game_manager_coin_overflow() -> void:
	if drop_coins.coins_num == 0:
		drop_coins.start(1)

func _on_drop_coins_started() -> void:
	game_manager.add_coins(-1)


func _on_gem_finished() -> void:
	game_manager.add_gems(1)


func _on_cafe_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			camera_pivot.is_panning = false
			camera_pivot.is_panning_2 = false
			cafe_open.play()
			var new_cafe_scene = cafe_scene.instantiate()
			new_cafe_scene.game_manager = game_manager
			
			get_tree().root.add_child(new_cafe_scene)


func _on_send_top_timer_timeout() -> void:
	if last_gems != game_manager.gems || last_coins != game_manager.coins:
		game_manager.get_lidership()

func _on_present_timer_timeout() -> void:
	audio_present_ready.play()
	animation_present.play("Ready")
	if game_manager.music_mode != 0:
		Input.vibrate_handheld(100, 1.0)
	presents_count += 1
	present_coins_count += randi_range(7, 10)
	if present_coins_count > 100:
		present_coins_count = 100


func _on_present_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if present_timer.time_left <= 0:
				animation_present.play("RESET")
				present_timer.start()
				audio_present_open.play()
				if game_manager.music_mode != 0:
					Input.vibrate_handheld(50, 1.0)
				present_coins.start(present_coins_count)


func _on_black_hole_area_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			camera_pivot.is_panning = false
			camera_pivot.is_panning_2 = false
			var new_new_game_scene = new_game_scene.instantiate()
			new_new_game_scene.game_manager = game_manager
			new_new_game_scene.new_game.connect(_on_new_game)
			get_tree().root.add_child(new_new_game_scene)

func _on_new_game() -> void:
	get_tree().reload_current_scene()
