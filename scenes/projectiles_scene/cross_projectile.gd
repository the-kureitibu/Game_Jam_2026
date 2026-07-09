extends Area2D

@onready var main_sprite: Sprite2D = $MainSprite
@onready var hit_box: CollisionShape2D = $HitBox
@onready var anim_player: AnimationPlayer = $Anim
#@onready var t_player: Node2D = null


func _ready() -> void:

	
	main_sprite.visible = false
	hit_box.visible = false

func _process(delta: float) -> void:
	if main_sprite.visible and hit_box.visible:
		start_anim()

func handle_initial_attack() -> void:
	main_sprite.visible = true
	hit_box.visible = true

func start_anim() -> void:
	anim_player.play("trigger_attack")


func _on_anim_animation_finished(_anim_name: StringName) -> void:
	main_sprite.visible = false
	hit_box.visible = false
