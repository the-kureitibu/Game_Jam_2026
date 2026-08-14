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

#region Timers 

@onready var vid_end_time: float = 28.0

#endregion -- Timers

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

#region Dialogue Related

@onready var current_index: int = 0
@onready var text_collect_keys = text_collection.keys()
@onready var speaker_one_collect = text_collect_keys[0]
@onready var speaker_two_collect = text_collect_keys[1]

#endregion -- Dialogue Related

#region Container Array

@onready var labels_cont_array: Array = [
	right_text_container,
	left_text_container
]

#endregion -- Container Array

#region Base Vars

@onready var is_dialogue_start: bool = false
var has_started_dialogue := false
var is_video_ending: bool = false
#var is_busy: bool = false

#endregion -- Base Vars


#Input works, work on the lines 


func _ready() -> void:
	first_label_container.modulate.a = 0.0
	video_stream_player.modulate.a = 0.0
	
	
	fade_out_and_start()
	
	var speaker_keys = text_collection[speaker_one_collect]
	var speaker_inner_keys = speaker_keys.keys()
	var speaker_one_cur_keys = speaker_inner_keys[current_index]
	text_collection.erase(speaker_one_cur_keys)
	print(speaker_inner_keys)
	
	
	
	
func _process(delta: float) -> void:
	
	if video_stream_player.is_playing() and not is_video_ending:
		vid_end_time -= delta
		if vid_end_time <= 0.0:
			is_video_ending = true
			fade_in_and_end_vid()

	handle_dialogue_seq()

#region First Sequence

func fade_out_and_start() -> void:
	var tween = create_tween()
	tween.tween_property(first_label_container, "modulate:a", 1.0, 1.5)

	await  tween.finished
	
	fade_out_and_start_vid()

func fade_out_and_start_vid() -> void:
	var tween = create_tween()
	video_stream_player.play()
	
	tween.tween_property(video_stream_player, "modulate:a", 1.0, 2.0)

	await tween.finished
	
	pulse_control(prev_label)
	
	
func pulse_control(control: Control) -> void:
	var tween := create_tween()
	tween.set_loops()
	
	tween.tween_property(control, "modulate:a", 0.0, 1.0)
	tween.tween_property(control, "modulate:a", 1.0, 2.5)
	
	#tween.tween_property(control, "modulate", Color(1.35, 1.35, 1.35, 1.0), 0.45)
	#tween.tween_property(control, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.45)

func fade_in_and_end_vid() -> void:
	var tween = create_tween().set_parallel(true)
	
	tween.tween_property(first_label_container, "modulate:a", 0.0, 3.0)
	tween.tween_property(video_stream_player, "modulate:a", 0.0, 3.0)
	
	await tween.finished

	is_dialogue_start = true


#endregion -- First Sequence

#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("right"):
		#print("Press works?")
		#
func _unhandled_input(event: InputEvent) -> void:
	if !has_started_dialogue:
		return
	
	if event.is_action_pressed("next"):
		print("Am I pressing?")
		print("Right Visible: ", right_text_container.visible)
		print("Left Visible: ", left_text_container.visible)
		
		if right_text_container.visible == false:
			dialogue_seq_helper(speaker_one_collect, current_index, right_text_label, right_text_container)
		elif left_text_container.visible == false:
			dialogue_seq_helper(speaker_two_collect, current_index, left_text_label, left_text_container)
		
		current_index += 1 
		print("Current index: ", current_index)

func handle_dialogue_seq() -> void:
	if !is_dialogue_start:
		return
	
	if has_started_dialogue:
		return
	
	has_started_dialogue = true
	print("has started dialogue?: ", has_started_dialogue)
	
	first_label_container.visible = false
	video_stream_player.visible = false
	
	dialogue_seq_helper(speaker_one_collect, current_index, right_text_label, right_text_container)
	
	
func dialogue_seq_helper(sp_collect: Variant, _index: int, label: RichTextLabel, container: VBoxContainer) -> void:
	
	var speaker_keys = text_collection[sp_collect]
	var speaker_inner_keys = speaker_keys.keys()
	var speaker_one_cur_keys = speaker_inner_keys[current_index]

	for cont in labels_cont_array:
		cont.visible = false
		
	container.visible = true
	label.text = speaker_keys[speaker_one_cur_keys]
	#print("Inner keys before remove: ", speaker_inner_keys)
	#speaker_keys.erase(speaker_one_cur_keys)
	#print("Inner keys after remove: ", speaker_inner_keys)
