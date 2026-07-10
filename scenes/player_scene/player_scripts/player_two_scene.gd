extends PlayerBase

var jump_height := 30.0
@onready var time_to_apex := 0.35

var jump_gravity := (2 * jump_height) / pow(time_to_apex, 2.0)
var jump_velocity := -jump_gravity * time_to_apex
@onready var main_sprite: AnimatedSprite2D = $MainSprite
@export var t_player: Node2D

#add move velocity 

var target_was_moving := false
var target_pos: Vector2 = Vector2.ZERO
var target_dir: Vector2 = Vector2.ZERO

const UP_DIRECTION: Vector2 = Vector2.UP



#region States
enum PlayerTwoState{
	JUMP,
	BLOCK,
	IDLE
}

@onready var p_two_state: PlayerTwoState = PlayerTwoState.IDLE
var is_on_air := false

#endregion

func _ready() -> void:
	t_player = get_tree().get_first_node_in_group("Player_target")
	
	if t_player:
		target_pos = t_player.global_position - position
		target_dir = global_position.direction_to(target_pos)
		
	#if t_player:
		#print(t_player.name)
	#
	#if t_player.p_move_state == PlayerMoveState.IDLE:
		#print("player_idle")

func _physics_process(delta: float) -> void:
	handle_animation()
	#handle_movement(delta)
	handle_follow_player(delta)
	#handle_gravity(delta)
	move_and_slide()

func handle_animation() -> void:
	
	match t_player.p_move_state:
		PlayerMoveState.IDLE:
			play_anim(main_sprite, "idle")
		PlayerMoveState.RUN:
			play_anim(main_sprite, "walk")
		PlayerMoveState.JUMP:
			play_anim(main_sprite, "jump")


func handle_movement(delta: float) -> void:

	var target_is_moving = abs(t_player.velocity.x) > 0.1
	
	#create guard

	if target_is_moving and not target_was_moving and is_on_floor():
		velocity.y = jump_velocity
		p_two_state = PlayerTwoState.JUMP

	target_was_moving = target_is_moving
	
func handle_gravity(delta: float) -> void:
	if is_on_floor():
		return
	
	var current_gravity: float
	
	if velocity.y < 0.0:
		current_gravity = -30.0
	
	velocity.y += current_gravity * delta

func handle_follow_player(delta: float) -> void:
		if t_player == null:
			return
		
		velocity.x = target_dir.x * delta
	
