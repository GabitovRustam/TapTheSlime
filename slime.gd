extends Node

var taps: float = 0
var score: int = 0
var scale: float = 1
var can_grow = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if FileAccess.file_exists("user://savegame.save"):
		var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
		score = int(save_file.get_line())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if can_grow and taps < 10 - delta:
		taps = taps + delta
	if taps >= 10 :
		if can_grow:
			get_node("MeshInstance3D/GPUParticles3D").restart()
		can_grow = false
		get_node("AudioStreamPlayer").play()
		get_node("MeshInstance3D/GPUParticles3D").emitting = true
		get_node("MeshInstance3D/AnimationPlayer").play("new_animation")
	scale = 1 + taps/10.
	get_node("MeshInstance3D").scale = Vector3(scale, scale, scale)
	get_node("MeshInstance3D").position = Vector3(0, taps/20.+0.05, 0)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and can_grow:
			get_node("AudioStreamPlayer2").play()
			taps = taps + 1


func _on_gpu_particles_3d_finished() -> void:
	pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	can_grow = true
	score = score + 1
	taps = 0
	scale = 1 + taps/10.
	get_node("MeshInstance3D").scale = Vector3(scale, scale, scale)
	get_node("MeshInstance3D").position = Vector3(0, taps/20., 0)
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	save_file.store_line(str(score))
