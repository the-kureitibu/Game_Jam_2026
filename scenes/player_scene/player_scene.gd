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
@export var p_state: PlayerBase.PlayerState = PlayerState.IDLE
@export var p_gravity: float = -680.0

var p_direction: float = 0.0

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
var p_cur_state = p_state

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

	
	apply_gravity(delta)
	player_move()
	player_jump()
	change_p_state()
	view_state()

	
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

func change_p_state() -> void:
	if !is_on_floor():
		p_state = PlayerState.JUMPING
	elif velocity.x != 0:
		p_state = PlayerState.RUN
	else:
		p_state = PlayerState.IDLE


#endregion 

#region Timers func

func update_timers(timer_res: float, delta: float) -> void:
	match timer_res:
		stats.attk_combo_timer:
			if attk_c_timer != 0:
				attk_c_timer -= delta
	
			

	#attk_c_timer = set_timer(stats.attk_combo_timer)
	#print(attk_c_timer)
	#d_timer = set_timer(stats.dash_timer)
	#r_timer = set_timer(stats.rage_timer)
	#r_cd_timer = set_timer(stats.rage_cd_timer)
	#s1_timer = set_timer(stats.s1_cd_timer)
	#s2_timer = set_timer(stats.s2_cd_timer)

func set_timers() -> void:
	attk_c_timer = set_timer(stats.attk_combo_timer)
	print(attk_c_timer)
	d_timer = set_timer(stats.dash_timer)
	r_timer = set_timer(stats.rage_timer)
	r_cd_timer = set_timer(stats.rage_cd_timer)
	s1_timer = set_timer(stats.s1_cd_timer)
	s2_timer = set_timer(stats.s2_cd_timer)

#endregion

#region Test func

func view_state() -> void:
	print(p_cur_state)

#endregion
