extends Node

class_name EnemyBase

#region Enums

enum EnemyActionState {
	COMBO_ONE,
	COMBO_TWO,
	COMBO_THREE,
	COMBO_FOUR,
	COMBO_RECOVERY
}

enum EnemyFormState {
	HUMAN_FORM,
	DEMON_LORD	
}

enum EnemyMovementState {
	JUMPING,
	CHASING,
	FLYING
}

#endregion

func set_timer(timer: float, delta: float) -> float:
	return max(timer - delta, 0.0)

func play_anim(anim_node: Node, anim_name: StringName, force_restart := false) -> void:
	if anim_node == null:
		push_error("No animation node exists.")
		return
	
	if anim_node is AnimatedSprite2D:
		if anim_node.sprite_frames == null:
			push_error("AnimatedSprite2D has no SpriteFrames resource.")
			return
		
		if not anim_node.sprite_frames.has_animation(anim_name):
			push_error("Missing animation: %s" % anim_name)
			return
		
		if not force_restart and anim_node.animation == anim_name and anim_node.is_playing():
			return
		
		anim_node.play(anim_name)
		return

func death() -> void:
	pass
