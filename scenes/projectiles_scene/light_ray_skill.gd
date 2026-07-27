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
var h_offset: float
var des_position: Vector2
const MAX_STACK := 5
var current_visible_stack := 0

#endregion

#region References 

@onready var player_target = get_tree().get_first_node_in_group("Player_target")

#endregion

#region Signals

#endregion

func _ready() -> void:
	
	if player_target == null:
		push_error("Player does not Exist")
	
	hitbox.set_deferred("disabled", true)
	get_tree().call_group("sprites", "hide")
	
	can_enable_vis = true
	
	handle_chaining()

func _process(delta: float) -> void:
	
	handle_stack_visibility()

	if sprite_vis_timer > 0.0:
		sprite_vis_timer -= delta
		if sprite_vis_timer <= 0.0:
			can_enable_vis = true
	
	
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
	

func handle_stack_visibility() -> void:
	is_stacking = true
	start_stack_vis()

func start_stack_vis() -> void:
	
	if !is_stacking:
		return

	if !sprite_vis_timer <= 0.0:
		return
	
	var group_nodes = get_tree().get_nodes_in_group("sprites")
	
	if can_enable_vis and current_visible_stack < MAX_STACK:
		for i in range(group_nodes.size()):
			var node = group_nodes[i]
			try_t(node, current_visible_stack)

	
			
func try_t(node: Node2D, cur_index: int) -> void:
	if !can_enable_vis:
		return
	
	match node.name:
		"S_1":
			if node.visible == false and cur_index == 0 and can_enable_vis:
				node.visible = true
				can_enable_vis = false
				current_visible_stack += 1
				sprite_vis_timer = 0.08
		"S_2":
			if node.visible == false and cur_index == 1 and can_enable_vis:
				node.visible = true
				can_enable_vis = false
				current_visible_stack += 1
				sprite_vis_timer = 0.08
		"S_3":
			if node.visible == false and cur_index == 2 and can_enable_vis:
				node.visible = true
				can_enable_vis = false
				current_visible_stack += 1
				sprite_vis_timer = 0.08
		"S_4":
			if node.visible == false and cur_index == 3 and can_enable_vis:
				node.visible = true
				can_enable_vis = false
				current_visible_stack += 1
				sprite_vis_timer = 0.08
		"S_5":
			if node.visible == false and cur_index == 4 and can_enable_vis:
				node.visible = true
				can_enable_vis = false
				is_stacking = false
				sprite_vis_timer = 0.0
				handle_col_shape()

func handle_col_shape() -> void:
	start_col_shape()

func start_col_shape() -> void:
	hitbox.set_deferred("disabled", false)
