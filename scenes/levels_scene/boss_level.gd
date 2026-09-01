extends Node2D

#region References 
@onready var menu_ui: Control = $MainUI/MenuUI
@onready var main_ui: Control = $MainUI/MainUI

@onready var player_one: CharacterBody2D = $PlayerScene
@onready var player_two: CharacterBody2D = $PlayerTwoScene
@onready var current_path = get_tree().current_scene.scene_file_path

const DEMON_REALM_SCENE: String = "res://scenes/levels_scene/demon_realm_level.tscn"
const BOSS_ROOM_SCENE: String = "res://scenes/levels_scene/boss_room.tscn"

var dmg: float = 10000.0

var captured_one_global_position: Vector2 = Vector2.ZERO
var captured_two_global_position: Vector2 = Vector2.ZERO


#region BGM 

@onready var orchestra_bgm: String = "res://assets/audio/bgm/Героическая минорная.mp3"

#endregion -- BGM


#endregion --  References 


func _enter_tree() -> void:
	GameManager.game_scene_state = GameManager.GameLevelStates.BOSS_LEVEL
	

func _ready() -> void:
	AudioManager.fade_to_bgm(orchestra_bgm, "bgm", -10.0)
	
	player_one.global_position = $PlayerScene.global_position
	player_two.global_position = $PlayerTwoScene.global_position
	
	player_one.p_health = GameManager.player_saved_health
	player_one.r_amount = GameManager.player_saved_rage

	captured_one_global_position = player_one.global_position
	captured_two_global_position = player_two.global_position
	
	player_one.open_and_update_text("YABAっ", "YABAっ")


	GameManager.capture_save_points(
		current_path,
		player_one.global_position,
		player_two.global_position
	)
	
	SignalHub.restart_game.connect(hide_health_ui)
	SignalHub.unpause_after_menu_exit.connect(unpause_stage)

func unpause_stage() -> void:
	if get_tree().paused:
		get_tree().paused = false
		
func hide_health_ui() -> void:
	main_ui.visible = false


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

func _on_to_demon_realm_body_entered(body: Node2D) -> void:
	var player = body.get_tree().get_first_node_in_group("Player_target")
	
	if player:
		
		AudioManager.fade_out_bgm("bgm")
		
		GameManager.capture_player_stats(player_one.p_health, player_one.r_amount)
		SignalHub.back_to_previous_stage.emit()



func _on_to_boss_room_body_entered(body: Node2D) -> void:
	var player = body.get_tree().get_first_node_in_group("Player_target")
	
	if player:
		main_ui.visible = false
		
		AudioManager.fade_out_bgm("bgm")
		GameManager.change_scene_with_transition(BOSS_ROOM_SCENE)


#endregion -- Transitions 

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		
		menu_ui.open_menu_panel()


func _on_insta_death_pit_area_entered(area: Area2D) -> void:
	
	var p_target = area.get_tree().get_first_node_in_group("Player_target")


	if GameManager.is_immortal:
		player_one.global_position = captured_one_global_position
		player_two.global_position = captured_two_global_position

		
	elif p_target and "handle_hurt" in p_target:
		p_target.handle_hurt(dmg)
