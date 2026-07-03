extends PlayerBase

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


func _ready() -> void:
	p_heath = stats.player_health
	p_speed = stats.player_speed
	p_damage = stats.player_damage
	r_amount = stats.rage_amount
	r_per_attk = stats.rage_per_attack
	p_jump_h = stats.player_jump_height
	
	print(PlayerState.keys()[p_state])
	
	if stats == null:
		push_error("Enemy has no stats resource assigned.")
		return
 
	print("I am champ")
	print(p_heath)

func _physics_process(delta: float) -> void:

	change_p_state()
	apply_gravity(delta)
	player_move()
	player_jump()

	
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

func change_p_state() -> void:
	if velocity.x != 0:
		p_state = PlayerState.RUN
		print(PlayerState.keys()[p_state])
	elif velocity.x == 0: 
		p_state = PlayerState.IDLE
		print(PlayerState.keys()[p_state])
	elif !is_on_floor():
		p_state = PlayerState.JUMPING
		print(PlayerState.keys()[p_state])

func apply_gravity(delta) -> void:
	if !is_on_floor():
		velocity.y += p_gravity * delta
	
#endregion
