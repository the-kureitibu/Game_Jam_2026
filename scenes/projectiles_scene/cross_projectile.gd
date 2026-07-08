extends Area2D

@onready var main_sprite: Sprite2D = $MainSprite
@onready var hit_box: CollisionShape2D = $HitBox
@onready var anim_player: AnimationPlayer = $Anim

func _ready() -> void:
	main_sprite.visible = false
	hit_box.visible = false

func _process(delta: float) -> void:
	if main_sprite.visible and hit_box.visible:
		pass
