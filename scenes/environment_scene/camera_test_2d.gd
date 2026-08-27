extends Camera2D

var cam_move_speed: float = 150.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var i: Vector2 = Input.get_vector("left", "right", "up", "down")

	position += i * cam_move_speed * delta
