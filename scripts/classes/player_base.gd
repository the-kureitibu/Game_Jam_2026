extends CharacterBody2D

class_name PlayerBase

#region enum state
enum PlayerState {
	RUN,
	ATTACKING,
	HUMAN_FORM,
	SPIDER_FORM,
	HIT,
	RAGE,
	IDLE,
	JUMPING,
	COMBO_ATTACK,
	DIED,
	REVIVING
	
}
#endregion


func death() -> void:
	pass

func to_human() -> void:
	pass

func to_spider() -> void:
	pass
