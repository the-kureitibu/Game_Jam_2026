extends Control

#region Base Vars

#region References 

@onready var bg_one: TextureRect = $BGOne
@onready var bg_two: TextureRect = $BGTwo
@onready var black_bg: ColorRect = $BlackBG


@onready var amiya_thumbnail_path: String = "res://assets/sprites/ui/thumbnails/Amiya_thumbnail.png"
@onready var bucko_thumbnail_path: String = "res://assets/sprites/ui/thumbnails/bucko_thumbnail.png"

@onready var amiya_image: TextureRect = $MainMargin/ImageVBox/HBoxContainer/AmiyaImage
@onready var bucko_image: TextureRect = $MainMargin/ImageVBox/HBoxContainer/BuckoImage

@onready var main_margin: MarginContainer = $MainMargin
@onready var panel_container: PanelContainer = $MainMargin/PanelContainer

@onready var player_name_container: VBoxContainer = $MainMargin/PanelContainer/MainHbox/PlayerNameContainer
@onready var player2_name_container: VBoxContainer = $MainMargin/PanelContainer/MainHbox/BuckoNameContainer
@onready var v_box_container: VBoxContainer = $MainMargin/PanelContainer/SecondHBox/VBoxContainer

@onready var player_name_label: RichTextLabel = $MainMargin/PanelContainer/MainHbox/PlayerNameContainer/PlayerNameLabel
@onready var bucko_name_label: RichTextLabel = $MainMargin/PanelContainer/MainHbox/BuckoNameContainer/BuckoNameLabel
@onready var dialogue_text_label: RichTextLabel = $MainMargin/PanelContainer/SecondHBox/VBoxContainer/DialogueTextLabel
@onready var next_text_label: RichTextLabel = $MainMargin/PanelContainer/NextTextContainer/NextTextLabel

@onready var button_margin_cont: MarginContainer = $ButtonMarginCont

const START_SCENE: String = "res://scenes/ui/start_screen.tscn"
#endregion -- References 

#region Base

var current_index: int = 0

const MAX_INDEX: int = 11

var has_ended_dialogue: bool = false 
var start_dialogue: bool = false

#endregion -- Base


#region Dialogue and Image Collection

var dialogue_lines: Array[Dictionary] = [
	{
		"speaker": "Amiya Aranha",
		"name": "Amiya Aranha",
		"text": [
			"We did it, Bucko. We saved them.",
			"Yeah…. Salaryman… what formidable foe.",
			"...",
			"...",
			"I’m hungy.",
			"* munch"
		],
		"side": "left",
		"image": amiya_thumbnail_path
	},
	{
		"speaker": "Bucko",
		"name": "Bucko",
		"text": [
			"All thanks to bro Michael. The guy with the weird clothes was strong.",
			"...",
			"...",
			"...",
			" /// /// "
			],
		"side": "left",
		"image": bucko_thumbnail_path
	}
]

@onready var dialogue_sequences: Array[Dictionary] = [
	{"speaker": 0, "line": 0}, 
	{"speaker": 1, "line": 0}, 
	{"speaker": 0, "line": 1}, 
	{"speaker": 1, "line": 1}, 
	{"speaker": 0, "line": 2},
	{"speaker": 1, "line": 2},
	{"speaker": 0, "line": 3},
	{"speaker": 0, "line": 4},
	{"speaker": 1, "line": 3},
	{"speaker": 0, "line": 5},
	{"speaker": 1, "line": 4},
]

@onready var names_and_text_collection: Array = [
	"Salaryman satou, four heavenly kings",
	"Amiya Aranha",
	"Bucko",
	"Click right arrow to next"
]

@onready var image_path_collection: Array = [
	amiya_thumbnail_path,
	bucko_thumbnail_path
]

#endregion -- Dialogue Collection

#endregion -- Base Vars


#region Processes
func _enter_tree() -> void:
	GameManager.game_scene_state = GameManager.GameLevelStates.EPILOGUE

func _ready() -> void:

	dialogue_helper(0, "left", 0)
	
	current_index += 1 
	next_text_label.text = names_and_text_collection[3]
	pulse_control(next_text_label)

#endregion -- Processes


#region Advancing Dialogue


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("next"):
		advance_dialogue()

func sequences_helper(curr_index: int, speaker: String = "speaker", line: String = "line", arr: Array = dialogue_sequences) -> Array:
	var speaker_index = arr[curr_index][speaker] 
	var line_index = arr[curr_index][line] 
	
	return [speaker_index, line_index]

func advance_dialogue() -> void:

	if has_ended_dialogue:
		return

	if current_index == MAX_INDEX:
		has_ended_dialogue = true

		panel_container.visible = false
		amiya_image.visible = false
		bucko_image.visible = false
		
		show_end_buttons()
		return
	
	var sequence_index = sequences_helper(current_index)
	var sequence_speaker_index = sequence_index[0]
	var sequence_line_index = sequence_index[1]
	
	var side: String = ""
	
	match sequence_speaker_index:
		0:
			side = "left"
		1:
			side = "right"
	
	dialogue_helper(sequence_speaker_index, side, sequence_line_index)
	
	current_index += 1


func dialogue_helper(main_index: int, side: String, cur_index: int, sp_text_indx: String = "text", sp_name: String = "speaker") -> void:
	
	var main_collection = dialogue_lines[main_index]
	var speaker_text_collection = main_collection[sp_text_indx]
	
	var speaker_name = main_collection[sp_name]

	match speaker_name:
		"Amiya Aranha":
			player_name_label.text = "Amiya Aranha"
			amiya_image.texture = load(amiya_thumbnail_path)
			if cur_index == 4:
				black_bg.visible = true
		"Bucko":
			player_name_label.text = "Bucko"
			bucko_image.texture = load(bucko_thumbnail_path)
			if cur_index == 4:
				show_bg_two()
	
	match side:
		"left":
			dialogue_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		"right":
			dialogue_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	
	
	dialogue_text_label.text = speaker_text_collection[cur_index]
	
#endregion -- Advancing Dialogue

#region Backgrounds

func show_bg_two() -> void:
	bg_one.visible = false

	var tween = create_tween()
	tween.tween_property(black_bg, "modulate:a", 0.0, 1.5)
	
	bg_two.visible = true
	
	await tween.finished
	
	black_bg.visible = false
	
	
#endregion -- Backgrounds


#region End Buttons

func show_end_buttons() -> void:
	button_margin_cont.visible = true

#endregion -- End Buttons

#region Effects 

func pulse_control(control: Control) -> void:
	var tween := create_tween()
	tween.set_loops()
	
	tween.tween_property(control, "modulate:a", 0.0, 1.0)
	tween.tween_property(control, "modulate:a", 1.0, 2.5)

#endregion --  Effects 

#region Buttons

func _on_back_to_start_pressed() -> void:
	
	SignalHub.restart_game.emit()
	GameManager.change_scene_with_transition(START_SCENE)
	

func _on_exit_button_pressed() -> void:
	get_tree().quit()

#endregion -- Buttons
