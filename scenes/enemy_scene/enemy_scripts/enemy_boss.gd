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
@onready var bf_marker: Marker2D = $BookFMarker
@onready var p_anim: AnimationPlayer = $AnimationPlayer

@onready var c_marker_base_x = abs(c_marker.position.x)
@onready var bf_marker_base_x = abs(bf_marker.position.x)


const CHAIR_SCENE = preload("res://scenes/projectiles_scene/chair_skill.tscn")
const BOOK_FALL_SCENE = preload("res://scenes/projectiles_scene/book_fall_skill.tscn")

var c_marker_dir: float

#endregion

#region Combo Base Variables

var skill_bag: Array[int] = []
var available_skills: Array[int] = [1, 2, 3]
var available_shots: Array[int] = [1, 2, 3]
var chair_shots_fired := 0
const MAX_CHAIR_SHOTS := 3
const CHAIR_SHOT_INTERVAL := 1.5

var is_recovering: bool = false
var pending_skill := 0


#endregion

#region Signals 
#UI signals
signal send_timers(timer: String, value: float)

#endregion

#region Timers 

@onready var recovery_timer := 0.0:
	set(value):
		var new_value = max(value, 0.0)
		
		if recovery_timer == new_value:
			return
		
		recovery_timer = new_value
		
		send_timers.emit("recover_timer", value)

@onready var chase_timer := 0.0:
	set(value):
		var new_value = max(value, 0.0)
		
		if chase_timer == new_value:
			return
		
		chase_timer = new_value
		send_timers.emit("chase_timer", chase_timer)

@onready var stunned_timer := 0.0:
	set(value):
		var new_value = max(value, 0.0)
		
		if stunned_timer == new_value:
			return
		
		stunned_timer = new_value
		
		send_timers.emit("stunned_timer", value)

@onready var shots_timer := 0.0:
	set(value):
		var new_value = max(value, 0.0)
		
		if shots_timer == new_value:
			return
		
		shots_timer = new_value
		

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
var is_shooting := false

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
	
	print("Number of shots ", chair_shots_fired)
	#launch_chair(CHAIR_SCENE, c_marker.global_position, c_marker_dir)

	
	
func _physics_process(delta: float) -> void:
	handle_boss_logic(delta)
	update_chair_skill(delta)
	update_recovery(delta)
	
	move_and_slide()
	
	#if chase_timer > 0.0:
		#print("Chase timer ", chase_timer)
	#
	#if recovery_timer > 0.0:
		#print("Recovery timer ", recovery_timer) # - this guy was named chase lmao



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


#region Target related func 

func chase_target(dir: float, abs_dis: float) -> void:
	
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


#region Boss Logic

func handle_boss_logic(delta: float) -> void:
	var signed_distance = find_target()
	var signed_direction = sign(int(signed_distance))
	var abs_distance = abs(signed_distance)
	
	if signed_direction != 0:
		var boss_facing_dir = signed_direction
		m_sprite.flip_h = signed_direction == 1
		
		c_marker.position.x = c_marker_base_x * boss_facing_dir
		bf_marker.position.x = bf_marker_base_x * boss_facing_dir

	if is_skilling:
		velocity.x = 0
		return
	
	if is_shooting:
		velocity.x = 0
		return
	
	if is_recovering:
		handle_movement()
		return
	
	
	if chase_timer > 0.0:
		chase_timer = set_timer(chase_timer, delta)
		handle_movement()
		return
	
	if pending_skill == 0:
		pending_skill = get_next_skill()
	
	if skill_needs_range(pending_skill) and abs_distance > stopping_radius:
		handle_movement()
		return
	
	
	var skill_to_start = pending_skill
	
	pending_skill = 0
	start_skill(skill_to_start)
	

#endregion


#region Skills

func fall_book(scene: PackedScene, pos: Vector2) -> void:

	is_skilling = true
	
	var book_scene = scene.instantiate()

	book_scene.global_position = pos
	
	var book_parent = get_tree().current_scene.get_node("Projectiles")
	book_parent.add_child(book_scene)
	
	if book_scene.is_inside_tree():
		book_scene.anim_done.connect(end_skill)
		

func start_chair_skill() -> void:
	is_skilling = true
	is_shooting = true
	chair_shots_fired = 0
	shots_timer = 0.0

func update_chair_skill(delta) -> void:
	
	if !is_shooting:
		return
	
	shots_timer = set_timer(shots_timer, delta)
	
	if shots_timer > 0.0:
		return

	launch_chair(CHAIR_SCENE, c_marker.global_position, c_marker_dir)
	chair_shots_fired += 1

	if chair_shots_fired >= MAX_CHAIR_SHOTS:
		end_skill()
	else: 
		shots_timer = CHAIR_SHOT_INTERVAL

	
func launch_chair(scene: PackedScene, pos: Vector2, direction: int) -> void:
	is_skilling = true
	is_shooting = true
	
	var chair_scene = scene.instantiate()
	chair_scene.global_position = pos
	chair_scene.marker_dir = direction
	
	var projectile_parent = get_tree().current_scene.get_node("Projectiles")
	
	projectile_parent.add_child(chair_scene)

	print(" I throw chair")
	shots_timer = 1.5
	print("Shots timer refilled? ", shots_timer)
	
	
func slam_directory() -> void:
	is_skilling = true
	
	print("I slammed something")
	end_skill()


#endregion 

#region Handle Skill

func get_next_skill() -> int:
	print("BEFORE get_next_skill, bag: ", skill_bag)
	if skill_bag.is_empty():
		print("BAG EMPTY, REFILLING")
		refill_skill_bag()
	
	var skill = skill_bag.pop_front()
	print("PICKED SKILL: ", skill, " | BAG AFTER PICK: ", skill_bag)
	return skill

func refill_skill_bag() -> void:
	skill_bag = available_skills.duplicate()
	skill_bag.shuffle()

func skill_needs_range(skill_num: int) -> bool:
	return skill_num == 1 or skill_num == 3 or skill_num == 4
	
func start_skill(num: int) -> void:
	is_skilling = true
	
	match num:
		1:
			fall_book(BOOK_FALL_SCENE, bf_marker.global_position)
		2:
			start_chair_skill()
		3:
			slam_directory()
		_:
			is_skilling = false



#endregion




#region Default Signals

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pass

#endregion

#region End Actions

func end_skill() -> void:
	is_skilling = false
	is_shooting = false

	print("bag now: ", skill_bag)
	
	if skill_bag.is_empty() and pending_skill == 0:
		start_recovery()
	else:
		chase_timer = 3.0

func start_recovery() -> void:
	is_recovering = true
	recovery_timer = 3.0


func update_recovery(delta: float) -> void:
	if not is_recovering:
		return
	
	recovery_timer = set_timer(recovery_timer, delta)
	
	if recovery_timer <= 0.0:
		is_recovering = false
		

#endregion


#region Timers Func

func reduce_timer(delta: float) -> void:

	stunned_timer = set_timer(stunned_timer, delta)
	recovery_timer = set_timer(recovery_timer, delta)
	

#endregion
