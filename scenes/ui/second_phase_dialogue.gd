extends Control

#region Base Vars

#region References 

@onready var amiya_thumbnail_path: String = "res://assets/sprites/ui/thumbnails/Amiya_thumbnail.png"
@onready var bucko_thumbnail_path: String = "res://assets/sprites/ui/thumbnails/bucko_thumbnail.png"
@onready var boss_thumbnail1_path: String = "res://assets/sprites/ui/thumbnails/boss_thumbnail.png"
@onready var boss_thumbnail2_path: String = "res://assets/sprites/ui/thumbnails/boss_thumbnailv1.png"
@onready var boss_thumbnail3_path: String = "res://assets/sprites/ui/thumbnails/boss_thumbnailv3.png"
@onready var boss_thumbnail4_path: String = "res://assets/sprites/ui/thumbnails/boss_thumbnailv4.png"
@onready var boss_thumbnail4v1_path: String = "res://assets/sprites/ui/thumbnails/boss_thumbnailv4v2.png"



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

#region Boss Animation

@onready var boss_anim_player: AnimatedSprite2D
@onready var boss_main_collision: CollisionShape2D
@onready var boss_main_hurt_box: CollisionShape2D
@onready var boss_target = get_tree().get_first_node_in_group("Boss_target")

#endregion -- Boss Animation

#endregion -- References 

#region Base

var current_index: int = 0

const MAX_INDEX: int = 10

var has_ended_dialogue: bool = false 
var start_dialogue: bool = false

#endregion -- Base

#region Gate Keepers

@onready var is_demon_lord: bool = false
@onready var is_transition: bool = false
@onready var transforming_done: bool = false

#endregion -- Gate Keepers

#region Dialogue and Image Collection

var dialogue_lines: Array[Dictionary] = [
	{
		"speaker": "Amiya Aranha",
		"name": "Amiya Aranha",
		"text": [
			"Huff, Huff",
			"!!!",
			"Demon Lord!",
			"No wonder those id**ts!!",
			"Brace yourself Bucko!"
		],
		"side": "left",
		"image": amiya_thumbnail_path
	},
	{
		"speaker": "Salaryman Satou, Four Heavenly Kings",
		"name": "Salaryman Satou, four heavenly kings",
		"text": [
			"Oh no. Don't kill me yet.",
			"Haha... そう Spidor. そう!!!",
			"That's right.",
			"No matter. I'll start with you and take care of the rats after."
		],
		"side": "right",
		"image": boss_thumbnail1_path
	},
	{
		"speaker": "Bucko",
		"name": "Bucko",
		"text": [
			"Did we get him?"
			],
		"side": "left",
		"image": bucko_thumbnail_path
	}
]

@onready var dialogue_sequences: Array[Dictionary] = [
	{"speaker": 0, "line": 0}, 
	{"speaker": 2, "line": 0}, 
	{"speaker": 1, "line": 0}, 
	{"speaker": 0, "line": 1}, 
	{"speaker": 0, "line": 2},
	{"speaker": 1, "line": 1},
	{"speaker": 0, "line": 3},
	{"speaker": 1, "line": 2},
	{"speaker": 1, "line": 3},
	{"speaker": 0, "line": 4},
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
	if !boss_target:
		boss_target = get_tree().get_first_node_in_group("Boss_target")
	
	boss_anim_player = boss_target.d_sprite
	boss_main_collision = boss_target.main_col
	boss_main_hurt_box = boss_target.hurt_col
	
	if !SignalHub.ready_for_second_phase.is_connected(update_boss_form):
		SignalHub.ready_for_second_phase.connect(update_boss_form)


func _ready() -> void:

	dialogue_helper(0, "left", 0)
	
	current_index += 1 
	next_text_label.text = names_and_text_collection[3]
	pulse_control(next_text_label)


func _process(delta: float) -> void:
	pass
	
#endregion -- Processes

#region Dialogue State related

func update_boss_form() -> void:
	is_demon_lord = true

#endregion -- Dialogue State related


#region Advancing Dialogue


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("next"):
		advance_dialogue()

func sequences_helper(curr_index: int, speaker: String = "speaker", line: String = "line", arr: Array = dialogue_sequences) -> Array:
	var speaker_index = arr[curr_index][speaker] 
	var line_index = arr[curr_index][line] 
	
	return [speaker_index, line_index]

func advance_dialogue() -> void:
	if current_index == 3 and !transforming_done:
		transition_to_demon_lord()
	
	if is_transition:
		return
	
	if has_ended_dialogue:
		return


	if current_index == MAX_INDEX:
		has_ended_dialogue = true
		SignalHub.mid_fight_dialogue_done.emit()
		
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


func dialogue_helper(main_index: int, side: String, cur_index: int, sp_text_indx: String = "text", sp_name: String = "speaker") -> void:
		
	var main_collection = dialogue_lines[main_index]
	var speaker_text_collection = main_collection[sp_text_indx]
	
	var speaker_name = main_collection[sp_name]

	match speaker_name:
		"Amiya Aranha":
			player_name_label.text = "Amiya Aranha"
			amiya_bucko_image.texture = load(amiya_thumbnail_path)
		"Salaryman Satou, Four Heavenly Kings":
			if cur_index == 0:
				boss_name_label.text = "Salaryman Satou, Four Heavenly Kings"
				boss_image.texture = load(boss_thumbnail1_path)
			elif cur_index == 1:
				boss_name_label.text = "Salaryman Satou, Demon Lord"
				boss_image.texture = load(boss_thumbnail4_path)
			elif cur_index == 2:
				boss_name_label.text = "Salaryman Satou, Demon Lord"
				boss_image.texture = load(boss_thumbnail4v1_path)
			else:
				boss_name_label.text = "Salaryman Satou, Demon Lord"
				boss_image.texture = load(boss_thumbnail4_path)
		"Bucko":
			player_name_label.text = "Bucko"
			amiya_bucko_image.texture = load(bucko_thumbnail_path)
	
	match side:
		"left":
			dialogue_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		"right":
			dialogue_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	
	
	dialogue_text_label.text = speaker_text_collection[cur_index]
	
func transition_to_demon_lord() -> void:
	if is_transition:
		return
	
	is_transition = true
	boss_anim_player.visible = true 

	handle_first_transform()
	
	SignalHub.is_needed_flip.emit()


func pass_boss_col_shape_values(radius: float, height: float, pos: Vector2, col_shape: CollisionShape2D):

	col_shape.shape.radius = radius
	col_shape.shape.height = height
	col_shape.position = pos 
	
func set_final_thumbnail() -> void:
	boss_name_label.text = "Salaryman Satou, Demon Lord"
	boss_image.texture = load(boss_thumbnail4v1_path)
	
	is_transition = false
	transforming_done = true

#region Transitions Animations Related

func handle_first_transform() -> void:
	boss_anim_player.play("to_demon_one")
	await boss_anim_player.animation_finished
	
	handle_shape_and_offset()
	
	handle_last_transform()
	
	
func handle_last_transform() -> void:
	boss_anim_player.play("to_demon_two")
	
	await boss_anim_player.animation_finished
	
	set_final_thumbnail()
	
func handle_shape_and_offset() -> void:
	
	boss_anim_player.offset = Vector2(0, -100.0)
	
	pass_boss_col_shape_values(19, 160, Vector2(0, -102.0), boss_main_collision)
	pass_boss_col_shape_values(19, 160, Vector2(0, -102.0), boss_main_hurt_box)


#endregion -- Transitions Animation

#endregion -- Advancing Dialogue

#region Effects 

func pulse_control(control: Control) -> void:
	var tween := create_tween()
	tween.set_loops()
	
	tween.tween_property(control, "modulate:a", 0.0, 1.0)
	tween.tween_property(control, "modulate:a", 1.0, 2.5)

#endregion --  Effects 
