extends StaticBody2D


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var main_col: CollisionShape2D = $MainCol
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var player = get_tree().get_first_node_in_group("Player_target")
@onready var enable_timer := 0.0


func _ready() -> void:
	
	pass

func _process(delta: float) -> void:
	
	if enable_timer > 0.0:
		enable_timer -= delta
		if enable_timer <= 0.0:
			
			if main_col.disabled:
				main_col.set_deferred("disabled", false)
				enable_timer = 3.0

	if ray_cast_2d.is_colliding():
		var collider = ray_cast_2d.get_collider()
		
		if collider.name != 'PlayerScene':
			return
		else:
			SignalHub.is_in_flatform.emit()
			enable_timer = 3.0


			if Input.is_action_pressed("down") and Input.is_action_pressed("jump"):
				if GameManager.is_immortal:
					return
				else:
					main_col.set_deferred("disabled", true)
					SignalHub.falling_players.emit()
	else:
		SignalHub.not_in_flatform.emit()
