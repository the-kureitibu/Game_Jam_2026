extends Control

#region Base Vars

@export var p_stats: PlayerStats
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

#region On Ready's
#signal stat_changed(s_name: String, s_value: int)
#signal r_timer_changed(r_name: String, r_value: float)
#signal a_m_state_changed(st_value: int)
@onready var player = get_tree().get_first_node_in_group("Player_target")
#endregion


func _ready() -> void:
	con_to_signals()
	dec_ini_p_stats()
	update_ini_hud_labels()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func con_to_signals() -> void: 
	if player == null:
		push_error("Player is null")
		return
	
	player.tmp_send_ini_state.connect(dec_ini_p_action)

func dec_ini_p_action(st_name: String, st_value: int) -> void:
	var p_m_state = PlayerBase.PlayerMoveState
	var p_a_state = PlayerBase.PlayerActionState

	match st_name:
		"p_move_state":
			p_m_state = PlayerBase.PlayerMoveState.keys()[st_value]
			movement_state_label.text = "%s, %s" % [st_name, p_m_state]
		"p_action_state":
			p_a_state = PlayerBase.PlayerActionState.keys()[st_value]
			action_state_label.text = "%s, %s" % [st_name, p_a_state]
		_:
			pass



func dec_ini_p_stats() -> void:
		#p_move_state = m_state
		#p_action_state = a_state
		p_heath = p_stats.player_health
		p_damage = p_stats.player_damage
		r_amount = p_stats.rage_amount
		r_duration = p_stats.rage_timer
		r_cooling = p_stats.rage_cd_timer
		r_per_attk = p_stats.rage_per_attack
		


func update_ini_hud_labels() -> void:
	
	health_label.text = "Health: " + str(p_heath)
	#action_state_label: Label
	#movement_state_label: Label
	attack_label.text = "Attack: " + str(p_damage)
	rage_label.text = "Rage Bar: " + str(r_amount)
	rage_duration_label.text = "Rage Duration: " + str(r_duration)
	rage_cd_label.text = "Rage cooling down: " +str(r_cooling)
