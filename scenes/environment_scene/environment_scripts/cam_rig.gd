extends Node2D

@onready var p_target = get_tree().get_first_node_in_group("Player_target")
@onready var cam: Camera2D = $Cam
@onready var follow_speed := 20.0
@onready var cam_limit = p_target.grab_cam_limits
@onready var boss_target = get_tree().get_first_node_in_group("Boss_target")
@onready var is_boss_room := false

@onready var zoom_out_distance := 250


func _ready() -> void:
	
	#is_boss_room = true
	
	cam.make_current()
	
	if p_target == null:
		push_error("Player does not exist")
		return

	if is_boss_room:
		if boss_target == null:
			print("Boss does not exist")
			return
		
		global_position = get_boss_room_midpoint()
		
	elif p_target:
		global_position = p_target.global_position 
	

func _physics_process(delta: float) -> void:
	var weight = clamp(follow_speed * delta, 0.0, 1.0)
	
	if p_target == null:
		push_error("Player does not exist")
		return
		
	if is_boss_room and p_target and boss_target:
		var current_midpoint = get_boss_room_midpoint()
		global_position = global_position.lerp(current_midpoint, weight)
		handle_camera_zoom(delta)
	elif p_target and !is_boss_room:
		global_position = global_position.lerp(p_target.global_position, weight)
		
	#handle_cam_limits()

func get_boss_room_midpoint() -> Vector2:
	return (p_target.global_position + boss_target.global_position) * 0.5

func handle_camera_zoom(delta) -> void:
	if !is_boss_room:
		return
	
	var distance = p_target.global_position.distance_to(boss_target.global_position)
	
	if distance > zoom_out_distance:
		cam.zoom = cam.zoom.lerp(Vector2(0.8, 0.8), 5.0 * delta)
	else:
		cam.zoom = cam.zoom.lerp(Vector2(1.0, 1.0), 5.0 * delta)
	
func handle_cam_limits() -> void:
	if p_target == null:
		return
	
	if !is_boss_room:
		cam.limit_left = int(p_target.grab_cam_limits()["cam_l_limit"])
		cam.limit_right = int(p_target.grab_cam_limits()["cam_r_limit"])
		cam.limit_bottom = int(p_target.grab_cam_limits()["cam_b_limit"])
		cam.limit_top = int(p_target.grab_cam_limits()["cam_t_limit"])
	else:
		cam.limit_left = -30
		cam.limit_right = 30
		cam.limit_bottom = 20
		cam.limit_top = -40
