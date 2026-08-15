extends CanvasLayer

#region References

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

#endregion -- References


func _ready() -> void:
	pass
	

func transition_to_scene(scene_path: PackedScene) -> void:
	animation_player.play("fade_to")
	await animation_player.animation_finished
	
	get_tree().change_scene_to_packed(scene_path)
	await get_tree().process_frame
	
	animation_player.play("fade_out")
	await animation_player.animation_finished
	
	SignalHub.transition_done.emit()
	queue_free()
