extends EnemyBase

#region Declared Vars
#region Base Vars

var health: float = 0.0
var speed: float = 60.0
var damage: float = 0.0
var target_x: float = 0.0

#endregion

#region Movement related

var patrol_distance: float = 100.0
var starting_x: float
var patrol_dir: int = 1
var is_target_nearby: bool = false

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
	
	draw_circle(Vector2(0, 0), 100.0, Color.RED, false, -2.0)

#endregion


func _ready() -> void:
	starting_x = global_position.x
	target_x = starting_x + patrol_distance
	patrol_dir = 1


func _physics_process(delta: float) -> void:
	queue_redraw()
	patrol_idle()
	apply_gravity(delta)
	jump_to_target()
	
	move_and_slide()
	check_target_nearby()

func check_target_nearby() -> void:
	var dis_to_player = t_player.global_position.x - target_x
	var signed_dis = sign(dis_to_player)
	print(patrol_dir, " :patrol dir")
	print(signed_dis, " :signed dis")
	
	if patrol_dir == signed_dis and dis_to_player < target_x:
		print("This worked")

	

func patrol_idle() -> void:
	var distance_to_target := target_x - global_position.x
	patrol_dir = sign(distance_to_target)
	print("Patrol dir in idle: ", patrol_dir)
	
	if abs(distance_to_target) <= 2.0:
		if target_x > starting_x:
			target_x = starting_x - patrol_distance
		else:
			target_x = starting_x + patrol_distance
	#
	#if is_target_nearby():
		#velocity.x = 0.0 * speed
	#else:
	velocity.x = patrol_dir * speed
	#

func jump_to_target() -> void:
	if t_player == null:
		return 
	
	var dis_to_player = t_player.global_position.x - global_position.x
	var signed_dir = sign(dis_to_player)
	var abs_dis = abs(dis_to_player)
	
	if abs_dis < target_x:
		velocity.y += 100.0


func apply_gravity(delta) -> void:

	if is_on_floor():
		return
	
	var current_gravity: float
	
	if velocity.y < 0.0:
		current_gravity = jump_gravity
	else:
		current_gravity = fall_gravity
	
	if abs(velocity.y) < apex_threshold:
		current_gravity *= apex_gravity_multiplier
		
	velocity.y += current_gravity * delta
