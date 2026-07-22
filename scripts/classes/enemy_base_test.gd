extends Node

class_name EnemyBaseTest


func got_hurt(dmg: int, cur_health: int) -> void:
	cur_health -= dmg


func _on_hitbox_entered(area: Area2D):
	var from_player = area.get_tree().get_first_node_in_group("Player_target")
	var test_val: int
	
	if from_player:
		print("hit exist")
		if "hit" in from_player:
			test_val = from_player.hit()
			print("value from player ", test_val)
			#hurt()
	else:
		print("no hit")
