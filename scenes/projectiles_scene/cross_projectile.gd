extends Area2D

@onready var main_sprite: Sprite2D = $MainSprite
@onready var hit_box: CollisionShape2D = $HitBox
@onready var anim_player: AnimationPlayer = $Anim
@onready var t_player = get_tree().get_first_node_in_group("Player_target")


func _ready() -> void:
	
	
	hit_box.set_deferred("disabled", true)
	main_sprite.visible = false
	hit_box.visible = false

func _process(delta: float) -> void:
	if main_sprite.visible and hit_box.visible:
		start_anim()

func handle_initial_attack() -> void:
	
	hit_box.set_deferred("disabled", false)
	main_sprite.visible = true
	hit_box.visible = true

func start_anim() -> void:
	anim_player.play("trigger_attack")

func hit() -> int:
	if t_player == null:
		push_error("Player does not exist")
	return t_player.p_damage

func _on_anim_animation_finished(_anim_name: StringName) -> void:
	hit_box.set_deferred("disabled", true)
	main_sprite.visible = false
	hit_box.visible = false


func _on_area_entered(area: Area2D) -> void:
	var to_enemy = area.get_tree().get_first_node_in_group("Enemy_target")
	
	if to_enemy:
		t_player.accumulate_rage()
