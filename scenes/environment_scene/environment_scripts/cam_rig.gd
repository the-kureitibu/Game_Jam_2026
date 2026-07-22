extends Node2D

@onready var p_target = get_tree().get_first_node_in_group("Player_target")
@onready var cam: Camera2D = $Cam
@onready var follow_speed := 20.0
@onready var cam_limit = p_target.grab_cam_limits
@onready var is_boss_room := false

func _ready() -> void:
	
	
	cam.make_current()
	
	if p_target == null:
		push_error("Player does not exist")
	
	if p_target:
		global_position = p_target.global_position 
	

func _physics_process(delta: float) -> void:
	var weight = clamp(follow_speed * delta, 0.0, 1.0)
	
	if p_target == null:
		push_error("Player does not exist")
		return
		
	
	global_position = global_position.lerp(p_target.global_position, weight)
	#handle_cam_limits()

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
