extends CharacterBody2D

class_name PlayerBase

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

func play_anim(anim: Animation, anim_name: String) -> void:
	anim.play(anim_name)

func death() -> void:
	pass

func to_human() -> void:
	pass

func to_spider() -> void:
	pass
