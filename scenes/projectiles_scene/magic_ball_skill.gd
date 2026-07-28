extends Area2D

var dir: Vector2 = Vector2.ZERO
var m_speed: float = 60.0
var max_travel_dist: float = 150.0
@onready var marker_target: Marker2D

@onready var m_sprite: AnimatedSprite2D = $MainSprite

func _ready() -> void:
	m_sprite.play("launch")

func _physics_process(delta: float) -> void:
	
	position += dir * m_speed * delta
	

func handle_max_travel() -> void:
	if marker_target == null:
		push_error("Marker does not Exist")
		return
		
	var mark_position = marker_target.global_position
	
	if global_position.distance_to(mark_position) >= max_travel_dist:
		print("free queue")


func _on_area_entered(area: Area2D) -> void:
	var enemy_target = get_tree().get_first_node_in_group("Enemy_target")
	var boss_target = get_tree().get_first_node_in_group("Boss_target")
	
	if enemy_target or boss_target:
		if "hurt" in enemy_target or boss_target:
			enemy_target.hurt()
			boss_target.hurt()
