extends Node2D

#region References

const PRE_FIGHT_DIALOGUE = preload("res://scenes/ui/pre_boss_dialogue.tscn")

#endregion -- References

#region Functions 

#region Processes 
func _enter_tree() -> void:
	if GameManager.game_scene_state != GameManager.GameLevelStates.BOSS_ROOM:
		GameManager.game_scene_state = GameManager.GameLevelStates.BOSS_ROOM
	
	SignalHub.pre_boss_fight_dialogue.emit()
	

func _ready() -> void:
	start_pre_fight_dialogue(PRE_FIGHT_DIALOGUE)
	
	print(GameManager.GameLevelStates.keys()[GameManager.game_scene_state]) 
	print(GameManager.can_start_boss_fight)
	

func start_pre_fight_dialogue(scene: PackedScene) -> void:
	var boss_room_scene = scene.instantiate()
	$CanvasLayer.add_child(boss_room_scene)

#endregion -- Processes 

#endregion -- Functions 
