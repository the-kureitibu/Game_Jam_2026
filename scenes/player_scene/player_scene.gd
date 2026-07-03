extends PlayerBase

@export var stats: PlayerStats 

func _ready() -> void:
	if stats == null:
		push_error("Enemy has no stats resource assigned.")
		return
	
	print("I am champ")
	print(stats.player_health)
	
