extends Area2D


@onready var main_sprite: Sprite2D = $MainSprite
@onready var hit_box: CollisionShape2D = $HitBox


var dir: Vector2 = Vector2.UP 
var min_upward_speed := 40.0
var max_upward_speed := 140.0
var final_random_speed: float = 0.0
var dmg := 20
var marker_pos: Vector2 = Vector2.ZERO

@onready var can_exit_tree: bool = false

#region Processes

func _ready() -> void:
	set_speed()
	global_position = marker_pos
	
	print(final_random_speed)
	
func _physics_process(delta: float) -> void:
	
	position += dir * final_random_speed * delta

#endregion -- Processes

#region Initial Launch

func start_spinning() -> void:
	pass

func get_random_speed(min_spd: float, max_spd: float) -> float:
	var rand_float = randf_range(min_spd, max_spd)
	
	return rand_float
	
func set_speed() -> void:
	var rand_speed = get_random_speed(min_upward_speed, max_upward_speed)
	
	final_random_speed = rand_speed

#endregion -- Initial Launch


#func match_explode_col_frames() -> void:
	#
	#match b_sprite.frame:
		#0: 
			#set_rad_rot_col_value(col_explode, 12.02, 33.99, Vector2(0, -11.0))
		#1:
			#set_rad_rot_col_value(col_explode, 12.02, 54.0, Vector2(0, -12.0))
		#2:
			#set_rad_rot_col_value(col_explode, 21.0, 82.0, Vector2(0, -21.0))
		#3:
			#set_rad_rot_col_value(col_explode, 21.0, 126.0, Vector2(0, -21.0))
		#4:
			#set_rad_rot_col_value(col_explode, 21.0, 82.0, Vector2(0, -21.0))
		#5:
			#set_rad_rot_col_value(col_explode, 12.02, 52.0, Vector2(0, -12.0))
		#6:
			#set_rad_rot_col_value(col_explode, 12.02, 32.0, Vector2(0, -12.0))
		#7:
			#pass
		#_:
			#return
#
#func set_rad_rot_col_value(col_shape: CollisionShape2D, rad: float, height: float, pos: Vector2) -> void:
#
	#col_shape.shape.radius = rad
	#col_shape.shape.height = height
	#col_shape.position = pos
#
#func _physics_process(delta: float) -> void:
	#
	#position += dir * fall_speed * delta
	#
	#if b_sprite.animation == "explode" and b_sprite.is_playing():
		#match_explode_col_frames()
	#
	#
	#if can_exit_tree:
		#queue_free()
#
#
#func _on_area_entered(area: Area2D) -> void:
	#var player = area.get_tree().get_first_node_in_group("Player_target")
#
	#if player:
		#if "handle_hurt" in player:
			#player.handle_hurt(dmg)
#
#
#
#func _on_body_entered(body: Node2D) -> void:
	#var movement_stopper = Vector2.ZERO
	#var terrain_group = body.get_tree().get_first_node_in_group("Terrain")
			#
	#if not terrain_group:
		#return 
#
	#if dir.y <= 0.0:
		#return
		#
	#if terrain_group:
#
		#dir = movement_stopper
		#
		#b_sprite.visible = true
		#col_explode.visible = true
		#col_book.set_deferred("disabled", true)
		#col_explode.set_deferred("disabled", false)
		#b_sprite.play("explode")
		#m_sprite.visible = false 
#
#
#func _on_explode_animation_finished() -> void:
	#anim_done.emit()
		#
	#can_exit_tree = true 
