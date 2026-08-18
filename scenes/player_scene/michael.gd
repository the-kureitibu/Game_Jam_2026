extends Node2D

#region References 
@onready var main_sprite: AnimatedSprite2D = $MainSprite

var max_height_offset: float = -70.0
var captured_pos: Vector2 = Vector2.ZERO

#endregion -- References 

#region Processes

func _ready() -> void:
	var tween = create_tween()
	
	global_position = captured_pos

	tween_height(max_height_offset, tween)

#endregion -- Processes


func tween_height(height_offset: float, tw: Tween) -> void:
	
	var max_height = global_position.y + max_height_offset
	tw.tween_property(self, "global_position:y", max_height, 2.0)
	
	main_sprite.play("summon")
	
	await main_sprite.animation_finished
	
	fade_and_exit(tw)
	

func fade_and_exit(tw: Tween) -> void:
	if tw.is_running():
		tw.stop()
	
	var tween2 = create_tween()
	
	main_sprite.play("fade")
	tween2.tween_property(main_sprite, "modulate:a", 0.0, 2.0)
	
	await tween2.finished
	
	if !GameManager.is_immortal:
		SignalHub.michael_blessing_get.emit()
	

	SignalHub.revival_complete.emit()
	
	queue_free()
	
