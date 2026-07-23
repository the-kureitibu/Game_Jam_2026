extends Area2D

#region Base vars

var dmg := 10.0
var base_speed := 250.0
var max_speed := 120.0

@onready var marker_dir: float
@onready var dir: Vector2 = Vector2.ZERO
@onready var boss_target = get_tree().get_first_node_in_group("Boss_target")

#endregion 

#region References

@onready var m_sprite: AnimatedSprite2D = $MainSprite
@onready var hit_box: CollisionShape2D = $HitBox

#endregion

#region Processes 

func _ready() -> void:
	play_anim(m_sprite, "launch")
	
	if boss_target == null:
		push_error("Boss does not exist")

func _physics_process(delta: float) -> void:
	
	position += dir * base_speed * delta

#endregion

#region Animation

func play_anim(anim_node: AnimatedSprite2D, anim_name: StringName) -> void:
	if anim_node.sprite_frames.has_animation(anim_name):
		m_sprite.play(anim_name)
		print(m_sprite.is_playing())

func _on_main_sprite_animation_finished() -> void:
	pass # Replace with function body.


#endregion

#region HitBox detection

func _on_area_entered(area: Area2D) -> void:
	var player = area.get_tree().get_first_node_in_group("Player_target")
	
	if !player:
		return
	
	if "handle_hurt" in player:
		player.handle_hurt(dmg)

#endregion
