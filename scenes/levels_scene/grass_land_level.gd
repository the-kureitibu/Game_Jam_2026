extends Node2D

#region References 

#region Menu Panel


@onready var menu_ui: Control = $MainUICanvas/MenuUI

#endregion Menu Panel

@onready var player_one: CharacterBody2D = $PlayerScene
@onready var player_two: CharacterBody2D = $PlayerTwoScene
@onready var current_path = get_tree().current_scene.scene_file_path
@onready var main_ui_canvas: CanvasLayer = $MainUICanvas
@onready var collision_shape_2d: CollisionShape2D = $TransitionArea/CollisionShape2D
@onready var last_pos_catcher: RayCast2D = $LastPosCatcher

var is_body_in_area := false
var position_captured := false



const DEMON_REALM_SCENE: String = "res://scenes/levels_scene/demon_realm_level.tscn"

#region BGM 

@onready var woodland_fantasy_bgm: String = "res://assets/audio/bgm/Woodland Fantasy.mp3"

#endregion -- BGM


#endregion --  References 


func _enter_tree() -> void:
	GameManager.game_scene_state = GameManager.GameLevelStates.GRASSLAND_SCENE
	
func _ready() -> void:
	AudioManager.fade_to_bgm(woodland_fantasy_bgm, "bgm", -10.0)

	player_one.global_position = $PlayerScene.global_position
	player_two.global_position = $PlayerTwoScene.global_position

	GameManager.capture_save_points(
		current_path,
		player_one.global_position,
		player_two.global_position
	)
	
	SignalHub.unpause_after_menu_exit.connect(unpause_stage)
	


func _process(delta: float) -> void:
	
	if last_pos_catcher.is_colliding():
		var collider = last_pos_catcher.get_collider()
		
		if collider.name != 'PlayerScene':
			print("not a player")
			return
		else:
			if position_captured:
				return
			
			position_captured = true
			capture_last_position()



func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		
		menu_ui.open_menu_panel()

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
		
		main_ui_canvas.visible = false
		position_captured = false
		AudioManager.fade_out_bgm("bgm")
		
		GameManager.capture_player_stats(player_one.p_health, player_one.r_amount)
		GameManager.change_scene_with_transition(DEMON_REALM_SCENE)
		
func unpause_stage() -> void:
	if get_tree().paused:
		get_tree().paused = false

#endregion -- Transitions 
