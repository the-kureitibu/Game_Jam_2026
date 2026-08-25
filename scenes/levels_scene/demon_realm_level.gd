extends Node2D

#region References 

@onready var player_one: CharacterBody2D = $PlayerScene
@onready var player_two: CharacterBody2D = $PlayerTwoScene
@onready var current_path = get_tree().current_scene.scene_file_path
@onready var main_ui_canvas: CanvasLayer = $MainUICanvas

const DEMON_REALM_SCENE: String = "res://scenes/levels_scene/demon_realm_level.tscn"
const MICHAEL_ROOM_SCENE: String = "res://scenes/levels_scene/michael_room.tscn"
const BOSS_CASTLE_SCENE: String = "res://scenes/levels_scene/boss_level.tscn"

#region BGM

@onready var orchestra_bgm: String = "res://assets/audio/bgm/Героическая минорная.mp3"

#endregion BGM


#endregion --  References 


func _enter_tree() -> void:
	GameManager.game_scene_state = GameManager.GameLevelStates.DEMON_REALM
	
	
func _ready() -> void:
	AudioManager.fade_to_bgm(orchestra_bgm, -10.0)
	
	player_one.global_position = $PlayerScene.global_position
	player_two.global_position = $PlayerTwoScene.global_position
	
	player_one.p_health = GameManager.player_saved_health
	player_one.r_amount = GameManager.player_saved_rage
	
	
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

func _on_transition_previous_body_entered(body: Node2D) -> void:
	var player = body.get_tree().get_first_node_in_group("Player_target")
	
	if player:
		AudioManager.fade_out_bgm()
		
		GameManager.capture_player_stats(player_one.p_health, player_one.r_amount)
		
		SignalHub.back_to_previous_stage.emit()


func _on_to_michael_body_entered(body: Node2D) -> void:
	var player = body.get_tree().get_first_node_in_group("Player_target")
	
	if player:
		main_ui_canvas.visible = false
		
		AudioManager.fade_out_bgm()
		GameManager.change_scene_with_transition(MICHAEL_ROOM_SCENE)


func _on_to_boss_castle_body_entered(body: Node2D) -> void:
	var player = body.get_tree().get_first_node_in_group("Player_target")
	
	if player:
		capture_last_position()
		main_ui_canvas.visible = false
		
		AudioManager.fade_out_bgm()
		GameManager.change_scene_with_transition(BOSS_CASTLE_SCENE)


#endregion -- Transitions 
