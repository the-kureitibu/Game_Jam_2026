extends EnemyBase

#region Declared Vars
#region Base Vars

var health: float = 0.0
var speed: float = 60.0
var damage: float = 0.0


#endregion

#region Movement related

var to_left_max_dis: float = abs(-100.0)
var to_right_max_dis: float = abs(100.0)
var to_left_target: Vector2 = Vector2(-100.0, 0)
var to_right_target: Vector2 = Vector2(100.0, 0)
var to_right: bool = false
var to_left: bool = false
var left_dir: Vector2 = Vector2.LEFT
var right_dir: Vector2 = Vector2.RIGHT

var reached_right: bool = false
var reached_left: bool = false
var is_traveling: bool = false
var starting_pos: Vector2 = Vector2.ZERO
var facing_dir: int = 1

@onready var jump_height := 100.0
@onready var time_to_apex := 0.35
@onready var time_to_fall := 0.25
@onready var apex_threshold := 35.0
@onready var apex_gravity_multiplier := 0.25
@onready var jump_gravity := (2.0 * jump_height) / pow(time_to_apex, 2.0)
@onready var fall_gravity := (2.0 * jump_height) / pow(time_to_fall, 2.0)

@onready var jump_velocity := -jump_gravity * time_to_apex



#region References

@onready var t_player: Node2D = get_tree().get_first_node_in_group("Player_target")

#endregion

#region States
@onready var mob_one_state: EnemyBase.MobStates = MobStates.IDLE

#endregion

#endregion
#endregion 

#region Tests 
func _draw() -> void:
	draw_circle(Vector2(0, 0), 200.0, Color.RED, false, -2.0)
#endregion

#region Processes

func _ready() -> void:
	starting_pos = global_position
	
	print(starting_pos.distance_to(to_right_target), " starting pos distance to")
	print(to_right_max_dis, " To right max dis")
	
func _physics_process(delta: float) -> void:


	velocity.x = 1.0 * speed 
		
	move_and_slide()

func handle_movement(delta) -> void:
	if mob_one_state == MobStates.ATTACKING or mob_one_state == MobStates.HURT:
		return 
	
	start_idle_moving(delta)

func start_idle_moving(delta) -> void:
	print("Got here?")
	#if !mob_one_state == MobStates.IDLE:
		#return 
	#

	
	#if facing_dir == 1 and !reached_right:
		#print('second line worked')
		#if starting_pos.distance_to(to_right_target) < to_right_max_dis:
			#print(starting_pos.distance_to(to_right_target), " starting pos distance to")
			#print(to_right_max_dis, " To right max dis")
			#
			#var signed_dist = global_position.distance_to(to_right_target)
			#var signed_dir = sign(signed_dist)
			#
	#
			
		

func decide_side() -> void:
	var signed_dist = global_position.distance_to(to_right_target)
	var signed_dir = sign(signed_dist)
	
	if signed_dist <= to_right_max_dis:
		is_traveling = false
		reached_right = true
		#sprite flip
		facing_dir = signed_dir

	elif signed_dist <= to_left_max_dis:
		is_traveling = false
		reached_left = true
		#sprite flip
		facing_dir = signed_dir

#endregion
	
