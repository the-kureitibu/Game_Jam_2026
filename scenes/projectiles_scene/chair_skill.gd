extends Area2D

#region Base vars

var dmg := 10.0
var base_speed := 250.0
var max_speed := 120.0
var queue_timer := 0.0
var chair_broken := false


@onready var dir: Vector2
@onready var boss_target = get_tree().get_first_node_in_group("Boss_target")
@onready var marker_dir: int

#endregion 

#region References

@onready var m_sprite: AnimatedSprite2D = $MainSprite
@onready var hit_box: CollisionShape2D = $HitBox

#endregion

#region SFX
@onready var throw_cast: String = "res://assets/audio/sfx/sfx_throw.wav"

#endregion -- SFX 

#region Processes 

func _ready() -> void:
	AudioManager.play_music(throw_cast, "special", -6.0)

	play_anim(m_sprite, "launch")
	
	if boss_target == null:
		push_error("Boss does not exist")
	
	queue_timer = 1.5

func _physics_process(delta: float) -> void:
	
	if boss_target:
		marker_dir = boss_target.c_marker_dir

	handle_movement(marker_dir)
	
	if chair_broken:
		var movement_stopper = Vector2.ZERO
		dir = movement_stopper
		
		position += dir * base_speed * delta
		
	else:
		position += dir * base_speed * delta

	
	if queue_timer > 0.0:
		queue_timer -= delta
		if queue_timer <= 0.0:
			queue_free()
	

#endregion

#region Movement
func handle_movement(sign_dir: int) -> void:
	if boss_target == null:
		push_error("Boss does not exist")
	
	var temp: Vector2
	
	if sign_dir == -1:
		temp = Vector2.LEFT 
		dir = temp
		
	elif sign_dir == 1:
		temp = Vector2.RIGHT 
		dir = temp
	else:
		dir = Vector2.ZERO


#endregion
#region Animation

func play_anim(anim_node: AnimatedSprite2D, anim_name: StringName) -> void:
	if anim_node.sprite_frames.has_animation(anim_name):
		m_sprite.play(anim_name)

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
	

	m_sprite.play("break")
	chair_broken = true
	end_chair_queu() 


	
func end_chair_queu() -> void:
	if !chair_broken:
		return
	
	var tween = create_tween()
	tween.tween_property(m_sprite, "modulate:a", 0.0, 1.0)
	
	if m_sprite.modulate.a <= 0.0:

		queue_free()


#endregion


func _on_body_entered(body: Node2D) -> void:
	var terrain = body.get_tree().get_first_node_in_group("Terrain")
	
	if !terrain:
		return
	
	#if terrain:
		#print("entered a terrain?")
	#
	m_sprite.play("break")
	chair_broken = true
	end_chair_queu() 
