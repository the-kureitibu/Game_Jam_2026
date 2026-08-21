extends Control

#region Base Vars

#region References 

@onready var amiya_thumbnail_path: String = "res://.godot/imported/Amiya_thumbnail.png"
@onready var bucko_thumbnail_path: String = "res://.godot/imported/bucko_thumbnail.png"
@onready var boss_thumbnail_path: String = "res://.godot/imported/boss_thumbnail.png"

@onready var amiya_bucko_image: TextureRect = $MainMargin/ImageVBox/HBoxContainer/AmiyaBuckoImage
@onready var boss_image: TextureRect = $MainMargin/ImageVBox/HBoxContainer/BossImage


@onready var main_margin: MarginContainer = $MainMargin
@onready var panel_container: PanelContainer = $MainMargin/PanelContainer

@onready var player_name_container: VBoxContainer = $MainMargin/PanelContainer/PlayerNameContainer
@onready var boss_name_container: VBoxContainer = $MainMargin/PanelContainer/BossNameContainer
@onready var v_box_container: VBoxContainer = $MainMargin/PanelContainer/VBoxContainer

@onready var player_name_label: RichTextLabel = $MainMargin/PanelContainer/PlayerNameContainer/PlayerNameLabel
@onready var boss_name_label: RichTextLabel = $MainMargin/PanelContainer/BossNameContainer/BossNameLabel
@onready var dialogue_text_label: RichTextLabel = $MainMargin/PanelContainer/VBoxContainer/DialogueTextLabel
@onready var next_text_label: RichTextLabel = $MainMargin/PanelContainer/VBoxContainer/NextTextContainer/NextTextLabel

#endregion -- References 

#region Base

var current_index: int = 0
var current_speaker: int = 0

const MAX_SPEAKER: int = 3
const MAX_INDEX: int = 3

#endregion -- Base

#region Dialogue and Image Collection

var dialogue_lines: Array[Dictionary] = [
	{
		"speaker": "Amiya Aranha",
		"name": "Amiya Aranha",
		"text": [
			"Wait, Bucko.",
			"Salaryman Satou of the Four Heavenly Kings... despite wearing weird clothes, it is said that his power rivals the demon lord. Take caution, Bucko.",
			"(pfft)"
		],
		"side": "left",
		"image": amiya_thumbnail_path
	},
	{
		"speaker": "Boss",
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
		"text": "You dress weird.",
		"side": "left",
		"image": bucko_thumbnail_path
	}
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

#region Speaker Text Collections

#@onready var text_collect_keys = dialogue_lines.keys()
#@onready var speaker_one_collect = text_collect_keys[0]
#@onready var speaker_two_collect = text_collect_keys[1]
#@onready var speaker_three_collect = text_collect_keys[2]

#endregion -- Speaker Text Collections 

#endregion -- Base Vars

#region Processes

func _ready() -> void:
	#set_initial_labels(speaker_one_collect, 0)
	
	#var speaker_keys = text_collect_keys[speaker_one_collect]

	dialogue_helper(0, "left", current_index)
	#
	#next_text_label.text = names_and_text_collection[3]
	#pulse_control(next_text_label)


func _process(delta: float) -> void:
	pass
	
#endregion -- Processes

#region Advancing Dialogue

func dialogue_helper(main_index: int, side: String, cur_index: int, sp_text_indx: String = "text", sp_name: String = "speaker") -> void:
		
	var main_collection = dialogue_lines[main_index]
	var speaker_text_collection = main_collection[sp_text_indx]
	
	var speaker_name = main_collection[sp_name]
	print(speaker_name)

	match speaker_name:
		"Amiya Aranha":
			player_name_label.text = "Amiya Aranha"
			amiya_bucko_image.texture = load(amiya_thumbnail_path)
		"Boss":
			boss_name_label.text = "Boss"
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
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("right"):
		pass

func advance_dialogue() -> void:
	pass


#endregion -- Advancing Dialogue

#region Effects 

func pulse_control(control: Control) -> void:
	var tween := create_tween()
	tween.set_loops()
	
	tween.tween_property(control, "modulate:a", 0.0, 1.0)
	tween.tween_property(control, "modulate:a", 1.0, 2.5)

#endregion --  Effects 
