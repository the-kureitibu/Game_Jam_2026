extends CharacterBody2D

class_name PlayerBase

#region enum state
enum PlayerState {
	RUN,
	ATTACKING,
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
	
