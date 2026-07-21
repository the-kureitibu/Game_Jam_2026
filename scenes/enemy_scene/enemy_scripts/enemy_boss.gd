extends EnemyBase


#region Base Variables

var b_health: int = 100
var b_damage: int = 20
var b_speed: float = 120.0

@onready var jump_height: float = 120.0
@onready var time_to_apex: float = 0.35
@onready var jump_gravity := (2.0 * jump_height) / pow(time_to_apex, 2.0)


#endregion

#region Target
@onready var p_target = get_tree().get_first_node_in_group("Player_target")

#endregion

func _ready() -> void:
	if p_target == null:
		push_error("Player does not exist")

func _physics_process(delta: float) -> void:
	pass


func handle_movement() -> void:
	pass
