extends EnemyBase



#region Base Variables

var b_health: int = 100
var b_damage: int = 20
var b_speed: float = 60.0
var b_acceleration := 2.5
var slowing_speed := 70.0
	
@onready var jump_height: float = 120.0
@onready var time_to_apex: float = 0.35
@onready var jump_gravity := (2.0 * jump_height) / pow(time_to_apex, 2.0)

#endregion

#region References

@onready var m_sprite: AnimatedSprite2D = $e_sprite
@onready var s_texture = m_sprite.sprite_frames.get_frame_texture("default", 0)
@onready var s_height = s_texture.get_height() / - 2.0
@onready var c_marker: Marker2D = $ChairMarker
@onready var p_anim: AnimationPlayer = $AnimationPlayer

const CHAIR_SCENE = preload("res://scenes/projectiles_scene/chair_skill.tscn")

var c_marker_dir: float

#endregion

#region Combo Base Variables
var is_skill_one_done: bool = false
var is_skill_two_done: bool = false
var is_skill_three_done: bool = false
var is_skill_four_done: bool = false
var is_skill_recovering: bool = false

var can_skill_one: bool = true
var can_skill_two: bool = true
var can_skill_three: bool = true

var skill_bag: Array[int] = []
var available_skills: Array[int] = [1, 2, 3]
var is_recovering: bool = false
var pending_skill := 0



#endregion

#region Signals 
#UI signals
signal send_timers(timer: String, value: float)

#endregion

#region Timers 
@onready var c_one_timer := 0.0:
	set(value):
		if c_one_timer == value: 
			return
		
		send_timers.emit("c_one_timer", value)
		
@onready var c_two_timer := 0.0:
	set(value):
		if c_two_timer == value: 
			return
		
		send_timers.emit("c_two_timer", value)
		
@onready var c_three_timer := 0.0:
	set(value):
		if c_three_timer == value: 
			return
		
		send_timers.emit("c_three_timer", value)
		
@onready var c_four_timer := 0.0:
	set(value):
		if c_four_timer == value: 
			return
		
		send_timers.emit("c_four_timer", value)
		
@onready var recovery_timer := 0.0:
	set(value):
		if recovery_timer == value: 
			return
		
		send_timers.emit("recover_timer", value)

@onready var chase_timer := 0.0:
	set(value):
		if chase_timer == value: 
			return
		
		send_timers.emit("chase_timer", value)

@onready var stunned_timer := 0.0:
	set(value):
		if stunned_timer == value:
			return
		
		send_timers.emit("stunned_timer", value)

#endregion

#region Gate Keepers
var is_transforming := false
var is_hurt := false
var hurt_count := [] #make boss stunned after 3 hits
var is_flying := false 
var is_human := false
var is_demon := false
var is_stunned := false
var is_chasing := false
var is_skilling := false

#endregion

#region Target
@onready var p_target = get_tree().get_first_node_in_group("Player_target")

var slowing_d_radius := 150.0
var stopping_radius := 70.0
var b_max_speed := 100.0


#endregion

func draw_speed_limit() -> void:
	pass

func _ready() -> void:
	if p_target == null:
		push_error("Player does not exist")
	
	find_target()
	
	#launch_chair(CHAIR_SCENE, c_marker.global_position, c_marker_dir)

	
	
func _physics_process(delta: float) -> void:
	handle_boss_logic(delta)
	update_recovery(delta)
	
	move_and_slide()

#region Movement func

func handle_movement() -> void:
	if p_target == null:
		return
	
	var signed_distance = find_target()
	var signed_direction = sign(signed_distance)
	var abs_distance = abs(signed_distance)
	
	chase_target(signed_direction, abs_distance)
	get_m_dis(c_marker)
	

func get_m_dis(marker: Marker2D) -> void:
	
	var marker_dis = marker.global_position.x - global_position.x
	var signed_dir = sign(marker_dis)
	
	pass_marker_dir(signed_dir)

func pass_marker_dir(s_dir: int) -> void:
	if s_dir == 1:
		c_marker_dir = 1
	elif s_dir == -1:
		c_marker_dir = -1
	else:
		print("value is zero")
	

	
#endregion

#region Combo Func

#endregion

#region Timers Func

func reduce_timer(delta: float) -> void:
	
	c_one_timer = set_timer(c_one_timer, delta)
	#if attk_c_timer <= 0.0:
		#close_attack_window()
	#
	stunned_timer = set_timer(stunned_timer, delta)
	c_two_timer = set_timer(c_two_timer, delta)

	c_three_timer = set_timer(c_three_timer, delta)
	c_four_timer = set_timer(c_four_timer, delta)
	recovery_timer = set_timer(recovery_timer, delta)
	

#endregion

#region Boss Logic

func handle_boss_logic(delta: float) -> void:
	if is_skilling:
		velocity.x = 0
		return
	
	if is_recovering:
		velocity.x = 0
		return
	
	var signed_distance = find_target()
	var signed_direction = sign(signed_distance)
	var abs_distance = abs(signed_distance)
	
	if chase_timer > 0.0:
		chase_timer = set_timer(chase_timer, delta)
		handle_movement()
		return
	
	if pending_skill == 0:
		pending_skill = get_next_skill()
	
	if skill_needs_range(pending_skill) and abs_distance > stopping_radius:
		handle_movement()
		return
	
	start_skill(pending_skill)
	pending_skill = 0
	


#endregion


#region Target related func 

func chase_target(dir: float, abs_dis: int) -> void:
	
	if is_skilling:
		return

	var current_speed: float
	
	if abs_dis <= stopping_radius:
		current_speed = 0
		
		velocity.x = current_speed

	elif abs_dis < slowing_d_radius:
		velocity.x = dir * slowing_speed
	
	else:
		current_speed = b_speed * b_acceleration
		velocity.x = dir * current_speed 

	
func find_target() -> float:
	if p_target == null:
		push_error("Player does not Exist")
	
	var target_dis = p_target.global_position.x - global_position.x

	return target_dis
#endregion

#region Skills

func slam() -> void:
	if is_skill_one_done:
		return
	
	is_skilling = true
	play_anim(p_anim, "slam")

	
func launch_chair(scene: PackedScene, pos: Vector2, direction: int) -> void:
	var chair_scene = scene.instantiate()
	chair_scene.global_position = pos
	chair_scene.marker_dir = direction
	
	var projectile_parent = get_tree().current_scene.get_node("Projectiles")
	
	projectile_parent.add_child(chair_scene)
	
	is_skill_two_done = true
	if chase_timer == 0.0:
		chase_timer = 5.0
	
	end_skill_two()
	
	
func slam_directory() -> void:
	print("I slammed something")


#endregion 

#region Handle Skill

func get_next_skill() -> int:

	if skill_bag.is_empty():
		refill_skill_bag()
	
	return skill_bag.pop_front()
	#choose_skill(skill_num)
	
func refill_skill_bag() -> void:
	skill_bag = available_skills.duplicate()
	skill_bag.shuffle()

func choose_skill(skill_num: int) -> void:
	var pending_skill: int
	
	var range_needed = skill_needs_range(skill_num)
	
	if range_needed:
		pending_skill = skill_num
	
	if !range_needed:
		start_skill(skill_num)


func skill_needs_range(skill_num: int) -> bool:
	return skill_num == 1 or skill_num == 2 or skill_num == 4
	
func start_skill(num: int) -> void:
	#Make sure to face character direction first 
	is_skilling = true
	
	match num:
		1:
				slam()
		2:
			launch_chair(CHAIR_SCENE, c_marker.global_position, c_marker_dir)
		3:
			slam_directory()
		_:
			is_skilling = false


	
#endregion

#region Default Signals

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if !is_skilling:
		return
	
	match anim_name:
		"slam":
			end_skill_one()
		_:
			pass

#endregion

#region End Actions

func end_skill() -> void:
	is_skilling = false
	
	if skill_bag.is_empty() and pending_skill == 0:
		start_recovery()
	else:
		chase_timer = 3.0

func start_recovery() -> void:
	is_recovering = true
	recovery_timer = 5.0

func update_recovery(delta: float) -> void:
	if not is_recovering:
		return
	
	recovery_timer = set_timer(recovery_timer, delta)
	
	if recovery_timer <= 0.0:
		is_recovering = false
		

func end_skill_one() -> void:
	is_skilling = false
	is_skill_one_done = true
	can_skill_one = false
	chase_timer = 5.0
	
func end_skill_two() -> void:
	can_skill_two = false

#endregion
