extends Control
#Get from Player instead 
#region Base Vars

@export var p_stats: PlayerStats
var player_move_state: String
var player_action_state: String
var player_heath: int 
var player_damage: int
var rage_amount: int
var rage_duration: float
var rage_cooling: float
var rage_per_attk: int

#endregion

#region HUD Labels

@export var health_label: Label
@export var action_state_label: Label
@export var movement_state_label: Label
@export var p_form_state: Label
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
	
	player.tmp_send_ini_state.connect(update_p_action)
	player.stat_changed.connect(update_p_stats)
	player.r_timer_changed.connect(update_p_rage)
	


func update_p_action(st_name: String, st_value: int) -> void:
	var p_m_state = PlayerBase.PlayerMoveState
	var p_a_state = PlayerBase.PlayerActionState
	var p_f_state = PlayerBase.PlayerFormState

	match st_name:
		"p_move_state":
			p_m_state = PlayerBase.PlayerMoveState.keys()[st_value]
			movement_state_label.text = "%s, %s" % [st_name, p_m_state]
		"p_action_state":
			p_a_state = PlayerBase.PlayerActionState.keys()[st_value]
			action_state_label.text = "%s, %s" % [st_name, p_a_state]
		"p_form":
			p_f_state = PlayerBase.PlayerFormState.keys()[st_value]
			p_form_state.text = "%s, %s" % [st_name, p_f_state]
		_:
			pass

func update_p_stats(s_name: String, s_value: int) -> void:
	if player == null:
		push_error("Player does not Exist")
		return
	
	match s_name:
		"p_health":
			health_label.text = "%s, %s" % ["Health: ", s_value]
		"p_damage":
			attack_label.text = "%s, %s" % ["Attack: ", s_value]
		"r_amount":
			rage_label.text = "%s, %s" % ["Rage Bar: ", s_value]


func update_p_rage(r_name: String, r_value: float) -> void:
	if player == null:
		push_error("Player does not Exist")
		return
	
	match r_name:
		"rage_dur": 
			rage_duration_label.text = "%s, %s" % ["Rage Duration: ", r_value]

	

func dec_ini_p_stats() -> void:
		if player == null:
			push_error("Player does not Exist")
			return
			
		var temp_form = PlayerBase.PlayerFormState.keys()[player.p_form_state]
		p_form_state.text = "%s, %s" % ["Form State: ", temp_form]
			
		#change this to get player's value, not the resource
		player_heath = player.p_health
		player_damage = player.p_damage
		rage_amount = player.r_amount
		rage_duration = player.r_timer
		rage_cooling = player.r_cd_timer
		rage_per_attk = player.r_per_attk

	

func update_ini_hud_labels() -> void:
	
	health_label.text = "Health: " + str(player_heath)
	attack_label.text = "Attack: " + str(player_damage)
	rage_label.text = "Rage Bar: " + str(rage_amount)
	rage_duration_label.text = "Rage Duration: " + str(rage_duration)
	rage_cd_label.text = "Rage cooling down: " +str(rage_cooling)
