extends Area2D

#region Base vars

@onready var hitbox: CollisionShape2D = $HitBox
@onready var sprite_one: AnimatedSprite2D = $S_1
@onready var sprite_two: AnimatedSprite2D = $S_2
@onready var sprite_three: AnimatedSprite2D = $S_3
@onready var sprite_four: AnimatedSprite2D = $S_4
@onready var sprite_five: AnimatedSprite2D = $S_5

@onready var sprite_texture = sprite_one.sprite_frames.get_frame_texture("ray_attk", 0)
@onready var sprite_height = sprite_texture.get_height()

var anim_start_timer := 2.0
var sprite_vis_timer: float
var is_stacking := false
var can_enable_vis := false
var h_offset: float = 64.0 * 4.0
var des_position: Vector2
const MAX_STACK := 5
var current_visible_stack := 0

@onready var ray_sprites: Array[AnimatedSprite2D] = [
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

signal light_ray_done
#endregion

#region Processes
func _ready() -> void:
	z_index = 10
	
	if player_target == null:
		push_error("Player does not Exist")
	
	hitbox.set_deferred("disabled", true)
	get_tree().call_group("sprites", "hide")
	
	can_enable_vis = true
	
	
	handle_chaining()
	start_reveal_sequence()

func _physics_process(delta: float) -> void:
	adjust_col_frame(sprite_one)

#endregion

#region Chaining Logic

func handle_chaining() -> void:
	stack_chaining(sprite_two, "ray_attk", 0, 1)
	stack_chaining(sprite_three, "ray_attk", 0, 2)
	stack_chaining(sprite_four, "ray_attk", 0, 3)
	stack_chaining(sprite_five, "ray_attk", 0, 4)

func stack_chaining(sprite: AnimatedSprite2D, anim_name: StringName, frame_num: int, multiplier: int) -> void:
	
	var sprite_text = sprite.sprite_frames.get_frame_texture(anim_name, frame_num)
	var sprite_h = sprite_text.get_height()
	var y_offset := 0.0
	var target_pos: Vector2 = Vector2.ZERO
	
	y_offset  = float(sprite_h)
	target_pos = Vector2(0, y_offset) * multiplier
	sprite.position = target_pos
	
	hitbox.shape.size = Vector2(10.0, y_offset + (y_offset * multiplier) )
	hitbox.position.y = y_offset * multiplier / 2.0
	
	#start_stack_vis()
	
func start_reveal_sequence() -> void:
	for sprite in ray_sprites:
		await reveal_sprite(sprite, 0.06)
	
	start_animation()


func reveal_sprite(sprite: AnimatedSprite2D, delay: float) -> void:
	sprite.visible = true
	sprite.modulate.a = 0.0
	
	var tween := create_tween()
	tween.tween_interval(delay)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.06)
	await tween.finished

#endregion

#region Animation handling Logic 
func start_animation() -> void:
	anim_helper(sprite_one, "ray_attk")
	anim_helper(sprite_two, "ray_attk")
	anim_helper(sprite_three, "ray_attk")
	anim_helper(sprite_four, "ray_attk")
	anim_helper(sprite_five, "ray_attk")

func anim_helper(anim_node: AnimatedSprite2D, anim_name: StringName) -> void:
	if !anim_node.sprite_frames.has_animation(anim_name):
		return
	
	anim_node.play(anim_name)
	handle_col_shape()

#endregion

#region Collision Shape Logic
func handle_col_shape() -> void:
	start_col_shape()

func start_col_shape() -> void:
	hitbox.set_deferred("disabled", false)

func adjust_col_frame(sprite: AnimatedSprite2D) -> void:
	if hitbox.disabled:
		return
	
	if !sprite.is_playing():
		return
	
	match sprite.frame:
		
		0:
			handle_col_shape_expand(hitbox, 10.0)
		1:
			handle_col_shape_expand(hitbox, 14.0)
		2:
			handle_col_shape_expand(hitbox, 16.0)
		3:
			handle_col_shape_expand(hitbox, 26.0)
		4:
			handle_col_shape_expand(hitbox, 18.0)
		5:
			handle_col_shape_expand(hitbox, 14.0)
		6:
			handle_col_shape_expand(hitbox, 10.0)
		7:
			hitbox.set_deferred("disabled", true)
			
func handle_col_shape_expand(col: CollisionShape2D, x_size: float) -> void:
	
	col.shape.size.x = x_size
	
#endregion

#region End Sequence Logic

func start_alpha_fade_in_sequence() -> void:
	
	var backwards_array = ray_sprites.duplicate()

	backwards_array.reverse()

	for item in backwards_array:
		await fade_in_to_trans_sprite(item, 0.3)
	
	light_ray_done.emit()
	queue_free()

func fade_in_to_trans_sprite(sprite: AnimatedSprite2D, delay: float) -> void:

	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, delay)
	await tween.finished
	
#endregion

#region Local Signals
func _on_s_1_animation_finished() -> void:
	start_alpha_fade_in_sequence()
	
#endregion
