extends Control


#region References


#region Panels

@onready var attk_tutorial_panel: MarginContainer = $MainMargin/BasicAttackPanel
@onready var jump_block_panel: MarginContainer = $MainMargin/BlockJumpPanel
@onready var rage_panel: MarginContainer = $MainMargin/RagePanel
@onready var rage_skill_panel: MarginContainer = $MainMargin/RageSkillPanel

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
		"rage_tut": "Normal attacks and combo accumulates rage. 
					Rage changes main attack"
	},
	
	"rage_skill_panel": {

		"skill_one_rage_tut": "Press 'E' key to launch skill one during Rage mode",
		"skill_two_rage_tut": "Press 'T' key to launch skill two during Rage mode", 
	}
}


#endregion


#endregion 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
