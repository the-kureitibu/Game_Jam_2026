extends Node


#region Base Vars

@onready var game_scene_state = GameLevelStates.START_SCENE

#region References

const TRANSITION_SCENE = preload("res://scenes/ui/transition_scene.tscn")

#endregion -- References

#region Game Enums


enum GameLevelStates {
	START_SCENE,
	PROLOGUE_SCENE,
	TUTORIAL_SCENE,
	GRASSLAND_SCENE
}
	
#endregion -- Game Enums

#endregion -- Base Vars 

func change_scene_with_transition(scene_path: PackedScene) -> void:
	var trans_scene = TRANSITION_SCENE.instantiate()
	get_tree().root.add_child(trans_scene)
	trans_scene.transition_to_scene(scene_path)
