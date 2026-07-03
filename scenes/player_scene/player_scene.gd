extends PlayerBase

@export var stats: PlayerStats 
@export var p_heath: int 
@export var p_speed: float
@export var p_damage: int
@export var r_amount: int
@export var r_per_attk: int
@export var p_sprite: Sprite2D

var p_direction: float = 0.0

func _ready() -> void:
	p_heath = stats.player_health
	p_speed = stats.player_speed
	p_damage = stats.player_damage
	r_amount = stats.rage_amount
	r_per_attk = stats.rage_per_attack
	
	if stats == null:
		push_error("Enemy has no stats resource assigned.")
		return
 
	print("I am champ")
	print(p_heath)

func _physics_process(delta: float) -> void:

	player_move()
		
	
	
#region Base movement

func player_move() -> void:
	p_direction = Input.get_axis("left", "right")
	velocity.x = p_direction * p_speed
#
	if p_direction != 0:
		p_sprite.flip_h = p_direction < 0

	move_and_slide()

#endregion
