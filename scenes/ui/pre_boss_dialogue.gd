extends Control

#region Base Vars

#region References 

@onready var amiya_thumbnail_path: String = "res://assets/sprites/ui/thumbnails/Amiya_thumbnail.png"
@onready var bucko_thumbnail_path: String = "res://assets/sprites/ui/thumbnails/bucko_thumbnail.png"
@onready var boss_thumbnail_path: String = "res://assets/sprites/ui/thumbnails/boss_thumbnail.png"
@onready var boss_thumbnail_path2: String = "res://assets/sprites/ui/thumbnails/boss_thumbnailv1.png"


@onready var amiya_bucko_image: TextureRect = $MainMargin/ImageVBox/HBoxContainer/AmiyaBuckoImage
@onready var boss_image: TextureRect = $MainMargin/ImageVBox/HBoxContainer/BossImage


@onready var main_margin: MarginContainer = $MainMargin
@onready var panel_container: PanelContainer = $MainMargin/PanelContainer

@onready var player_name_container: VBoxContainer = $MainMargin/PanelContainer/MainHbox/PlayerNameContainer
@onready var boss_name_container: VBoxContainer = $MainMargin/PanelContainer/MainHbox/BossNameContainer
@onready var v_box_container: VBoxContainer = $MainMargin/PanelContainer/SecondHBox/VBoxContainer

@onready var player_name_label: RichTextLabel = $MainMargin/PanelContainer/MainHbox/PlayerNameContainer/PlayerNameLabel
@onready var boss_name_label: RichTextLabel = $MainMargin/PanelContainer/MainHbox/BossNameContainer/BossNameLabel
@onready var dialogue_text_label: RichTextLabel = $MainMargin/PanelContainer/SecondHBox/VBoxContainer/DialogueTextLabel
@onready var next_text_label: RichTextLabel = $MainMargin/PanelContainer/NextTextContainer/NextTextLabel

#region BGM 

@onready var dova_bgm: String = "res://assets/audio/bgm/dova_Die Letzte Revolution_master.mp3"

#endregion -- BGM 

#region SFX 
@onready var typing_sfx: String = "res://assets/audio/sfx/typewriter3.wav"

#endregion -- SFX 

#endregion -- References 

#region Base

var current_index: int = 0

const MAX_INDEX: int = 9

var has_ended_dialogue: bool = false 
var start_dialogue: bool = false

#endregion -- Base

#region Dialogue and Image Collection

var dialogue_lines: Array[Dictionary] = [
	{
		"speaker": "Amiya Aranha",
		"name": "Amiya Aranha",
		"text": [
			"Wait, Bucko.",
			"Salaryman Satou of the Four Heavenly Kings... despite wearing weird clothes, it is said that his power rivals the demon lord. Take caution, Bucko.",
			"....",
			"(pfft)"
		],
		"side": "left",
		"image": amiya_thumbnail_path
	},
	{
		"speaker": "Salaryman Satou, Four Heavenly Kings",
		"name": "Salaryman Satou, four heavenly kings",
		"text": [
			"Oho…? Cleric Aminya Aranha… or should I say the hero party's saint.",
			"Why don't you join us; and together, we will - ",
			"....",
			"Nevermind. I Satou shall bring you demise."
		],
		"side": "right",
		"image": boss_thumbnail_path
	},
	{
		"speaker": "Bucko",
		"name": "Bucko",
		"text": [
			"You dress weird."
			],
		"side": "left",
		"image": bucko_thumbnail_path
	}
]

@onready var dialogue_sequences: Array[Dictionary] = [
	{"speaker": 0, "line": 0}, 
	{"speaker": 0, "line": 1}, 
	{"speaker": 1, "line": 0}, 
	{"speaker": 0, "line": 2}, 
	{"speaker": 1, "line": 1},
	{"speaker": 2, "line": 0},
	{"speaker": 0, "line": 3},
	{"speaker": 1, "line": 2},
	{"speaker": 1, "line": 3}
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

func _ready() -> void:

	dialogue_helper(0, "left", 0)
	
	current_index += 1 
	next_text_label.text = names_and_text_collection[3]
	pulse_control(next_text_label)


func _process(delta: float) -> void:
	pass
	
#endregion -- Processes

#region Advancing Dialogue

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("next"):
		AudioManager.play_music(typing_sfx, "oneshot", -6.0)

		advance_dialogue()

func sequences_helper(curr_index: int, speaker: String = "speaker", line: String = "line", arr: Array = dialogue_sequences) -> Array:
	var speaker_index = arr[curr_index][speaker] 
	var line_index = arr[curr_index][line] 
	
	return [speaker_index, line_index]

func advance_dialogue() -> void:
	if current_index == 8:
		AudioManager.fade_to_bgm(dova_bgm, "bgm", -10.0)

	
	if has_ended_dialogue:
		return

	if current_index == MAX_INDEX:
		has_ended_dialogue = true
		SignalHub.pre_fight_dialogue_done.emit()
		
		queue_free()
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
		2:
			side = "left"
	
	dialogue_helper(sequence_speaker_index, side, sequence_line_index)
	
	current_index += 1
	
	if current_index == 9:
		boss_image.texture = load(boss_thumbnail_path)
	else:
		boss_image.texture = load(boss_thumbnail_path2)


func dialogue_helper(main_index: int, side: String, cur_index: int, sp_text_indx: String = "text", sp_name: String = "speaker") -> void:
		
	var main_collection = dialogue_lines[main_index]
	var speaker_text_collection = main_collection[sp_text_indx]
	
	var speaker_name = main_collection[sp_name]

	match speaker_name:
		"Amiya Aranha":
			player_name_label.text = "Amiya Aranha"
			amiya_bucko_image.texture = load(amiya_thumbnail_path)
		"Salaryman Satou, Four Heavenly Kings":
			boss_name_label.text = "Salaryman Satou, Four Heavenly Kings"
			boss_image.texture = load(boss_thumbnail_path)
		"Bucko":
			player_name_label.text = "Bucko"
			amiya_bucko_image.texture = load(bucko_thumbnail_path)
	
	match side:
		"left":
			dialogue_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		"right":
			dialogue_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	
	
	
	dialogue_text_label.text = speaker_text_collection[cur_index]

#endregion -- Advancing Dialogue

#region Effects 

func pulse_control(control: Control) -> void:
	var tween := create_tween()
	tween.set_loops()
	
	tween.tween_property(control, "modulate:a", 0.0, 1.0)
	tween.tween_property(control, "modulate:a", 1.0, 2.5)

#endregion --  Effects 
