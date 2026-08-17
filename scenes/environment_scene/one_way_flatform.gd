extends StaticBody2D


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var main_col: CollisionShape2D = $MainCol
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var player = get_tree().get_first_node_in_group("Player_target")



func _ready() -> void:
	
	pass

func _process(delta: float) -> void:
	
	
	if ray_cast_2d.is_colliding():
		var collider = ray_cast_2d.get_collider()
		
		if collider.name != 'PlayerScene':
			return
		else:
			if Input.is_action_just_pressed("down") and Input.is_action_just_pressed("right"):
				print("worked")
