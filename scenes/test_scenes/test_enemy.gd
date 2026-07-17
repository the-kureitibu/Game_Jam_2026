extends CharacterBody2D

@export var hurtbox: Area2D

func _ready() -> void:
	pass
 

func hurt() -> void: 
	print("I got hurt!")

func _on_hurt_box_area_entered(area: Area2D) -> void:
	var from_player = area.get_tree().get_first_node_in_group("Player_target")
	
	if "hit" in area:
		if from_player:
			hurt()
