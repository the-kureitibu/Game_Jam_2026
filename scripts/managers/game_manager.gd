extends Node


#region Base Vars

@onready var game_scene_state = GameLevelStates.START_SCENE

#region References

const TRANSITION_SCENE = preload("res://scenes/ui/transition_scene.tscn")
const TEXT_ANNOUNCER = preload("res://scenes/ui/text_announcer.tscn")

var current_scene: Node


#endregion -- References

#region Game Enums


enum GameLevelStates {
	START_SCENE,
	PROLOGUE_SCENE,
	TUTORIAL_SCENE,
	GRASSLAND_SCENE,
	DEMON_REALM,
	BOSS_LEVEL,
	SECRET_SANCTUARY
}
	
#endregion -- Game Enums

#region Spawn Points

var player_one_spawn_p: Vector2 = Vector2.ZERO
var player_two_spawn_p: Vector2 = Vector2.ZERO


#endregion -- Spawn Points

#endregion -- Base Vars 

#region Processes
func _ready() -> void:
	if (game_scene_state != GameLevelStates.START_SCENE or 
		game_scene_state != GameLevelStates.PROLOGUE_SCENE or 
		game_scene_state != GameLevelStates.TUTORIAL_SCENE):
		
		capture_save_points()
		
		SignalHub.transition_done.connect(announce_level_scene)
	
	
	SignalHub.player_died.connect(player_death)
	SignalHub.stage_restart.connect(transition_to_start)
	
#endregion -- Processes

#region Levels Start
func announce_level_scene() -> void:
	var announcer_scene = TEXT_ANNOUNCER.instantiate()
	get_tree().root.add_child(announcer_scene)
	
	match game_scene_state:
		GameLevelStates.GRASSLAND_SCENE:
			announcer_scene.announce("Grass Land")
		GameLevelStates.DEMON_REALM:
			announcer_scene.announce("Demon Realm")
		GameLevelStates.SECRET_SANCTUARY:
			announcer_scene.announce("Secret Sanctuary")
		GameLevelStates.BOSS_LEVEL:
			announcer_scene.announce("Demon Castle")
			
	

func change_scene_with_transition(scene_path: PackedScene) -> void:
	var trans_scene = TRANSITION_SCENE.instantiate()
	get_tree().root.add_child(trans_scene)
	trans_scene.transition_to_scene(scene_path)

func transition_to_start() -> void:
	var trans_scene = TRANSITION_SCENE.instantiate()
	get_tree().root.add_child(trans_scene)
	trans_scene.transition_to_scene(current_scene)


#endregion -- Levels Start



#region Save Points

func capture_save_points() -> void:
	var player_one = get_tree().get_first_node_in_group("Player_target")
	var player_two = get_tree().get_first_node_in_group("Player_two")
	
	if player_one and player_two == null:
		print("Players does not exist")
		return
	
	if player_one and player_two:
		player_one_spawn_p = player_one.global_position
		player_two_spawn_p = player_two.global_position
		
		current_scene = get_tree().current_scene

#endregion -- Save Points



#region Player Related

#region Restart Stage  

func player_death() -> void:
	var announcer_scene = TEXT_ANNOUNCER.instantiate()
	get_tree().root.add_child(announcer_scene)
	
	announcer_scene.announce_death("You've Failed, Spidor")

#endregion --  Restart Stage  

#func restart_stage() -> void:
	#var announcer_scene = TEXT_ANNOUNCER.instantiate()
	#get_tree().root.add_child(announcer_scene)
	#
	#announcer_scene.announce_death("You've Failed, Spidor")



#endregion Player Related 
