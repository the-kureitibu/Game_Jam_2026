extends Area2D


@onready var main_sprite: Sprite2D = $MainSprite
@onready var hit_box: CollisionShape2D = $HitBox


var dir: Vector2 = Vector2.UP 
var min_upward_speed := 40.0
var max_upward_speed := 140.0
var rotation_speed := 10.0
var final_random_speed: float = 0.0
var dmg := 10.0
var marker_pos: Vector2 = Vector2.ZERO
var queue_timer: float = 5.0 

@onready var can_exit_tree: bool = false

#region Processes

func _ready() -> void:
	set_speed()
	global_position = marker_pos
	
	print(final_random_speed)
	
func _physics_process(delta: float) -> void:
	
	position += dir * final_random_speed * delta
	rotation += rotation_speed * delta
	
	if queue_timer > 0.0:
		queue_timer -= delta
		if queue_timer <= 0.0:
			remove_from_tree()

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

#region End Process

func remove_from_tree() -> void:
	var tween = create_tween()
	tween.tween_property(main_sprite, "modulate:a", 0.0, 1.0)
	
	await tween.finished
	queue_free()

#endregion -- End Process





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

func hit() -> float:
	return dmg

#region Area Signals 

func _on_area_entered(area: Area2D) -> void:
	var player = area.get_tree().get_first_node_in_group("Player_target")

	if player:
		if "handle_hurt" in player:
			player.handle_hurt(dmg)
	
#endregion -- Area Signals 
