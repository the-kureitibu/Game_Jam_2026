extends Node


#region Base Vars

@onready var game_scene_state = GameLevelStates.START_SCENE

#region References

const TRANSITION_SCENE = preload("res://scenes/ui/transition_scene.tscn")
const TEXT_ANNOUNCER = preload("res://scenes/ui/text_announcer.tscn")

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


#endregion -- Base Vars 

func _ready() -> void:
	if (game_scene_state != GameLevelStates.START_SCENE or 
		game_scene_state != GameLevelStates.PROLOGUE_SCENE or 
		game_scene_state != GameLevelStates.TUTORIAL_SCENE):
		
		SignalHub.transition_done.connect(announce_level_scene)

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
