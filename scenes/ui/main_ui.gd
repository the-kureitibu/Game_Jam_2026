extends Control


#region Base Vars

var player_heath: int 
var player_damage: int
var rage_amount: int
var rage_per_attk: int

#endregion

#region HUD Labels

@onready var health_bar: TextureProgressBar = $MainMargin/BaseVBox/HealthBar
@onready var rage_bar: TextureProgressBar = $MainMargin/BaseVBox/RageBar

#endregion

#region References

@onready var player = get_tree().get_first_node_in_group("Player_target")

#endregion


func _ready() -> void:
	con_to_signals()
	dec_ini_p_stats()
	update_ini_hud_labels()


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
			health_bar.min_value = s_value
		"r_amount":
			rage_bar.min_value = s_value

func dec_ini_p_stats() -> void:
	if player == null:
		push_error("Player does not Exist")
		return
			
	player_heath = player.p_health
	rage_amount = player.r_amount
	rage_per_attk = player.r_per_attk

func update_ini_hud_labels() -> void:

	health_bar.max_value = player_heath
	rage_bar.max_value = rage_amount
