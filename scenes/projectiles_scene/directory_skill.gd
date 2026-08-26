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

#region SFX
@onready var flight_cast: String = "res://assets/audio/sfx/flight_sound.mp3"

#endregion -- SFX 


#region Processes

func _ready() -> void:
	AudioManager.play_music(flight_cast, "special", -6.0)

	set_speed()
	global_position = marker_pos
	
	
func _physics_process(delta: float) -> void:
	
	position += dir * final_random_speed * delta
	rotation += rotation_speed * delta
	
	if queue_timer > 0.0:
		queue_timer -= delta
		if queue_timer <= 0.0:
			remove_from_tree()

#endregion -- Processes

#region Initial Launch


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



func hit() -> float:
	return dmg

#region Area Signals 

func _on_area_entered(area: Area2D) -> void:
	var player = area.get_tree().get_first_node_in_group("Player_target")

	if player:
		if "handle_hurt" in player:
			player.handle_hurt(dmg)
	
#endregion -- Area Signals 
