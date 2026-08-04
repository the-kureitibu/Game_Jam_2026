extends Control

#region Base Vars

@export var monster: Node2D
var mob_health: float = 0.0


#endregion



#region Signals

#endregion

#region Processes

func _ready() -> void:
	
	declare_initial_stats()


func _process(delta: float) -> void:
	pass

#endregion

func declare_initial_stats() -> void:
	
	if monster == null:
		push_error("Monster does not exist")
		
	mob_health = monster.health
