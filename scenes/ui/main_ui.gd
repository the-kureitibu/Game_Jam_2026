extends Control


#region Base Vars

var p_health: float 
var p_damage: int
var p_rage_amount: float
var rage_per_attk: int

#endregion

#region References

@export var p_stats: PlayerStats


#endregion

#region HUD Labels

@onready var health_bar: TextureProgressBar = $MainMargin/BaseVBox/HealthBar
@onready var rage_bar: TextureProgressBar = $MainMargin/BaseVBox/RageBar

#endregion

#region References

@onready var player = get_tree().get_first_node_in_group("Player_target")

#endregion


func _ready() -> void:
	
	update_ini_min_max()
	dec_ini_p_stats()
	con_to_signals()
	


func con_to_signals() -> void: 
	if player == null:
		push_error("Player is null")
		return
	
	player.stat_changed.connect(update_p_stats)


func update_p_stats(s_name: String, s_value: Variant) -> void:
	if player == null:
		push_error("Player does not Exist")
		return
	
	match s_name:
		"p_health":
			print("health in UI working?")
			health_bar.value = s_value
		"r_amount":
			rage_bar.value = s_value
			print("rage in UI working?")

func dec_ini_p_stats() -> void:

	if player == null:
		push_error("Player is null")
		return

	p_health = player.p_health
	p_rage_amount = player.r_amount
	
	health_bar.value = p_health
	print(health_bar.value)
	rage_bar.value = p_rage_amount
	print(rage_bar.value)
	

func update_ini_min_max() -> void:

	health_bar.min_value = 0.0
	health_bar.max_value = p_stats.player_health
	
	rage_bar.min_value = 0.0
	rage_bar.max_value = p_stats.rage_amount
