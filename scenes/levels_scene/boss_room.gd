extends Node2D

#region References

const PRE_FIGHT_DIALOGUE = preload("res://scenes/ui/pre_boss_dialogue.tscn")
const PRE_SECOND_PHASE_DIALOGUE = preload("res://scenes/ui/second_phase_dialogue.tscn")
const EPILOGUE_SCENE: String = "res://scenes/ui/epilogue_scene.tscn"
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var main_parallax: Node2D = $MainParallax


#endregion -- References


#region Functions 

#region Processes 
func _enter_tree() -> void:
	if GameManager.game_scene_state != GameManager.GameLevelStates.BOSS_ROOM:
		GameManager.game_scene_state = GameManager.GameLevelStates.BOSS_ROOM
	
	SignalHub.pre_boss_fight_dialogue.emit()
	

func _ready() -> void:
	main_parallax.global_position = Vector2(0, -100)
	
	
	start_pre_fight_dialogue(PRE_FIGHT_DIALOGUE)

	SignalHub.ready_for_second_phase.connect(handle_second_phase_dialogue)
	
	SignalHub.end_game_start.connect(start_end_fight_dialogue)
	SignalHub.start_end_game_dialogue.connect(move_to_end_dialogue)
	
	
#endregion -- Processes 

func move_to_end_dialogue() -> void:
	await get_tree().process_frame
	
	AudioManager.fade_out_bgm("bgm")
	canvas_layer.visible = false
	GameManager.change_scene_with_transition(EPILOGUE_SCENE)

func start_end_fight_dialogue() -> void:
	GameManager.game_scene_state = GameManager.GameLevelStates.END_GAME
	GameManager.announce_level_scene()

func start_pre_fight_dialogue(scene: PackedScene) -> void:
	var pre_fight_dialogue = scene.instantiate()
	$CanvasLayer.add_child(pre_fight_dialogue)

func handle_second_phase_dialogue() -> void:
	start_second_phase_dialogue(PRE_SECOND_PHASE_DIALOGUE)

func start_second_phase_dialogue(scene: PackedScene) -> void:
	var second_phase_dialogue = scene.instantiate()
	$CanvasLayer.add_child(second_phase_dialogue)


#endregion -- Functions 
