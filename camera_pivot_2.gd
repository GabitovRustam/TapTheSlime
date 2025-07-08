extends Node3D

var is_panning = false
var is_panning_2 = false
var start_position
var start_position_2
var scale_dist

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				scale -= Vector3(0.1, 0.1, 0.1)
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				scale += Vector3(0.1, 0.1, 0.1)
			
			if !is_panning: 
				is_panning = true
				start_position = event.position
			else:
				var df1 = abs(event.position.distance_to(start_position))
				if df1 > 50:
					is_panning_2 = true
					start_position_2 = event.position
					scale_dist = abs(start_position.distance_to(start_position_2))
				else:
					start_position = event.position

		else:
			if !is_panning_2:
				is_panning = false
			else:
				var df1 = abs(event.position.distance_to(start_position))
				var df2 = abs(event.position.distance_to(start_position_2))
				is_panning_2 = false
				if df1 < df2:
					start_position = start_position_2

	if (event is InputEventScreenDrag or event is InputEventMouseMotion):
		if is_panning and !is_panning_2:
			var current_position = event.position
			var delta = current_position - start_position
			rotation -= Vector3(delta.y/300, delta.x/600, 0) # Перемещение камеры
			rotation.x = min(rotation.x, deg_to_rad(60))
			rotation.x = max(rotation.x, -deg_to_rad(60))
			start_position = current_position # Обновляем начальную позицию	
		else:
			if is_panning and is_panning_2:
				var df1 = abs(event.position.distance_to(start_position))
				var df2 = abs(event.position.distance_to(start_position_2))
				if df1 > df2:
					start_position_2 = event.position
				else:
					start_position = event.position
					
				var new_scale_dist = abs(start_position.distance_to(start_position_2))
				var delta_scale = scale_dist/new_scale_dist
				
				scale *= Vector3(delta_scale, delta_scale, delta_scale)
				scale.x = min(scale.x, 3)
				scale.y = min(scale.y, 3)
				scale.z = min(scale.z, 3)
				scale.x = max(scale.x, 0.7)
				scale.y = max(scale.y, 0.7)
				scale.z = max(scale.z, 0.7)
				scale_dist = new_scale_dist
