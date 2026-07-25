extends Area2D

@onready var m_sprite: AnimatedSprite2D = $Book
@onready var b_sprite: AnimatedSprite2D = $Explode

var dir: Vector2 = Vector2.DOWN 
var fall_speed := 60.0
var dmg := 20
@onready var col_book: CollisionShape2D = $BookHitbox
@onready var col_explode: CollisionShape2D = $ExplodeHitbox


signal anim_done

func _ready() -> void:
	m_sprite.play("fall")
	
	col_explode.set_deferred("disabled", true)
	b_sprite.visible = false

	

func _physics_process(delta: float) -> void:
	
	position += dir * fall_speed * delta

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
		print("hit the ground")
		dir = movement_stopper
		
		b_sprite.visible = true
		col_book.set_deferred("disabled", true)
		col_explode.set_deferred("disabled", false)
		b_sprite.play("explode")
		m_sprite.visible = false 


func _on_explode_animation_finished() -> void:
	anim_done.emit()
	queue_free()
