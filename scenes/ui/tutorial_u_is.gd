extends Control


#region References


#region Panels

@onready var attk_tutorial_panel: MarginContainer = $MainMargin/BasicAttackPanel
@onready var jump_block_panel: MarginContainer = $MainMargin/BlockJumpPanel
@onready var rage_panel: MarginContainer = $MainMargin/RagePanel
@onready var rage_skill_panel: MarginContainer = $MainMargin/RageSkillPanel

#endregion

#region Text Panels Labels

@onready var text_label_one: Label = $MainMargin/BasicAttackPanel/MainVBox/BG/TextVBContainer/Label1
@onready var text_label_two: Label = $MainMargin/BlockJumpPanel/MainVBox/BG/TextVBContainer/Label2
@onready var text_label_three: Label = $MainMargin/RagePanel/MainVBox/BG/TextVBContainer/Label3
@onready var text_label_four: Label = $MainMargin/RageSkillPanel/MainVBox/BG/TextVBContainer/Label4

#endregion

#region Arrow buttons

@onready var arrow_navs_panel: VBoxContainer = $MainMargin/ArrowNavsContainer
@onready var arrow_left: Button = $MainMargin/ArrowNavsContainer/HBoxContainer/VBoxContainer/ArrowLeftButton
@onready var arrow_right: Button = $MainMargin/ArrowNavsContainer/HBoxContainer/VBoxContainer2/ArrowRightButton

#endregion


#region Arrays 

@onready var panel_arrays: Array = [
	attk_tutorial_panel,
	jump_block_panel,
	rage_panel,
	rage_skill_panel
]

#endregion

#region Identifiers

@onready var current_index := 0
var is_attk_tutorial_panel := false
var is_jump_block_panel := false
var is_rage_panel := false
var is_rage_skill_panel := false


#endregion

#region Texts 

@onready var text_collect: Dictionary = {
	"attack_panel": {
		"attk_tut": "Press Left Mouse button to attack",
		"combo_tut": "Press Left Mouse repeatedly to start combo",
		"skill_one_tut": "Press 'E' key to launch skill one",
		"skill_two_tut": "Press 'T' key to launch skill two"
	},
	"block_jump_panel": {

		"jump_tut": "Press Space Bar to jump",
		"block_tut": "Press Right Mouse button to block",
	},
	
	"rage_panel": {
		"rage_tut": "Normal attacks and combo brings Aminya closer to true Spidor form. Rage changes main attack combos"
	},
	
	"rage_skill_panel": {

		"skill_one_rage_tut": "Press 'E' key to launch skill one during Rage mode",
		"skill_two_rage_tut": "Press 'T' key to launch skill two during Rage mode", 
	}
}

#endregion

#endregion 

func _ready() -> void:
	#arrow_navs_panel.visible = false
	#
	#for panel in panel_arrays:
		#panel.visible = false
	#open_attk_tutorial_panel()
	#open_jump_block_panel()
	#open_rage_panel()
	open_rage_skill_panel()

func _process(delta: float) -> void:
	pass


#region Open Panels 

func open_attk_tutorial_panel() -> void:
	is_attk_tutorial_panel = true
	
	panel_ini_helper(attk_tutorial_panel, arrow_navs_panel, 
					text_label_one, 0, current_index)
	
func open_jump_block_panel() -> void:
	is_jump_block_panel = true

	panel_ini_helper(jump_block_panel, arrow_navs_panel, 
				text_label_two, 1, current_index)

func open_rage_panel() -> void:
	is_rage_panel = true
	
	panel_ini_helper(rage_panel, arrow_navs_panel, 
				text_label_three, 2, current_index)

func open_rage_skill_panel() -> void:
	is_rage_skill_panel = true
	
	panel_ini_helper(rage_skill_panel, arrow_navs_panel, 
				text_label_four, 3, current_index)


func panel_ini_helper(panel: MarginContainer, arrow_panel: VBoxContainer, 
				label: Label, main_dict_item: int, index: int) -> void:

	panel.visible = true 
	arrow_panel.visible = true
	
	var dict_helper = text_collect.keys()
	var desired_key_item = dict_helper[main_dict_item]
	
	var current_panel_dict = text_collect[desired_key_item]
	var inner_keys = current_panel_dict.keys()
	var current_inner_key = inner_keys[index]
	
	label.text = current_panel_dict[current_inner_key]

#endregion

#region Button Navigations


func _on_arrow_left_button_pressed() -> void:
	pass # Replace with function body.


func _on_arrow_right_button_pressed() -> void:
	pass # Replace with function body.


#endregion

#region Exit Button

func _on_exit_button_pressed() -> void:
	pass # Replace with function body.
	
#endregion
