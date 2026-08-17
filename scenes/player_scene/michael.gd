extends Node2D

#region References 
@onready var main_sprite: AnimatedSprite2D = $MainSprite

var max_height_offset: float = -80.0

#endregion -- References 


func tween_height(height_offset: float) -> void:
	
	var tween = create_tween()
	
	
