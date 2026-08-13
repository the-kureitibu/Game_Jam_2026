extends Node2D

@onready var p_target = get_tree().get_first_node_in_group("Player_target")
@onready var cam: Camera2D = $Cam
@onready var follow_speed := 20.0
#@onready var cam_limit = p_target.grab_cam_limits
@onready var boss_target = get_tree().get_first_node_in_group("Boss_target")

@onready var zoom_out_distance := 250

#region Level Types

@onready var level_finder = get_tree().current_scene.name

@onready var is_tutorial_level: bool = false
@onready var is_grassland_level: bool = false
@onready var is_demonrealm_level: bool = false
@onready var is_boss_room_level: bool = false
@onready var is_michael_room: bool = false


#endregion



func _ready() -> void:
	
	cam.make_current()
	
	determine_level_scene(level_finder)
	
	if p_target == null:
		push_error("Player does not exist")
		return

	if is_boss_room_level:
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
		
	if is_boss_room_level and p_target and boss_target:
		var current_midpoint = get_boss_room_midpoint()
		global_position = global_position.lerp(current_midpoint, weight)
		handle_camera_zoom(delta)
	elif p_target and !is_boss_room_level:
		global_position = global_position.lerp(p_target.global_position, weight)
		


func get_boss_room_midpoint() -> Vector2:
	return (p_target.global_position + boss_target.global_position) * 0.5

func handle_camera_zoom(delta) -> void:
	if !is_boss_room_level:
		return
	
	var distance = p_target.global_position.distance_to(boss_target.global_position)
	
	if distance > zoom_out_distance:
		cam.zoom = cam.zoom.lerp(Vector2(0.8, 0.8), 5.0 * delta)
	else:
		cam.zoom = cam.zoom.lerp(Vector2(1.0, 1.0), 5.0 * delta)
	
func handle_cam_limits(limit_l: int, limit_r: int, 
			limit_b: int, limit_t: int, ) -> void:
	
	if p_target == null:
		return
	
	cam.limit_left = limit_l
	cam.limit_right = limit_r
	cam.limit_bottom = limit_b
	cam.limit_top = limit_t

func determine_level_scene(lvl_name: Variant) -> void:
	
	if p_target == null:
		return
	
	match lvl_name:
		"TutorialLevel":
			handle_cam_limits(0, 640, 63, -400)
			is_tutorial_level = true
			cam.offset = Vector2(0, -20.0)
			
		"GrassLandLevel":
			handle_cam_limits(0, 8291, 88, -1050)
			is_grassland_level = true
		
		"BossRoom":
			handle_cam_limits(0, 1584, 88, -434)
			is_boss_room_level = true
			
		"DemonRealmLevel":
			handle_cam_limits(0, 2399, 766, -620)
			is_demonrealm_level = true
			
		"MichaelRoom":
			handle_cam_limits(0, 833, 63, -465)
			is_michael_room = true
