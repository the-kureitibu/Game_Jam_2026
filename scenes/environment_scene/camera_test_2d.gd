extends Camera2D

#var cam_move_speed: float = 150.0
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#
	#var i: Vector2 = Input.get_vector("left", "right", "up", "down")
#
	#position += i * cam_move_speed * delta
#

@export var test_speed := 150.0
@export var follow_speed := 5.0

var fake_player_pos := Vector2(0, 150.0)

func _physics_process(delta: float) -> void:
	#var input_dir := Input.get_axis("left", "right")
	var input_dir := Input.get_vector("left", "right", "up","down" )
	#fake_player_pos.x += input_dir * test_speed * delta
	fake_player_pos += input_dir * test_speed * delta

	
	global_position = global_position.lerp(
		fake_player_pos,
		clamp(follow_speed * delta, 0.0, 1.0)
	)
