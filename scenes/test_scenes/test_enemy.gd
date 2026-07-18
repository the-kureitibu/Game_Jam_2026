extends CharacterBody2D

@export var hurtbox: Area2D

var test_dmg: int = 20

func _ready() -> void:
	pass
 
func hit() -> int:
	
	print("You got hit!")
	return test_dmg

func hurt() -> void: 
	print("I got hurt!")

func _on_hurt_box_area_entered(area: Area2D) -> void:
	var from_player = area.get_tree().get_first_node_in_group("Player_target")
	var test_val: int
	
	if from_player:
		print("hit exist")
		if "hit" in from_player:
			test_val = from_player.hit()
			print("value from player ", test_val)
			hurt()
	else:
		print("no hit")


func _on_hit_box_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
