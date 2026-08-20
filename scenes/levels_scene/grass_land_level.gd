extends Node2D

#region References 

@onready var player_one: CharacterBody2D = $PlayerScene
@onready var player_two: CharacterBody2D = $PlayerTwoScene
@onready var current_path = get_tree().current_scene.scene_file_path
@onready var main_ui_canvas: CanvasLayer = $MainUICanvas


const DEMON_REALM_SCENE: String = "res://scenes/levels_scene/demon_realm_level.tscn"


#endregion --  References 


func _enter_tree() -> void:
	GameManager.game_scene_state = GameManager.GameLevelStates.GRASSLAND_SCENE
	
func _ready() -> void:

	player_one.global_position = $PlayerScene.global_position
	player_two.global_position = $PlayerTwoScene.global_position

	GameManager.capture_save_points(
		current_path,
		player_one.global_position,
		player_two.global_position
	)


#region Transitions 


func capture_last_position() -> void:
	var player1_last_pos = player_one.global_position
	var player2_last_pos = player_two.global_position
	
	GameManager.capture_last_points(
		current_path,
		player1_last_pos,
		player2_last_pos
	)
	
	GameManager.capture_player_stats(player_one.p_health, player_one.r_amount)

func _on_transition_area_body_entered(body: Node2D) -> void:
	var player = body.get_tree().get_first_node_in_group("Player_target")
	
	if player:
		capture_last_position()
		main_ui_canvas.visible = false
		
		GameManager.change_scene_with_transition(DEMON_REALM_SCENE)

#endregion -- Transitions 
