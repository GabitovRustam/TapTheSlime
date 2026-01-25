extends Node

var taps: float = 0
var scale: float = 1
var can_grow = true

signal died
signal autokill 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var random = RandomNumberGenerator.new()
	random.randomize()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if can_grow:
		taps = taps + GameManager.get_grow_speed() * delta
		if taps >= 10:
			if GameManager.has_auto_kill():
				autokill.emit()
				_kill()
			else:
				taps = 9.99
	scale = 1 + taps/10.
	get_node("MeshInstance3D").scale = Vector3(scale, scale, scale)
	get_node("MeshInstance3D").position = Vector3(0, taps/20.+0.05, 0)

func _kill() -> void:
	get_node("AudioStreamPlayer").play()
	if GameManager.music_mode != 0:
		Input.vibrate_handheld(200, 1.0)
	died.emit()
	if can_grow:
		get_node("MeshInstance3D/GPUParticles3D").restart()
	can_grow = false
	get_node("MeshInstance3D/AnimationPlayer").play("new_animation")
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	can_grow = true
	taps = 0
	scale = 1 + taps/10.
	get_node("MeshInstance3D").scale = Vector3(scale, scale, scale)
	get_node("MeshInstance3D").position = Vector3(0, taps/20., 0)

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and can_grow:
			taps = taps + GameManager.get_click_power()
			get_node("AudioStreamPlayer2").play()
			if taps >= 10 :
				_kill()
