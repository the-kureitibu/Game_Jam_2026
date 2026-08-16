extends Node2D

#region References 

@onready var player_one: CharacterBody2D = $PlayerScene
@onready var player_two: CharacterBody2D = $PlayerTwoScene

const DEMON_REALM_SCENE: String = "res://scenes/levels_scene/demon_realm_level.tscn"


#endregion --  References 


func _enter_tree() -> void:
	GameManager.game_scene_state = GameManager.GameLevelStates.GRASSLAND_SCENE
	
func _ready() -> void:
	player_one.global_position = $PlayerScene.global_position
	player_two.global_position = $PlayerTwoScene.global_position
	

#region Transitions 

func _on_transition_area_body_entered(body: Node2D) -> void:
	var player = body.get_tree().get_first_node_in_group("Player_target")
	
	if player:
		GameManager.change_scene_with_transition(DEMON_REALM_SCENE)

#endregion -- Transitions 
