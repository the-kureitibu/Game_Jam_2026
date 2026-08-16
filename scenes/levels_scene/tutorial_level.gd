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

@onready var tutorial_u_is: Control = $UILayer/TutorialUIs

const GRASS_LAND_SCENE: String = "res://scenes/levels_scene/grass_land_level.tscn"

@onready var ui_layer: CanvasLayer = $UILayer



#region Collision Shapes

@onready var arrow_one_col: CollisionShape2D = $ArrowOneArea/ArrowOneCol
@onready var arrow_two_col: CollisionShape2D = $ArrowTwoArea/ArrowTwoCol
@onready var arrow_three_col: CollisionShape2D = $ArrowThreeArea/ArrowThreeCol
@onready var arrow_four_col: CollisionShape2D = $ArrowFourArea/ArrowFourCol

#endregion --  Collision Shapes

#region Signals

var is_in_arrow_one: bool = false
var is_in_arrow_two: bool = false
var is_in_arrow_three: bool = false
var is_in_arrow_four: bool = false

#endregion -- Signals


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

#endregion --  Arrow Arrays

#endregion --  References


#endregion --  Base Vars

#region Processes

func _enter_tree() -> void:
	GameManager.game_scene_state = GameManager.GameLevelStates.TUTORIAL_SCENE
	
	if not SignalHub.transition_done.is_connected(start_ui_and_arrows):
		SignalHub.transition_done.connect(start_ui_and_arrows)

func _ready() -> void:

	for arrow in arrows:
		arrow_original_positions[arrow] = arrow.position
	

#func _process(delta: float) -> void:
	#animate_arrows()

#endregion  -- Processes

#region Test Region

func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("up"):
		if is_in_arrow_one:
			tutorial_u_is.open_attk_tutorial_panel()
		elif is_in_arrow_two:
			tutorial_u_is.open_jump_block_panel()
		elif is_in_arrow_three:
			tutorial_u_is.open_rage_panel()
		elif is_in_arrow_four: 	
			tutorial_u_is.open_rage_skill_panel()

#endregion


#region Area Signals

func _on_exit_area_body_entered(body: Node2D) -> void:
	var player = body.get_tree().get_first_node_in_group("Player_target")
	
	if player:
		GameManager.change_scene_with_transition(GRASS_LAND_SCENE)

func _on_arrow_one_area_body_entered(body: Node2D) -> void:

	var player = body.get_tree().get_first_node_in_group("Player_target")

	if player:
		is_in_arrow_one = true



func _on_arrow_two_area_body_entered(body: Node2D) -> void:
	
	var player = body.get_tree().get_first_node_in_group("Player_target")

	if player:
		is_in_arrow_two = true


func _on_arrow_three_area_body_entered(body: Node2D) -> void:
	var player = body.get_tree().get_first_node_in_group("Player_target")

	if player:
		is_in_arrow_three = true


func _on_arrow_four_area_body_entered(body: Node2D) -> void:
	
	var player = body.get_tree().get_first_node_in_group("Player_target")

	if player:
		is_in_arrow_four = true



#endregion

#region test Signals

#endregion


#region Arrow Animations
func start_ui_and_arrows() -> void:
	ui_layer.visible = true
	
	animate_arrows()

func animate_arrows() -> void:
	
	for arrow in arrows:
		var original_pos: Vector2 = arrow_original_positions[arrow]
		var up_pos := original_pos + Vector2(0.0, -arrow_float_amount)
		
		var tween := create_tween()
		tween.set_loops()
		tween.tween_property(arrow, "position", up_pos, arrow_float_duration)
		tween.tween_property(arrow, "position", original_pos, arrow_float_duration)


#endregion

#region Area Body Exited


func _on_arrow_one_area_body_exited(body: Node2D) -> void:

	is_in_arrow_one = false

func _on_arrow_two_area_body_exited(body: Node2D) -> void:
	
	is_in_arrow_two = false


func _on_arrow_three_area_body_exited(body: Node2D) -> void:
	
	is_in_arrow_three = false

func _on_arrow_four_area_body_exited(body: Node2D) -> void:
	
	is_in_arrow_four = false

#endregion

#region Transitions


#endregion -- Transitions
