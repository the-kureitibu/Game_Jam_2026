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

#region Arrow Arrays 

var arrow_float_amount := 10.0
var arrow_float_duration := 0.8

@onready var arrows: Array = [
	arrow_one,
	arrow_two,
	arrow_three,
	arrow_four
]

var arrow_original_positions: Dictionary = {}

#endregion

#endregion


#endregion


func _ready() -> void:
	for arrow in arrows:
		arrow_original_positions[arrow] = arrow.position
	
	animate_arrows()


#func _process(delta: float) -> void:
	#animate_arrows()


#region Area Signals

func _on_exit_area_body_entered(body: Node2D) -> void:
	var player = body.get_tree().get_first_node_in_group("Player_target")

	if player:
		print("Move to main scene")

func _on_arrow_one_area_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_arrow_two_area_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_arrow_three_area_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_arrow_four_area_body_entered(body: Node2D) -> void:
	pass # Replace with function body.

#endregion

#region Arrow Animations

func animate_arrows() -> void:
	
	for arrow in arrows:
		var original_pos: Vector2 = arrow_original_positions[arrow]
		var up_pos := original_pos + Vector2(0.0, -arrow_float_amount)
		
		var tween := create_tween()
		tween.set_loops()
		tween.tween_property(arrow, "position", up_pos, arrow_float_duration)
		tween.tween_property(arrow, "position", original_pos, arrow_float_duration)


#endregion
