extends Control

#region References

#region References Nodes
@onready var bgm_volume: HSlider = $BasePanel/MainVBox/BG/ImageVBContainer/BGMVolume
@onready var sfx_volume: HSlider = $BasePanel/MainVBox/BG/ImageVBContainer/SFXVolume
@onready var title_button: Button = $BasePanel/MainVBox/BG/ImageVBContainer/TitleButton
@onready var exit_button: Button = $BasePanel/MainVBox/BG/ImageVBContainer/ExitButton
@onready var x_button: Button = $BasePanel/ExitButtonContainer/VBoxContainer/XButton

@onready var SFX_AGH: String = "res://assets/audio/sfx/sfx agh.wav"
@onready var woodland_fantasy_bgm: String = "res://assets/audio/bgm/Woodland Fantasy.mp3"
@onready var base_panel: MarginContainer = $BasePanel
@onready var typing_sfx: String = "res://assets/audio/sfx/typewriter3.wav"
const START_SCENE: String = "res://scenes/ui/start_screen.tscn"


#endregion -- References Nodes


#endregion -- References


#region Functions

#region Processes

#endregion -- Processes

#region Volumes

func _ready() -> void:
	base_panel.visible = false
	bgm_volume.value = 50.0
	sfx_volume.value = 50.0

func open_menu_panel() -> void:
	base_panel.visible = true

func adjust_sfx_volume() -> void:
	pass
	
func _on_sfx_volume_value_changed(value: float) -> void:
	if !base_panel.visible:
		return
	
	var bus_index := AudioServer.get_bus_index("SFX")
	var linear_value := value / 100.0
	
	if linear_value <= 0.0:
		AudioServer.set_bus_volume_db(bus_index, -80.0)
	else:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(linear_value))

	
	AudioManager.play_music(SFX_AGH, "voice", -10.0)



func _on_bgm_volume_value_changed(value: float) -> void:
	if !base_panel.visible:
		return
	
	var bus_index := AudioServer.get_bus_index("Music")

	
	var linear_value := value / 100.0
	
	if linear_value <= 0.0:
		AudioServer.set_bus_volume_db(bus_index, -80.0)
	else:
		AudioServer.set_bus_volume_db(
			bus_index,
			linear_to_db(linear_value)
		)

	if !AudioManager.bgm_player.is_playing():
		AudioManager.play_music(woodland_fantasy_bgm, "bgm", -10.0)

#endregion -- Volumes


#region Buttons

func _on_title_button_pressed() -> void:

	SignalHub.restart_game.emit()
	
	AudioManager.fade_out_bgm("bgm")
	GameManager.change_scene_with_transition(START_SCENE)


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_x_button_pressed() -> void:
	AudioManager.play_music(typing_sfx, "oneshot", -6.0)
	base_panel.visible = false


#endregion -- Buttons

#endregion -- Functions


func _on_sfx_volume_drag_started() -> void:
	pass
