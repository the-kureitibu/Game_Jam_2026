extends PlayerBase

#add if AttkComboSprite is vis > AttkComboSprite anim play 

#region Base Vars

@export var stats: PlayerStats 
@export var p_heath: int 
@export var p_speed: float
@export var p_damage: int
@export var r_amount: int
@export var r_per_attk: int
@export var p_sprite: AnimatedSprite2D
@export var p_move_state: PlayerBase.PlayerMoveState = PlayerMoveState.IDLE

var p_direction: float = 0.0
var can_dash: bool 

#endregion 

#region Movement Vars
@onready var jump_height := 100.0

@onready var time_to_apex := 0.35
@onready var time_to_fall := 0.25
@onready var apex_threshold := 35.0
@onready var apex_gravity_multiplier := 0.25

@onready var jump_gravity := (2.0 * jump_height) / pow(time_to_apex, 2.0)
@onready var fall_gravity := (2.0 * jump_height) / pow(time_to_fall, 2.0)

@onready var jump_velocity := -jump_gravity * time_to_apex

#endregion

#region Attack Base Vars
var is_attacking := false 
var combo_seq := 0
const MAX_COMBO = 2
var combo_input_queued: bool

@export var p_action_state: PlayerBase.PlayerActionState = PlayerActionState.NONE


#endregion
#region References Vars

@onready var p_attk_sprite: AnimatedSprite2D = $MainSprite

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
	dec_ini_stats()
	
	if not p_sprite.is_playing():
		p_sprite.play("idle")

	if stats == null:
		push_error("Enemy has no stats resource assigned.")
		return

	print_debug(is_attacking)
	
	attk_c_timer = stats.attk_combo_timer
	
func _physics_process(delta: float) -> void:
	
	#p_sprite.play("idle") - animation never runs without this
	reduce_timer(delta)
	apply_gravity(delta)
	player_move()
	start_attack()
	player_jump()
	update_move_state()

#region Initial Stats declaration
func dec_ini_stats() -> void:
	p_heath = stats.player_health
	p_speed = stats.player_speed
	p_damage = stats.player_damage
	r_amount = stats.rage_amount
	r_per_attk = stats.rage_per_attack

#endregion

#region Base movement

func player_move() -> void:
	p_direction = Input.get_axis("left", "right")

	velocity.x = p_direction * p_speed

	if p_direction != 0:
		p_sprite.flip_h = p_direction < 0
	
	move_and_slide()

func player_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity


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
		
	

#endregion


#region Attack Related 

func start_attack() -> void:
	
	if not Input.is_action_just_pressed("attack"):
		return
		
	if is_attacking:
		if attk_c_timer > 0.0:
			combo_input_queued = true
		return 
		
	start_attk_combo(1)


func start_attk_combo(combo_count: int) -> void:
	is_attacking = true
	combo_input_queued = false
	combo_seq = combo_count

	match combo_seq:
		1:
			p_action_state = PlayerActionState.ATTACK
			play_anim(p_sprite, "attk_combo_1", true)
		2:
			p_action_state = PlayerActionState.COMBO_ATTACK
			play_anim(p_sprite, "attk_combo_2", true)

	attk_c_timer = stats.attk_combo_timer


func _on_main_sprite_animation_finished() -> void:
	if not is_attacking:
		return
	
	if combo_input_queued and combo_seq < MAX_COMBO:
		start_attk_combo(combo_seq + 1)
	else:
		end_combo()

func end_combo() -> void:
	is_attacking = false
	combo_input_queued = false
	combo_seq = 0
	attk_c_timer = 0.0
	p_action_state = PlayerActionState.NONE
	
#endregion 

#region Player States 

func change_move_state(new_state: PlayerMoveState) -> void:
	if p_move_state == new_state:
		return
		
	p_move_state = new_state
	
	match p_move_state:
		PlayerMoveState.JUMP: 
			play_anim(p_sprite, "jump")
		PlayerMoveState.RUN:
			play_anim(p_sprite, "walk")
		PlayerMoveState.IDLE:
			play_anim(p_sprite, "idle")
		
	#print(PlayerMoveState.keys()[p_move_state])

func update_move_state() -> void:
	
	if !is_on_floor():
		change_move_state(PlayerMoveState.JUMP)
	elif abs(velocity.x) > 0.1:
		change_move_state(PlayerMoveState.RUN)
	elif velocity.x == 0:
		change_move_state(PlayerMoveState.IDLE)
		

func change_action_state(new_state) -> void:
	if p_action_state == new_state:
		return
	
	p_action_state = new_state
	print(p_action_state)

#endregion 

#region Timers func

func reduce_timer(delta: float) -> void:
	attk_c_timer = set_timer(attk_c_timer, delta)
	d_timer = set_timer(d_timer, delta)
	r_timer = set_timer(r_timer, delta)
	r_cd_timer = set_timer(r_cd_timer, delta)
	s1_timer = set_timer(s1_timer, delta)
	s2_timer = set_timer(s2_timer, delta)

#endregion

#region Test func

func view_state() -> void:
	print(p_cur_state)

#endregion
