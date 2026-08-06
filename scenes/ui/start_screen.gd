extends Control

#region Base Vars
#region Texture Rects

@onready var title_top: TextureRect = $MainMargin/TitleOne
@onready var title_mid: TextureRect = $MainMargin/TitleTwo
@onready var title_bot: TextureRect = $MainMargin/TitleThree

#endregion

#region Button Rects

@onready var button_start: Button = $MainMargin/ButtonContainer/StartButton
@onready var button_exit: Button = $MainMargin/ButtonContainer/ExitButton

#endregion

#region Arrays 

@onready var title_parts: Array = [
	title_top, 
	title_mid,
	title_bot
]

@onready var buttons: Array = [
	button_start, 
	button_exit
]


#endregion
#endregion

func _ready() -> void:
	hide_title_screen_parts()
	await reveal_title_sequence()
	start_pulse_loop()

func hide_title_screen_parts() -> void:
	for item in title_parts:
		item.modulate.a = 0.0
	
	for button in buttons:
		button.modulate.a = 0.0
		button.disabled = true


func reveal_title_sequence() -> void:
	for item in title_parts:
		await reveal_control(item, 24.0, 0.25)
		await get_tree().create_timer(0.12).timeout
	
	await get_tree().create_timer(0.35).timeout
	
	for button in buttons:
		await reveal_control(button, 12.0, 0.18)
		button.disabled = false

func reveal_control(control: Control, x_offset: float, duration: float) -> void:
	var original_pos := control.position
	
	control.position = original_pos + Vector2(-x_offset, 0.0)
	control.modulate.a = 0.0
	control.visible = true
	
	var tween := create_tween()
	tween.tween_property(control, "position", original_pos, duration)
	tween.parallel().tween_property(control, "modulate:a", 1.0, duration)
	
	await tween.finished
	

func start_pulse_loop() -> void:
	for item in title_parts:
		pulse_control(item)
	
	for button in buttons:
		pulse_control(button)
		

func pulse_control(control: Control) -> void:
	var tween := create_tween()
	tween.set_loops()
	
	tween.tween_property(control, "modulate", Color(1.35, 1.35, 1.35, 1.0), 0.45)
	tween.tween_property(control, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.45)

func _process(delta: float) -> void:
	pass
