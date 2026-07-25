extends Area2D

@onready var m_sprite: AnimatedSprite2D = $Book
@onready var b_sprite: AnimatedSprite2D = $Explode

var dir: Vector2 = Vector2.DOWN 
var fall_speed := 60.0
var dmg := 20

signal anim_done

func _ready() -> void:
	m_sprite.play("fall")
	

func _physics_process(delta: float) -> void:
	
	position += dir * fall_speed * delta

func _on_area_entered(area: Area2D) -> void:
	var player = area.get_tree().get_first_node_in_group("Player_target")
	var ground = area.get_collision_layer_value(4)

	if "handle_hurt" in player:
		player.handle_hurt(dmg)
	
	if ground:
		b_sprite.play("explode")
		m_sprite.visible = false 


func _on_explode_animation_finished() -> void:
	anim_done.emit()
	queue_free()
