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
var current_visible_stack := 1

#endregion

#region References 

@onready var player_target = get_tree().get_first_node_in_group("Player_target")

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
		print("Vis timer in process: ", sprite_vis_timer)
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
	
	start_stack_vis()
	

func handle_stack_visibility() -> void:
	is_stacking = true
	start_stack_vis()

func start_stack_vis() -> void:
	if !is_stacking:
		return
	
	if !sprite_vis_timer <= 0.0:
		return
	
	sprite_vis_timer = 1.0
	
	var group_nodes = get_tree().get_nodes_in_group("sprites")
	print(group_nodes)
	
	if can_enable_vis and current_visible_stack < MAX_STACK:
		print("made it here?")
		for i in range(group_nodes.size()):
			var node = group_nodes[i]
			print_debug(node)
			
			match node.name:
				"S_1":
					if node.visible == false:
						print_debug("match works?")
						print_debug("visible? ", node.visible)
						node.visible = true
						print_debug("visible? ", node.visible)
						can_enable_vis = false
						#node.visible = true
						#current_visible_stack += 1 
					
				1:
					if node.visible == false:
						node.visible = true
						current_visible_stack += 1 
				
			
	#
	#if !sprite_one.visible:
		#sprite_one.visible = true 
	#elif sprite_one.visible and sprite_two.visible == false and is_stacking:
		#sprite_two.visible = true
	
	
	#print("Vis timer in function: ", sprite_vis_timer)
