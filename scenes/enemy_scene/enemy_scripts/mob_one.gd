extends EnemyBase

#region Declared Vars
#region Base Vars

var health: float = 0.0
var speed: float = 60.0
var damage: float = 0.0

#endregion

#region Movement related

var patrol_distance: float = 100.0
var starting_pos: Vector2
var patrol_dir: int = 1

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


func _ready() -> void:
	starting_pos = global_position


func _physics_process(delta: float) -> void:
	patrol_idle()
	move_and_slide()


func patrol_idle() -> void:
	var right_limit := starting_pos.x + patrol_distance
	var left_limit := starting_pos.x - patrol_distance
	
	if global_position.x >= right_limit:
		patrol_dir = -1
	
	elif global_position.x <= left_limit:
		patrol_dir = 1
	
	velocity.x = patrol_dir * speed
