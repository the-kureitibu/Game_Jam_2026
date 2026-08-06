extends Node2D

#region Base Vars

#region References

@onready var tutorial_attack: Sprite2D = $TutorialAttack
@onready var tutorial_skill: Sprite2D = $TutorialSkill
@onready var tutorial_jump: Sprite2D = $TutorialJump
@onready var tutorial_rage: Sprite2D = $TutorialRage

#endregion


#endregion


func _ready() -> void:
	pass



func _on_exit_area_body_entered(body: Node2D) -> void:
	var player = body.get_tree().get_first_node_in_group("Player_target")

	if player:
		print("Move to main scene")
