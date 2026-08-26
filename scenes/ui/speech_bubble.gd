extends Control

@onready var main_panel: PanelContainer = $MainPanel
@onready var label: Label = $MainPanel/HBoxContainer/Label



func update_text(text: String) -> void:
	label.text = text
