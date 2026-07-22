extends EnemyBase


#draw the limit files first 

#region Base Variables

var b_health: int = 100
var b_damage: int = 20
var b_speed: float = 40.0

@onready var jump_height: float = 120.0
@onready var time_to_apex: float = 0.35
@onready var jump_gravity := (2.0 * jump_height) / pow(time_to_apex, 2.0)

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

var slowing_d_radius := 200.0
var stopping_radius := 0.0
var b_max_speed := 100.0


#endregion

func _ready() -> void:
	if p_target == null:
		push_error("Player does not exist")
	
	find_target()

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	
	move_and_slide()

#region Movement func

func handle_movement(delta: float) -> void:
	if p_target == null:
		return
	
	var target_distance = find_target()
	var target_direction = target_distance
	
	chase_target(target_direction, delta)
	
	

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

func chase_target(dir: float, delta: float) -> void:
	
	velocity.x = dir * b_speed * delta
	

func find_target() -> float:
	if p_target == null:
		push_error("Player does not Exist")
	
	var target_dis = p_target.global_position.x - global_position.x
	print("Boss is ", target_dis, " from Player")
	
	return target_dis

#endregion
