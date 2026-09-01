extends CanvasLayer

#region References

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

#endregion -- References


func _ready() -> void:
	pass
	

func transition_to_previous_stage(scene_path: String, p1_spawn: Vector2, p2_spawn: Vector2) -> void:
	animation_player.play("fade_to")
	await animation_player.animation_finished
	
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	
	var player_one = get_tree().get_first_node_in_group("Player_target")
	var player_two = get_tree().get_first_node_in_group("Player_target")
	
	if player_one and player_two:
		
		player_one.global_position = p1_spawn
		player_two.global_position = p2_spawn

		player_one.p_health = GameManager.player_saved_health
		player_one.r_amount = GameManager.player_saved_rage
	
	animation_player.play("fade_out")
	await animation_player.animation_finished
	
	SignalHub.transition_done.emit()
	queue_free()




func transition_to_scene(scene_path: String) -> void:
	animation_player.play("fade_to")
	await animation_player.animation_finished
	
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	
	var player_one = get_tree().get_first_node_in_group("Player_target")
	var player_two = get_tree().get_first_node_in_group("Player_target")
	
	if player_one and player_two:
		if GameManager.out_of_initial_level:
			player_one.p_health = GameManager.player_saved_health
			player_one.r_amount = GameManager.player_saved_rage
	
	
	animation_player.play("fade_out")
	await animation_player.animation_finished
	
	SignalHub.transition_done.emit()
	queue_free()
