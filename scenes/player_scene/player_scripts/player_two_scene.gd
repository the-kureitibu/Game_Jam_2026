extends PlayerBase

var jump_height := 90.0
var jump_gravity := (2 * jump_height) / pow(jump_height, 2.0)
@onready var main_sprite: AnimatedSprite2D = $MainSprite
@export var t_player: Node2D


func _ready() -> void:
	pass
	#if t_player:
		#print(t_player.name)
	#
	#if t_player.p_move_state == PlayerMoveState.IDLE:
		#print("player_idle")

func _physics_process(delta: float) -> void:
	handle_animation()
	handle_movement()

func handle_animation() -> void:
	
	match t_player.p_move_state:
		PlayerMoveState.IDLE:
			play_anim(main_sprite, "idle")
		PlayerMoveState.RUN:
			play_anim(main_sprite, "walk")
		PlayerMoveState.JUMP:
			play_anim(main_sprite, "jump")
	
func handle_movement() -> void:
	if t_player.velocity.x == 0.0:
		print("true")
	else:
		print("false")
