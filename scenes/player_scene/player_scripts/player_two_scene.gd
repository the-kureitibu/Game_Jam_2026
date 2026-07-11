extends PlayerBase

const UP_DIRECTION: Vector2 = Vector2.UP

@onready var main_sprite: AnimatedSprite2D = $MainSprite
@onready var jump_height := 30.0
@onready var time_to_apex := 0.35

@onready var jump_gravity := (2 * jump_height) / pow(time_to_apex, 2.0)
@onready var jump_velocity := -jump_gravity * time_to_apex

#region Target player related

@onready var t_player: Node2D
var target_was_moving := false
var to_target_speed := 120.0
@export var follow_offset := Vector2(60.0, 0.0)
@export var follow_stop_distance := 4.0
var is_blocking_player: bool = false
var p_blocked: bool

#endregion

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


func _physics_process(delta: float) -> void:
	handle_animation()
	handle_movement(delta)
	handle_follow_player(delta)
	handle_player_blocking()
	handle_gravity(delta)
	move_and_slide()
	

func handle_animation() -> void:
	if is_blocking_player:
		return
	
	match t_player.p_move_state:
		PlayerMoveState.IDLE:
			play_anim(main_sprite, "idle")
		PlayerMoveState.RUN:
			play_anim(main_sprite, "walk")
		PlayerMoveState.JUMP:
			play_anim(main_sprite, "jump")


func handle_movement(delta: float) -> void:

	var target_is_moving = abs(t_player.velocity.x) > 0.1


	if target_is_moving and not target_was_moving and is_on_floor():
		velocity.y = jump_velocity
		p_two_state = PlayerTwoState.JUMP

	target_was_moving = target_is_moving
	
func handle_gravity(delta: float) -> void:
	if is_on_floor():
		return
	
	var current_gravity: float = jump_gravity

	velocity.y += current_gravity * delta
	

func handle_follow_player(delta: float) -> void:
	if t_player == null:
			return
	
	var p_facing_dir: int
	
	if "facing_dir" in t_player:
		p_facing_dir = t_player.facing_dir
	
	var target_pos := t_player.global_position + (follow_offset * p_facing_dir)
	var distance_x := target_pos.x - global_position.x
	
	if abs(distance_x) < follow_stop_distance: 
		velocity.x = 0.0
	else:
		velocity.x = sign(distance_x) * to_target_speed 

func handle_player_blocking() -> void:
	
	if "is_blocking" in t_player:
		p_blocked = t_player.is_blocking
	
	if p_blocked == false:
		return
	
	is_blocking_player = true
	start_blocking_player()
	
func start_blocking_player() -> void:
	p_two_state = PlayerTwoState.BLOCK
	play_anim(main_sprite, "block")

func force_next_animation() -> void:
	match t_player.p_move_state:
		PlayerMoveState.IDLE:
			play_anim(main_sprite, "idle")
		PlayerMoveState.RUN:
			play_anim(main_sprite, "walk")
		PlayerMoveState.JUMP:
			play_anim(main_sprite, "jump")

func _on_main_sprite_animation_finished() -> void:
	is_blocking_player = false
	SignalHub.blocking_anim_done.emit()
	
	force_next_animation()
