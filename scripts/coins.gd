extends Node

@export var target: Node3D
@export var speed: int
@export var delay: float
@export var gem_probability: float
@export var game_manager: Node

signal finished
signal gem_finished
signal started

@export var coins_num: int = 0
var timer: float = 0

const coin_scene: PackedScene = preload("res://scenes/coin.tscn")
const gem_scene: PackedScene = preload("res://scenes/gem.tscn")

func start(count: int) -> void:
	coins_num += count

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var random = RandomNumberGenerator.new()
	random.randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if coins_num == 0:
		timer = delay
	else:
		timer -= delta
		
	if coins_num > 0 && timer <= 0:
		timer = delay
		started.emit()
		var probability = gem_probability * game_manager.gem_probability
		if probability > 0.2:
			probability = 0.2
		if randf_range(0, 1) > probability:
			coins_num -= 1
			var new_coin = coin_scene.instantiate()
			new_coin.target = target
			new_coin.speed = speed
			new_coin.finished.connect(_on_coin_finished)
			add_child(new_coin)
			new_coin.start()
		else:
			var new_gem = gem_scene.instantiate()
			new_gem.target = target
			new_gem.speed = speed
			new_gem.finished.connect(_on_gem_finished)
			add_child(new_gem)
			new_gem.start()
	
func _on_coin_finished() -> void:
	if game_manager.music_mode != 0:
		Input.vibrate_handheld(50, 1.0)
	finished.emit()

func _on_gem_finished() -> void:
	if game_manager.music_mode != 0:
		Input.vibrate_handheld(100, 1.0)
	gem_finished.emit()
