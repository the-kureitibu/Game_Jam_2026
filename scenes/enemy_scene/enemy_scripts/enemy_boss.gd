extends EnemyBase



#region Base Variables

var b_health: int = 100
var b_damage: int = 20
var b_speed: float = 50.0
var b_acceleration := 60.0
var slowing_speed := 20.0
	
@onready var jump_height: float = 120.0
@onready var time_to_apex: float = 0.35
@onready var jump_gravity := (2.0 * jump_height) / pow(time_to_apex, 2.0)

#endregion

#region References

@onready var m_sprite: AnimatedSprite2D = $e_sprite
@onready var s_texture = m_sprite.sprite_frames.get_frame_texture("default", 0)
@onready var s_height = s_texture.get_height() / - 2.0
@onready var r_marker: Marker2D = $RadiusTarget

#endregion

#region Combo Base Variables
var is_combo_one: bool = false
var is_combo_two: bool = false
var is_combo_three: bool = false
var is_combo_four: bool = false
var is_combo_recovery: bool = false

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
		
@onready var recover_timer := 0.0:
	set(value):
		if recover_timer == value: 
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

#endregion

#region Target
@onready var p_target = get_tree().get_first_node_in_group("Player_target")

var slowing_d_radius := 400.0
var stopping_radius := 200.0
var b_max_speed := 100.0


#endregion

func draw_speed_limit() -> void:
	pass

func _ready() -> void:
	if p_target == null:
		push_error("Player does not exist")
	
	find_target()
	

#
#func _draw() -> void:
	#var text_center = global_position + Vector2(0, s_height)
	#print(text_center)
	#
	#draw_circle(text_center, 100.0, Color.RED, false, 3.0)
#
#func _process(delta: float) -> void:
	#queue_redraw()
	
	
func _physics_process(delta: float) -> void:
	handle_movement()
	
	move_and_slide()

#region Movement func

func handle_movement() -> void:
	if p_target == null:
		return
	
	var signed_distance = find_target()
	var signed_direction = sign(signed_distance)
	var abs_distance = abs(signed_distance)
	print(signed_direction)
	
	chase_target(signed_direction, abs_distance)

	

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
	recover_timer = set_timer(recover_timer, delta)
	

#endregion

#region Target related func 

func chase_target(dir: float, abs_dis: int) -> void:
	
	var l_weight = clamp(global_position.x, 0, 1.0)
	var current_speed: float
	
	
	if abs_dis <= stopping_radius:
		current_speed = 0
		
		velocity.x = current_speed
		
	elif abs_dis < slowing_d_radius:
		velocity.x = dir * slowing_speed
	
	else:
		velocity.x = dir * b_speed
		print(velocity.x)
		
func find_target() -> float:
	if p_target == null:
		push_error("Player does not Exist")
	
	var target_dis = p_target.global_position.x - global_position.x

	return target_dis

#endregion
