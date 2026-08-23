extends Control

#region Base Vars

var mob_health: float = 0.0
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar
@export var boss_node: Node2D

#endregion

#region Signals

#endregion

#region Processes

func _ready() -> void:
	con_to_signals()
	
	if boss_node:
		if GameManager.can_start_second_phase:
			declare_initial_stats(boss_node.p2_boss_health)
		else:
			declare_initial_stats(boss_node.boss_health)
		
		boss_node.update_health.connect(update_boss_health)

func _process(delta: float) -> void:
	pass

#endregion

func con_to_signals() -> void: 
	
	if owner.is_in_group("Mob"):
		owner.update_health.connect(update_mob_health)
	else:
		return


func update_mob_health(value: float) -> void:
	
	texture_progress_bar.value = value

func update_boss_health(value: float) -> void:
	
	texture_progress_bar.value = value


func declare_initial_stats(health: float) -> void:

	mob_health = health
	texture_progress_bar.min_value = 0.0
	texture_progress_bar.max_value = health
	
	texture_progress_bar.value = health
	
