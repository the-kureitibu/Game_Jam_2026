extends Control

#region References

@onready var video_stream_player: VideoStreamPlayer = $VideoStreamPlayer

@onready var first_label_container: VBoxContainer = $MainLabelContainer/PanelContainer/FirstLabelContainer
@onready var right_text_container: VBoxContainer = $MainLabelContainer/PanelContainer/RightTextContainer
@onready var left_text_container: VBoxContainer = $MainLabelContainer/PanelContainer/LeftTextContainer

@onready var prev_label: RichTextLabel = $MainLabelContainer/PanelContainer/FirstLabelContainer/PrevLabel
@onready var right_text_label: RichTextLabel = $MainLabelContainer/PanelContainer/RightTextContainer/HBoxContainer/RightTextLabel
@onready var left_text_label: RichTextLabel = $MainLabelContainer/PanelContainer/LeftTextContainer/HBoxContainer/LeftTextLabel

#endregion -- References

#region Text Dictionaries

@onready var text_collection: Dictionary = {
	
	"speaker_one" = {
		"line_one": "Hey… did you hear? The hero party apparently almost got annihilated and barely made it back…",
		"line_two": "Yeah… and this happened after they expelled Amiya the Saint too…",
		"line_three": "Hey look, it’s Amiya…",
		"line_four": "So it seems! But who’s the little spider with her… they look cute.",
		"line_five": "Yea… Ami cute."
	},
	
	"speaker_two" = {
		"line_one": "No way? Who’s gonna defeat the demon king now!?",
		"line_two": "I was right… It was Amiya who carried the party all along… It’s all that hero’s fault-",
		"line_three": "What she’s doing here- what?! She’s going solo?!",
		"line_four": "I agree… and Amiya looks cute too…"
	}
}

#endregion -- Text Dictionaries


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
