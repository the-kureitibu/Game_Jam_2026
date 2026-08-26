extends Area2D

var dir: Vector2 = Vector2.ZERO
var m_speed: float = 60.0
var max_travel_dist: float = 150.0
@onready var marker_target: Marker2D 

@onready var m_sprite: AnimatedSprite2D = $MainSprite

signal launched_done

#region References 

@onready var player_target = get_tree().get_first_node_in_group("Player_target")

#region References

@onready var wind_sfx: String = "res://assets/audio/sfx/strong wind blowing.mp3"

#endregion -- References

#endregion

func _enter_tree() -> void:
	if !is_in_group("player_projectile"):
		add_to_group("player_projectile")

func _ready() -> void:
	AudioManager.play_music(wind_sfx, "skill", -9.0)
	
	m_sprite.play("launch")
	
	
func _physics_process(delta: float) -> void:
	
	
	if dir != Vector2.ZERO:
		m_sprite.flip_h = dir == Vector2.LEFT
	
	
	position += dir * m_speed * delta
	handle_max_travel()


func handle_max_travel() -> void:
	if marker_target == null:
		push_error("Marker does not Exist")
		return

	var mark_position = marker_target.global_position
	
	if global_position.distance_to(mark_position) >= max_travel_dist:
		m_sprite.play("fade_to")


func _on_area_entered(area: Area2D) -> void:
	var boss_target = get_tree().get_first_node_in_group("Boss_target")
	var enemy_target = get_tree().get_first_node_in_group("Enemy_target")
	
	if boss_target: 
		if "hurt" in boss_target:
			boss_target.hurt()
	elif enemy_target:
		if "hurt" in enemy_target:
			enemy_target.hurt()


func _on_main_sprite_animation_finished() -> void:
	var tween = create_tween()
	tween.tween_property(m_sprite, "modulate:a", 0.0, 1.0)
	
	await tween.finished
	launched_done.emit()
	
	AudioManager.stop_music("skill")
	queue_free()
	

func hit() -> int:
	if player_target == null:
		push_error("Player does not exist")
	
	return player_target.magic_ball_skill_damage
