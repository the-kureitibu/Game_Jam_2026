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

#region Texts 

@onready var text_collect: Dictionary = {
	"attack_panel": {
		"attk_tut": "Press Left Mouse button to attack",
		"combo_tut": "Press Left Mouse repeatedly to start combo",
		"skill_one_tut": "Press 'E' key to launch skill one",
		"skill_two_tut": "Press 'T' key to launch skill two"
	},
	"block_jump_panel": {

		"jump_tut": "Press SpaceBar to jump",
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
	for panel in panel_arrays:
		panel.visible = false


func _process(delta: float) -> void:
	pass


#region Open Panels 

func open_attk_tutorial_panel() -> void:
	pass
	
func open_jump_block_panel() -> void:
	pass

func open_rage_panel() -> void:
	pass

func open_rage_skill_panel() -> void:
	pass

#endregion
