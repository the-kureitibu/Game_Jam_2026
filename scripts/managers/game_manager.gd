extends Node


#region Base Vars

var game_scene_state = GameLevelStates.START_SCENE

#region References

const TRANSITION_SCENE = preload("res://scenes/ui/transition_scene.tscn")
const TEXT_ANNOUNCER = preload("res://scenes/ui/text_announcer.tscn")
var current_scene_path: String = ""
var previous_scene_path: String = ""
var demon_realm_path: String = "res://scenes/levels_scene/demon_realm_level.tscn"
var is_immortal: bool = true

var is_tutorial_menu_open := false

#endregion -- References

#region Game Enums


enum GameLevelStates {
	START_SCENE,
	PROLOGUE_SCENE,
	TUTORIAL_SCENE,
	GRASSLAND_SCENE,
	DEMON_REALM,
	BOSS_LEVEL,
	MICHAEL_ROOM,
	BOSS_ROOM,
	END_GAME,
	EPILOGUE
}
	
#endregion -- Game Enums

#region Spawn Points

var player_one_spawn_p: Vector2 = Vector2.ZERO
var player_two_spawn_p: Vector2 = Vector2.ZERO
var player_one_prev_spawn: Vector2 = Vector2.ZERO
var player_two_prev_spawn: Vector2 = Vector2.ZERO


var demon_realm_p1: Vector2 = Vector2.ZERO
var demon_realm_p2: Vector2 = Vector2.ZERO

var player_saved_health: float = 0.0
var player_saved_rage: float = 0.0


#endregion -- Spawn Points

#region Levels/Boss Fight 

var is_pre_dialogue: bool = false
var can_start_boss_fight: bool = false
var can_start_second_phase: bool = false
var is_second_phase_pre_dialogue: bool = false

#endregion -- Levels/Boss Fight 

#endregion -- Base Vars 

#region Processes
func _ready() -> void:

	if (game_scene_state != GameLevelStates.START_SCENE or 
		game_scene_state != GameLevelStates.PROLOGUE_SCENE or 
		game_scene_state != GameLevelStates.TUTORIAL_SCENE or 
		game_scene_state != GameLevelStates.EPILOGUE):
		
		SignalHub.transition_done.connect(announce_level_scene)
	
	
	SignalHub.player_died.connect(player_death)
	SignalHub.stage_restart.connect(restart_current_stage)
	SignalHub.back_to_previous_stage.connect(back_to_previous_stage)
	SignalHub.michael_blessing_get.connect(make_player_immortal)
	SignalHub.pre_boss_fight_dialogue.connect(update_pre_boss_fight)
	SignalHub.pre_fight_dialogue_done.connect(start_boss_fight)
	
	SignalHub.ready_for_second_phase.connect(update_boss_second_phase)
	SignalHub.mid_fight_dialogue_done.connect(start_boss_second_phase)
	
	SignalHub.restart_game.connect(restart_game_manager)


#endregion -- Processes

#region Restart Levels

func restart_game_manager() -> void:
	current_scene_path = ""
	previous_scene_path = ""
	is_immortal = false
	player_one_spawn_p = Vector2.ZERO
	player_two_spawn_p = Vector2.ZERO
	player_one_prev_spawn = Vector2.ZERO
	player_two_prev_spawn = Vector2.ZERO
	player_saved_health = 0.0
	player_saved_rage = 0.0
	is_pre_dialogue = false
	can_start_boss_fight = false
	can_start_second_phase = false
	is_second_phase_pre_dialogue = false


#endregion -- Restart Levels


#region Levels Start
func announce_level_scene() -> void:
	clear_announcers()
	
	var announcer_scene = TEXT_ANNOUNCER.instantiate()
	get_tree().root.add_child(announcer_scene)
	
	match game_scene_state:
		GameLevelStates.GRASSLAND_SCENE:
			announcer_scene.announce("Grass Land")
		GameLevelStates.DEMON_REALM:
			announcer_scene.announce("Demon Realm")
		GameLevelStates.MICHAEL_ROOM:
			announcer_scene.announce("Forgotten Sanctuary")
		GameLevelStates.BOSS_LEVEL:
			announcer_scene.announce("Demon Castle")
		GameLevelStates.END_GAME:
			announcer_scene.announce("Huff, Huff, We did it, Bucko.")
			

func clear_announcers() -> void:
	for announcer in get_tree().get_nodes_in_group("text_announcer"):
		if is_instance_valid(announcer):
			announcer.queue_free()

func change_scene_with_transition(scene_path: String) -> void:
	var trans_scene = TRANSITION_SCENE.instantiate()
	get_tree().root.add_child(trans_scene)
	trans_scene.transition_to_scene(scene_path)


func change_scene_to_previous(scene_path: String, p1_spawn: Vector2, p2_spawn: Vector2) -> void:

	var trans_scene = TRANSITION_SCENE.instantiate()
	get_tree().root.add_child(trans_scene)
	trans_scene.transition_to_previous_stage(scene_path, p1_spawn, p2_spawn)

func back_to_previous_stage() -> void:
	if current_scene_path == "":
		push_error("No current_scene_path registered. Cannot restart stage.")
		return
	
	#if game_scene_state == GameLevelStates.BOSS_LEVEL:
		#change_scene_to_previous(demon_realm_path, demon_realm_p1, demon_realm_p2)
	#else:

	change_scene_to_previous(previous_scene_path, player_one_prev_spawn, player_two_prev_spawn)

	await get_tree().process_frame
	

func restart_current_stage() -> void:

	await get_tree().process_frame
	
	if game_scene_state == GameLevelStates.BOSS_ROOM:
		var stats = PlayerStats
		
		change_scene_with_transition(demon_realm_path)
		player_saved_health = 120.0
		player_saved_rage  = 0.0
	else:
		if current_scene_path == "":
			push_error("No current_scene_path registered. Cannot restart stage.")
			return
		
		change_scene_with_transition(current_scene_path)


#endregion -- Levels Start


#region Save Points

func capture_save_points(scene_path: String, p1_spawn: Vector2, p2_spawn: Vector2) -> void:

	player_one_spawn_p = p1_spawn
	player_two_spawn_p = p2_spawn
	current_scene_path = scene_path


func capture_last_points(scene_path: String, p1_spawn: Vector2, p2_spawn: Vector2) -> void:

	player_two_prev_spawn = p2_spawn
	player_one_prev_spawn = p1_spawn
	previous_scene_path = scene_path


func capture_player_stats(p_health: float, p_rage: float) -> void:
	player_saved_health = p_health
	player_saved_rage = p_rage


#endregion -- Save Points


#region Player Related

func make_player_immortal() -> void:
	is_immortal = true


#region Restart Stage  

func player_death() -> void:
	var announcer_scene = TEXT_ANNOUNCER.instantiate()
	get_tree().root.add_child(announcer_scene)
	
	var announce_text: String = ""
	
	if game_scene_state == GameLevelStates.BOSS_ROOM:
		announce_text = "You've Failed, Spidor. Perhaps, Somewhere in the Demon Realm lies forgotten power."
	else:
		announce_text = "You've Failed, Spidor"
	
	announcer_scene.announce_death(announce_text)

#endregion --  Restart Stage  

#region Boss Fight Related

func update_pre_boss_fight() -> void:
	is_pre_dialogue = true

func update_boss_second_phase() -> void:
	
	is_second_phase_pre_dialogue = true

func start_boss_fight() -> void:
	can_start_boss_fight = true

func start_boss_second_phase() -> void:
	can_start_second_phase = true
	SignalHub.start_second_phase.emit()


#endregion -- Boss Fight Related 

#endregion Player Related 
