extends Area2D

#region Base vars

@onready var hitbox: CollisionShape2D = $HitBox
@onready var sprite_one: AnimatedSprite2D = $S_1
@onready var sprite_two: AnimatedSprite2D = $S_2
@onready var sprite_texture = sprite_one.sprite_frames.get_frame_texture("ray_attk", 0)
@onready var sprite_height = sprite_texture.get_height()
var h_offset: float
var des_position: Vector2

#endregion

#region References 

@onready var player_target = get_tree().get_first_node_in_group("Player_target")

#endregion

func _ready() -> void:
	
	if player_target == null:
		push_error("Player does not Exist")
	
	#print(sprite_height)
	#print(position)
#
	#des_position = Vector2(0, h_offset)
	#print(des_position)
	#
	#sprite_one.position = des_position
	#print(sprite_one.position)
	#
	#sprite_two.position = des_position * 2
	#print(sprite_two.position)
	stack_position(sprite_two, "ray_attk", 0, 1)

func handle_chaining() -> void:
	pass

func stack_position(sprite: AnimatedSprite2D, anim_name: StringName, frame_num: int, multiplier: int) -> void:
	
	var sprite_text = sprite.sprite_frames.get_frame_texture(anim_name, frame_num)
	var sprite_h = sprite_text.get_height()
	var y_offset := 0.0
	var target_pos: Vector2 = Vector2.ZERO
	
	y_offset  = float(sprite_h)
	target_pos = Vector2(0, y_offset) * multiplier
	sprite.position = target_pos
	
	print(target_pos)
	print(sprite.position)
	

	
	 
