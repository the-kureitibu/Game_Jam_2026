extends Area2D

@onready var m_sprite: AnimatedSprite2D = $Book
@onready var b_sprite: AnimatedSprite2D = $Explode

var dir: Vector2 = Vector2.DOWN 
var fall_speed := 130.0
var dmg := 20
@onready var col_book: CollisionShape2D = $BookHitbox
@onready var col_explode: CollisionShape2D = $ExplodeHitbox


signal anim_done

func _ready() -> void:
	m_sprite.play("fall")
	
	col_explode.set_deferred("disabled", true)
	b_sprite.visible = false

func match_explode_col_frames() -> void:
	
	match b_sprite.frame:
		0: 
			set_rad_rot_col_value(col_explode, 12.02, 33.99, Vector2(0, -11.0))
		1:
			set_rad_rot_col_value(col_explode, 12.02, 54.0, Vector2(0, -12.0))
		2:
			set_rad_rot_col_value(col_explode, 21.0, 82.0, Vector2(0, -21.0))
		3:
			set_rad_rot_col_value(col_explode, 21.0, 126.0, Vector2(0, -21.0))
		4:
			set_rad_rot_col_value(col_explode, 21.0, 82.0, Vector2(0, -21.0))
		5:
			set_rad_rot_col_value(col_explode, 12.02, 52.0, Vector2(0, -12.0))
		6:
			set_rad_rot_col_value(col_explode, 12.02, 32.0, Vector2(0, -12.0))
		7:
			pass
		_:
			return

func set_rad_rot_col_value(col_shape: CollisionShape2D, rad: float, height: float, pos: Vector2) -> void:

	col_shape.shape.radius = rad
	col_shape.shape.height = height
	col_shape.position = pos

func _physics_process(delta: float) -> void:
	
	position += dir * fall_speed * delta
	
	if b_sprite.animation == "explode" and b_sprite.is_playing():
		match_explode_col_frames()


func _on_area_entered(area: Area2D) -> void:
	var player = area.get_tree().get_first_node_in_group("Player_target")

	if player:
		if "handle_hurt" in player:
			player.handle_hurt(dmg)



func _on_body_entered(body: Node2D) -> void:
	var movement_stopper = Vector2.ZERO
	var terrain_group = body.get_tree().get_first_node_in_group("Terrain")
			
	if not terrain_group:
		return 

	if dir.y <= 0.0:
		return
		
	if terrain_group:

		dir = movement_stopper
		
		b_sprite.visible = true
		col_explode.visible = true
		col_book.set_deferred("disabled", true)
		col_explode.set_deferred("disabled", false)
		b_sprite.play("explode")
		m_sprite.visible = false 


func _on_explode_animation_finished() -> void:
	anim_done.emit()
	queue_free()
