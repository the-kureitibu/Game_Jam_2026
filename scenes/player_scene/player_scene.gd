extends PlayerBase

#region Base Vars

@export var stats: PlayerStats 
@export var p_heath: int 
@export var p_speed: float
@export var p_damage: int
@export var r_amount: int
@export var r_per_attk: int
@export var p_sprite: Sprite2D
@export var p_jump_h: float
@export var p_move_state: PlayerBase.PlayerMoveState = PlayerMoveState.IDLE
@export var p_action_state: PlayerBase.PlayerActionState = PlayerActionState.NONE
@export var p_gravity: float = -680.0

var p_direction: float = 0.0
var can_dash: bool 


#endregion 

#region Consts

const UP_DIRECTION: Vector2 = Vector2.UP

#endregion

#region Timers

@export var attk_c_timer: float = 0.0 
@export var d_timer: float = 0.0
@export var r_timer: float = 0.0
@export var r_cd_timer: float = 0.0
@export var s1_timer: float = 0.0
@export var s2_timer: float = 0.0

#endregion 

#region Test vars
var p_cur_state = p_move_state

#endregion 

func _ready() -> void:
	p_heath = stats.player_health
	p_speed = stats.player_speed
	p_damage = stats.player_damage
	r_amount = stats.rage_amount
	r_per_attk = stats.rage_per_attack
	p_jump_h = stats.player_jump_height
	
	
	if stats == null:
		push_error("Enemy has no stats resource assigned.")
		return

func _physics_process(delta: float) -> void:

	reduce_timer(delta)
	apply_gravity(delta)
	player_move()
	player_jump()
	change_move_state()

	
#region Base movement

func player_move() -> void:
	p_direction = Input.get_axis("left", "right")

	velocity.x = p_direction * p_speed

	if p_direction != 0:
		p_sprite.flip_h = p_direction < 0
	
	move_and_slide()

func player_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		velocity.y += p_jump_h


func apply_gravity(delta) -> void:
	if !is_on_floor():
		velocity.y += p_gravity * delta
	
#endregion

#region Player States 

func change_move_state() -> void:
	if !is_on_floor():
		p_move_state = PlayerMoveState.JUMP
	elif velocity.x != 0:
		p_move_state = PlayerMoveState.RUN
	else:
		p_move_state = PlayerMoveState.IDLE
		
	print(p_move_state)

func change_action_state(new_state) -> void:
	if p_action_state == new_state:
		return
	
	p_action_state = new_state
	print(p_action_state)

#endregion 

#region Timers func

func reduce_timer(delta: float) -> void:
	attk_c_timer = set_timer(stats.attk_combo_timer, delta)
	d_timer = set_timer(stats.dash_timer, delta)
	r_timer = set_timer(stats.rage_timer, delta)
	r_cd_timer = set_timer(stats.rage_cd_timer, delta)
	s1_timer = set_timer(stats.s1_cd_timer, delta)
	s2_timer = set_timer(stats.s2_cd_timer, delta)

#endregion

#region Test func

func view_state() -> void:
	print(p_cur_state)

#endregion
