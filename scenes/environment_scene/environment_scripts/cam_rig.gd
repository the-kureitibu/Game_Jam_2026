extends Node2D

@onready var p_target = get_tree().get_first_node_in_group("Player_target")
@onready var cam: Camera2D = $Cam
@onready var follow_speed := 20.0
@onready var cam_limit = p_target.grab_cam_limits

func _ready() -> void:
	
	
	cam.make_current()
	
	if p_target == null:
		push_error("Player does not exist")
	
	if p_target:
		global_position = p_target.global_position 
		
		print(p_target.grab_cam_limits()["cam_l_limit"])
	
func _physics_process(delta: float) -> void:
	var weight = clamp(follow_speed * delta, 0.0, 1.0)
	
	if p_target == null:
		push_error("Player does not exist")
		return
	
	global_position = global_position.lerp(p_target.global_position, weight)
