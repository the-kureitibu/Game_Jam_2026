extends Control

#region Base Vars

var p_stats: PlayerStats
var p_move_state: String
var p_action_state: String
var p_heath: int 
var p_damage: int
var r_amount: int
var r_duration: float
var r_cooling: float
var r_per_attk: int

#endregion

#region HUD Labels

@export var health_label: Label
@export var action_state_label: Label
@export var movement_state_label: Label
@export var attack_label: Label
@export var rage_label: Label
@export var rage_duration_label: Label
@export var rage_cd_label: Label

#endregion

func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func dec_ini_p_stats(a_state: String, m_state: String) -> void:
		p_move_state = m_state
		p_action_state = a_state
		p_heath = p_stats.player_health
		p_damage = p_stats.player_damage
		r_amount = p_stats.rage_amount
		r_duration = p_stats.rage_timer
		r_cooling = p_stats.rage_cd_timer
		r_per_attk = p_stats.rage_per_attack

func update_ini_hud_labels() -> void:
	pass
