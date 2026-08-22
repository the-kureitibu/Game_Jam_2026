extends Node2D

#region References

const PRE_FIGHT_DIALOGUE = preload("res://scenes/ui/pre_boss_dialogue.tscn")

#endregion -- References

#region Functions 

#region Processes 
func _enter_tree() -> void:
	SignalHub.pre_boss_fight_dialogue.emit()
	GameManager.game_scene_state = GameManager.GameLevelStates.BOSS_ROOM

func _ready() -> void:
	start_pre_fight_dialogue(PRE_FIGHT_DIALOGUE)
	

func start_pre_fight_dialogue(scene: PackedScene) -> void:
	var boss_room_scene = scene.instantiate()
	$Projectiles.add_child(boss_room_scene)

#endregion -- Processes 

#endregion -- Functions 
