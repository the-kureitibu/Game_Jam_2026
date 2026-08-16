extends CharacterBody2D

class_name PlayerBase

#region Var helpers

var is_dead: bool = false

#endregion


#region Enums States

enum PlayerMoveState {
	RUN,
	IDLE,
	JUMP,
	FALL,
	DASH,
	KNOCKBACK
}

enum PlayerActionState {
	RAGE_TRANSFORM,
	ATTACK,
	COMBO_ATTACK,
	HURT,
	BLOCKING,
	SKILL_1,
	SKILL_2,
	DEAD,
	REVIVE,
	NONE,
}

enum PlayerFormState {
	HUMAN_FORM,
	RAGE_CD,
	SPIDER_FORM,
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
	
	if anim_node is AnimationPlayer:

		if not anim_node.has_animation(anim_name):
			push_error("Missing animation: %s" % anim_name)
			return
		
		if not force_restart and anim_node.current_animation == anim_name and anim_node.is_playing():
			return
		
		anim_node.play(anim_name)
		return

func death() -> void:
	if is_dead:
		return

	is_dead = true
	
	SignalHub.player_died.emit()
