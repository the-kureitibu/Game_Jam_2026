extends Node2D

#region Base Vars

#region References

@onready var tutorial_attack: Sprite2D = $TutorialAttack
@onready var tutorial_skill: Sprite2D = $TutorialSkill
@onready var tutorial_jump: Sprite2D = $TutorialJump
@onready var tutorial_rage: Sprite2D = $TutorialRage

@onready var arrow_one: Sprite2D = $ArrowOne
@onready var arrow_two: Sprite2D = $ArrowTwo
@onready var arrow_three: Sprite2D = $ArrowThree
@onready var arrow_four: Sprite2D = $ArrowFour

#region Collision Shapes

@onready var arrow_one_col: CollisionShape2D = $ArrowOneArea/ArrowOneCol
@onready var arrow_two_col: CollisionShape2D = $ArrowTwoArea/ArrowTwoCol
@onready var arrow_three_col: CollisionShape2D = $ArrowThreeArea/ArrowThreeCol
@onready var arrow_four_col: CollisionShape2D = $ArrowFourArea/ArrowFourCol


#endregion


#endregion


#endregion


func _ready() -> void:
	pass



func _on_exit_area_body_entered(body: Node2D) -> void:
	var player = body.get_tree().get_first_node_in_group("Player_target")

	if player:
		print("Move to main scene")

#region Area Signals

func _on_arrow_one_area_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_arrow_two_area_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_arrow_three_area_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_arrow_four_area_body_entered(body: Node2D) -> void:
	pass # Replace with function body.

#endregion
