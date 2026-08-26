extends Area2D

#region Base Vars

@onready var rot_speed: float = 10.0
@onready var move_speed: float = 60.0
@onready var dmg: float = 20.0
@onready var spin_and_move_timer: float = 4.0

#endregion -- Base Vars

#region References

@onready var main_col: CollisionShape2D = $MainCol
@onready var main_sprite: AnimatedSprite2D = $MainSprite
@onready var target_pos: Vector2
@onready var final_direction: Vector2 = Vector2.ZERO
@onready var target_boss: Node2D

var dir: int = 0

#endregion -- References


#region SFX
@onready var earth_cast: String = "res://assets/audio/sfx/Earth Element Magic Spell.ogg"

#endregion -- SFX 

func _enter_tree() -> void:
	if target_boss == null:
		target_boss = get_tree().get_first_node_in_group("Boss_target")
	
		dir = target_boss.facing_dir
		
	else:
		print("boss does not exist")

func _ready() -> void:
	
	AudioManager.play_music(earth_cast, "special", -6.0)

	global_position = target_pos
	main_sprite.play("attk")

	
func _physics_process(delta: float) -> void:
	
	spin_and_move(delta)


func spin_and_move(delta: float) -> void:
	rotation += rot_speed * delta 
	position.x += dir * move_speed * delta
	
	spin_and_move_timer -= delta
	
	if spin_and_move_timer <= 0.0:
		fade_and_free()

func _on_main_sprite_animation_finished() -> void:
	pass

func fade_and_free() -> void:
	if main_sprite.is_playing():
		main_sprite.stop()
	
	var tween = create_tween()
	tween.tween_property(main_sprite, "modulate:a", 0.0, 2.0)
	
	await tween.finished
	
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	var player = area.get_tree().get_first_node_in_group("Player_target")

	if player:
		if "handle_hurt" in player:
			player.handle_hurt(dmg)
