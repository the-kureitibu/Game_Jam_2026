extends Control

#region References

#region References Nodes
@onready var bgm_volume: HSlider = $BasePanel/MainVBox/BG/ImageVBContainer/BGMVolume
@onready var sfx_volume: HSlider = $BasePanel/MainVBox/BG/ImageVBContainer/SFXVolume
@onready var title_button: Button = $BasePanel/MainVBox/BG/ImageVBContainer/TitleButton
@onready var exit_button: Button = $BasePanel/MainVBox/BG/ImageVBContainer/ExitButton
@onready var x_button: Button = $BasePanel/ExitButtonContainer/VBoxContainer/XButton

#endregion -- References Nodes


#endregion -- References


#region Functions

#region Processes


#endregion -- Processes


#region Volumes

func adjust_sfx_volume() -> void:
	pass
	
func _on_sfx_volume_value_changed(value: float) -> void:
	var bus_index := AudioServer.get_bus_index("SFX")
	var linear_value := value / 100.0
	
	if linear_value <= 0.0:
		AudioServer.set_bus_volume_db(bus_index, -80.0)
	else:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(linear_value))

	var test_volume := AudioServer.get_bus_volume_db(bus_index)
	print(test_volume)

func _on_bgm_volume_value_changed(value: float) -> void:
	var bus_index := AudioServer.get_bus_index("Music")

	
	var linear_value := value / 100.0
	
	if linear_value <= 0.0:
		AudioServer.set_bus_volume_db(bus_index, -80.0)
	else:
		AudioServer.set_bus_volume_db(
			bus_index,
			linear_to_db(linear_value)
		)

	var test_volume := AudioServer.get_bus_volume_db(bus_index)
	print(test_volume)

#endregion -- Volumes


#region Buttons

func _on_title_button_pressed() -> void:
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	pass # Replace with function body.


func _on_x_button_pressed() -> void:
	pass # Replace with function body.

#endregion -- Buttons

#endregion -- Functions


func _on_sfx_volume_drag_started() -> void:
	print("Im draggin")
