extends Node
class_name Gem

@export var target: Node3D
@export var speed: int

signal finished

var velocity: Vector3
var time: float
var rotate: float

@onready var gem_mesh: MeshInstance3D = $gem_mesh
@onready var new_gem_audio: AudioStreamPlayer = $new_gem_audio
@onready var get_gem_audio: AudioStreamPlayer = $get_gem_audio

func start() -> void:
	velocity = Vector3(randf_range(-1, 1), 1, randf_range(-1, 1)).normalized() * speed
	rotate = 0
	time = 0
	gem_mesh.position = Vector3(0, 0, 0)
	gem_mesh.visible = true
	new_gem_audio.play()
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var random = RandomNumberGenerator.new()
	random.randomize()
	gem_mesh.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Если нас не запускали, то ничего не делаем
	if !gem_mesh.visible:
		return
	
	# Если дошли до цели, то пора заканчивать	
	if gem_mesh.global_position.distance_to(target.global_position) < 1 || time > 2:
		gem_mesh.visible = false
		get_gem_audio.play()
		finished.emit()
		return
		
	# Иначе продолжаем лететь к цели
	time += delta
	var new_velocity = (velocity * (1 - time) + (target.global_position - gem_mesh.global_position).normalized() * speed * time) * delta
	gem_mesh.position += new_velocity
	rotate += 6*delta
	gem_mesh.look_at(new_velocity.normalized())
	gem_mesh.rotation.x = rotate

func _on_get_gem_audio_finished() -> void:
	queue_free()
