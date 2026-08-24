extends Control

#region Base Vars

var mob_health: float = 0.0
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar
@export var boss_node: Node2D
@onready var is_done_second_phase_update: bool = false

#endregion

#region Signals

#endregion

#region Processes

func _ready() -> void:
	con_to_signals()
	
	if boss_node:
		declare_initial_stats(boss_node.boss_health)
		
		boss_node.update_health.connect(update_boss_health)

func _process(delta: float) -> void:
	handle_second_phase_boss_health()

#endregion

func con_to_signals() -> void: 
	
	if owner.is_in_group("Mob"):
		owner.update_health.connect(update_mob_health)
	else:
		return

func handle_second_phase_boss_health() -> void:
	if !GameManager.can_start_second_phase:
		return
		
	if is_done_second_phase_update:
		return
	
	update_boss_second_phase_health()
	

func update_boss_second_phase_health() -> void:
	is_done_second_phase_update = true
	
	declare_initial_stats(boss_node.p2_boss_health)
	update_boss_health(boss_node.p2_boss_health)
	
	

func update_mob_health(value: float) -> void:
	
	texture_progress_bar.value = value

func update_boss_health(value: float) -> void:
	
	texture_progress_bar.value = value


func declare_initial_stats(health: float) -> void:

	mob_health = health
	texture_progress_bar.min_value = 0.0
	texture_progress_bar.max_value = health
	
	texture_progress_bar.value = health
	
