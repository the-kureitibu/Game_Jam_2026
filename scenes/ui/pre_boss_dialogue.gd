extends Control

#region Base Vars

#region References 

@onready var amiya_thumbnail_path: String = "res://.godot/imported/Amiya_thumbnail.png-834829f972c9de96a3dafc59ae82382c.ctex"
@onready var bucko_thumbnail_path: String = "res://.godot/imported/bucko_thumbnail.png-5ed1b9fb6710ac235db47d0570e2fcb5.ctex"
@onready var boss_thumbnail_path: String = "res://.godot/imported/boss_thumbnail.png-93fa4ed20e720671d14ced4192a2be80.ctex"

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

@onready var prelogue_text_collect: Dictionary = {
	"Amiya": {
		"seq_0": "Wait, Bucko.",
		"seq_1": "Salaryman Satou of the four heavenly kings… despite wearing weird clothes, it is said that his power rivals the demon lord. Take caution, Bucko.",
		"seq_2": "....",
		"seq_3": "(pfft)"
	},
	"Bucko": {
		"seq_1": "You dress weird."
	},
	"Boss": {
		"seq_1": "Oho…? Cleric Aminya Aranha… or should I say the hero party's saint. Rumor has it that you're a powerful healer.",
		"seq_2": "Why don't you join us; and together, we will -",
		"seq_3": "Nevermind. I Satou, shall bring you demise."
	}
}

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

@onready var text_collect_keys = prelogue_text_collect.keys()
@onready var speaker_one_collect = text_collect_keys[0]
@onready var speaker_two_collect = text_collect_keys[1]
@onready var speaker_three_collect = text_collect_keys[2]

#endregion -- Speaker Text Collections 

#endregion -- Base Vars

#region Processes

func _ready() -> void:
	#set_initial_labels(speaker_one_collect, 0)
	
	#var speaker_keys = text_collect_keys[speaker_one_collect]
	print(text_collect_keys[0])
		
	#pulse_control(next_text_label)


func _process(delta: float) -> void:
	pass
	
#endregion -- Processes

#region Advancing Dialogue

func set_initial_labels(sp_collect: Variant, _index: int) -> void:
	var speaker_keys = text_collect_keys[sp_collect]
	var speaker_inner_keys = speaker_keys.keys()
	var speaker_one_cur_keys = speaker_inner_keys[_index]
	
	next_text_label.text = names_and_text_collection[3]
	player_name_label.text = names_and_text_collection[1]
	amiya_bucko_image.texture = load(amiya_thumbnail_path)
	#boss_name_label.text = names_and_text_collection[0]
	dialogue_text_label.text = speaker_keys[speaker_one_cur_keys]
	


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
