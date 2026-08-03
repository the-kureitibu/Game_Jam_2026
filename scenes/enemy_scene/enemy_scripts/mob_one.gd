extends EnemyBase

#region Declared Vars
#region Base Vars

var health: float = 0.0
var speed: float = 60.0
var damage: float = 0.0
var target_x: float = 0.0
var is_attacking: bool = false


#endregion

#region Movement related

var patrol_distance: float = 100.0
var starting_x: float
var patrol_dir: int = 1
var is_target_nearby: bool = false

@onready var jump_height := 70.0
@onready var time_to_apex := 0.35
@onready var time_to_fall := 0.25
@onready var apex_threshold := 35.0
@onready var apex_gravity_multiplier := 0.25
@onready var jump_gravity := (2.0 * jump_height) / pow(time_to_apex, 2.0)
@onready var fall_gravity := (2.0 * jump_height) / pow(time_to_fall, 2.0)

@onready var jump_velocity := -jump_gravity * time_to_apex

var jump_attack_speed_min := 120.0
var jump_attack_speed_max := 360.0
var landing_offset := 24.0

#region References

@onready var t_player: Node2D = get_tree().get_first_node_in_group("Player_target")

#endregion

#region Timers
@onready var attk_timer := 0.0
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
	apply_gravity(delta)
	
	if mob_one_state == MobStates.ATTACKING:
		pass
	elif is_target_nearby:
		jump_to_target()
	else:
		patrol_idle()
	
	move_and_slide()
	check_target_nearby()
	update_attack_state(delta)

func check_target_nearby() -> void:
	if t_player == null:
		return
	
	var dis_to_player = t_player.global_position.x - global_position.x
	var dir_to_player = sign(dis_to_player)
	var abs_dis = abs(dis_to_player)
	
	var detection_range := 100.0

	if abs_dis <= detection_range and dir_to_player == patrol_dir:
		is_target_nearby = true
	else:
		is_target_nearby = false
		

func patrol_idle() -> void:

	var distance_to_target := target_x - global_position.x
	patrol_dir = sign(distance_to_target)
	
	if abs(distance_to_target) <= 2.0:
		if target_x > starting_x:
			target_x = starting_x - patrol_distance
		else:
			target_x = starting_x + patrol_distance
	
	velocity.x = patrol_dir * speed
	

func jump_to_target() -> void:

	if t_player == null:
		return 
	
	if not is_on_floor():
		return

	if mob_one_state == MobStates.ATTACKING: 
		return
	
	is_attacking = true
	mob_one_state = MobStates.ATTACKING
	
	var dis_to_player = t_player.global_position.x - global_position.x
	var dir_to_player = sign(dis_to_player)
	
	if dir_to_player == 0:
		dir_to_player = patrol_dir
		
	# Land near the player, not exactly on center.
	var target_landing_x = t_player.global_position.x - dir_to_player * landing_offset
	var distance_to_landing = target_landing_x - global_position.x
	
	# Approximate total air time.
	var estimated_air_time := time_to_apex + time_to_fall
	
	var needed_x_speed = distance_to_landing / estimated_air_time
	needed_x_speed = clamp(needed_x_speed, -jump_attack_speed_max, jump_attack_speed_max)
	
	if abs(needed_x_speed) < jump_attack_speed_min:
		needed_x_speed = dir_to_player * jump_attack_speed_min
	
	velocity.x = needed_x_speed
	velocity.y = jump_velocity
	
	attk_timer = 3.0



func apply_gravity(delta) -> void:

	if is_on_floor():
		return
	
	var current_gravity: float
	
	if velocity.y < 0.0:
		current_gravity = jump_gravity
	else:
		current_gravity = fall_gravity
	
	velocity.y += current_gravity * delta

func update_attack_state(delta) -> void:
	if not is_attacking:
		return
	
	attk_timer -= delta
	
	if is_on_floor() and velocity.y >= 0.0 and attk_timer <= 2.8:
		end_attack()
	elif attk_timer <= 0.0:
		end_attack()


func end_attack() -> void:
	is_attacking = false
	mob_one_state = MobStates.IDLE
