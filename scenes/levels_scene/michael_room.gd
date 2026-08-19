extends Node2D

#region References

@onready var michael_statue: AnimatedSprite2D = $MichaelStatue
var cur_statue_frame := 0
var max_statue_frame := 3
var michael_summoned: bool = false
@onready var michael_marker: Marker2D = $MichaelMarker
@onready var top_control_michael: Control = $TutorialPopup/TopControl
@onready var exit_button: Button = $TutorialPopup/TopControl/BasePanel/ExitButtonContainer/VBoxContainer/ExitButton



const MICHAEL_SCENE = preload("res://scenes/player_scene/michael.tscn")
const DEMON_REALM: String = "res://scenes/levels_scene/demon_realm_level.tscn"

#region -- References



#region Functions

#region Processes

func _enter_tree() -> void:
	GameManager.game_scene_state = GameManager.GameLevelStates.MICHAEL_ROOM

func _ready() -> void:
	top_control_michael.visible = false
	SignalHub.show_michael_tutorial.connect(show_tutorial)


#endregion -- Processes

#region Statue related

func update_statue_sprite(sprite: AnimatedSprite2D, target_frame: int) -> void:
	sprite.frame = target_frame
	
	if sprite.frame == max_statue_frame:
		summon_michael(MICHAEL_SCENE)

#endregion -- Statue related

#region Michael Scene Instantiate

func summon_michael(scene: PackedScene) -> void:
	if michael_summoned:
		return
	
	michael_summoned = true
	
	var mic_scene = scene.instantiate()
	mic_scene.captured_pos = michael_marker.global_position
	add_child(mic_scene)


func show_tutorial() -> void:
	await get_tree().process_frame
	
	top_control_michael.visible = true
	
#endregion Michael Scene Instantiate


#region Area Signals

func _on_statue_hurt_box_area_entered(area: Area2D) -> void:
	var player = area.name
	
	if player == 'HitBox':
		cur_statue_frame += 1
		update_statue_sprite(michael_statue, cur_statue_frame)
	else:
		print("Not Hitbox: ")

func _on_exit_area_body_entered(body: Node2D) -> void:
	var player = body.get_tree().get_first_node_in_group("Player_target")

	if player:
		GameManager.change_scene_with_transition(DEMON_REALM)

#endregion -- Area Signals

#region Button Signals

func _on_exit_button_pressed() -> void:
	await get_tree().process_frame
	
	top_control_michael.visible = false

#endregion -- Button Signals

#endregion -- Functions
