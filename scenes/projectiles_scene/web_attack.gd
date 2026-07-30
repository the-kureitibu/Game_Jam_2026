extends Area2D

#region Base vars

@onready var hitbox: CollisionShape2D = $HitBox
@onready var sprite_one: AnimatedSprite2D = $MainSprite
@onready var sprite_two: AnimatedSprite2D = $MainSprite2
@onready var sprite_three: AnimatedSprite2D = $MainSprite3
@onready var sprite_four: AnimatedSprite2D = $MainSprite4
@onready var sprite_five: AnimatedSprite2D = $MainSprite5

@onready var sprite_texture = sprite_one.sprite_frames.get_frame_texture("spawn_web", 0)
@onready var sprite_height = sprite_texture.get_height()

var current_stacks := 0
var sprite_vis_timer: float
var can_enable_vis := false
var h_offset: float = 64.0 * 4.0
var des_position: Vector2
var delay_timer := 0.0
const MAX_STACK := 5

@onready var web_sprites: Array[AnimatedSprite2D] = [
	sprite_one,
	sprite_two,
	sprite_three,
	sprite_four,
	sprite_five
]

#endregion

#region References 

@onready var player_target = get_tree().get_first_node_in_group("Player_target")

#endregion

#region Signals

signal web_attack_done
#endregion

#region Processes
func _ready() -> void:

	sprite_one.rotation = deg_to_rad(90.0)

	
	if player_target == null:
		push_error("Player does not Exist")
	
	hitbox.set_deferred("disabled", true)

	for sprite in web_sprites:
		sprite.hide()
		sprite.modulate.a = 0.0
	
	can_enable_vis = true
	
	
	handle_chaining()
	start_reveal_sequence()

func _physics_process(delta: float) -> void:
	if delay_timer > 0.0:
		delay_timer -= delta
		if delay_timer <= 0.0:
			start_alpha_fade_in_sequence()
			

#endregion

#region Chaining Logic

func handle_chaining() -> void:
	stack_chaining(sprite_two, "spawn_web", 0, 1)
	stack_chaining(sprite_three, "spawn_web", 0, 2)
	stack_chaining(sprite_four, "spawn_web", 0, 3)
	stack_chaining(sprite_five, "spawn_web", 0, 4)

func stack_chaining(sprite: AnimatedSprite2D, anim_name: StringName, frame_num: int, multiplier: int) -> void:
	
	var sprite_text = sprite.sprite_frames.get_frame_texture(anim_name, frame_num)
	var sprite_h = sprite_text.get_height()
	var y_offset := 0.0
	var target_pos: Vector2 = Vector2.ZERO
	
	y_offset  = float(sprite_h)

	target_pos = Vector2(0, -y_offset) * multiplier

	sprite.position = target_pos
	sprite.rotation = deg_to_rad(90.0)

	hitbox.shape.size = Vector2(32.0, y_offset + (y_offset * multiplier) )
	hitbox.position.y = -y_offset * multiplier / 2.0

	
func start_reveal_sequence() -> void:
	for sprite in web_sprites:
		await reveal_sprite(sprite, 0.06)


func reveal_sprite(sprite: AnimatedSprite2D, delay: float) -> void:
	sprite.visible = true
	sprite.modulate.a = 0.0
	
	var tween := create_tween()
	tween.tween_interval(delay)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.06)
	await tween.finished
	current_stacks += 1 
	
	if current_stacks >= MAX_STACK:
		hitbox.set_deferred("disabled", false)
		delay_timer = 0.06
		

#endregion

#region End Sequence Logic

func start_alpha_fade_in_sequence() -> void:
	hitbox.set_deferred("disabled", true)
	
	var backwards_array = web_sprites.duplicate()

	backwards_array.reverse()

	for item in backwards_array:
		await fade_in_to_trans_sprite(item, 0.1)
	
	web_attack_done.emit()
	queue_free()

func fade_in_to_trans_sprite(sprite: AnimatedSprite2D, delay: float) -> void:

	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, delay)
	await tween.finished
	
#endregion
