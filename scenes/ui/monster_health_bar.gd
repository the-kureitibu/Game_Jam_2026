extends Control

#region Base Vars

var mob_health: float = 0.0
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar


#endregion

#region Signals

#endregion

func con_to_signals() -> void: 
	#var parent = get_tree().current_scene.name
	#
	if owner:
		match owner.name:
			"MobOne":
				owner.update_health.connect(update_mob_health)
				


func update_mob_health(value: float) -> void:
	
	texture_progress_bar.value = value
	print(texture_progress_bar.value)


#region Processes

func _ready() -> void:
	con_to_signals()
	

func _process(delta: float) -> void:
	pass

#endregion

func declare_initial_stats(health: float) -> void:

	mob_health = health
	texture_progress_bar.min_value = 0.0
	texture_progress_bar.max_value = health
	
	texture_progress_bar.value = health
	
