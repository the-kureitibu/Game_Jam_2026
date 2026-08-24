extends Area2D

#region Base Vars

@onready var rot_speed: float = 20.0


#endregion -- Base Vars

#region References

@onready var main_col: CollisionShape2D = $MainCol
@onready var main_sprite: AnimatedSprite2D = $MainSprite

#endregion -- References


func _ready() -> void:
	
	main_sprite.play("attk")
	
func _physics_process(delta: float) -> void:
	
	rotation += rot_speed * delta 
