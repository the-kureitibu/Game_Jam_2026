extends CanvasLayer

#region References

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

#endregion -- References


func _ready() -> void:
	pass
	

func _fade_to() -> void:
	animation_player.play("fade_to")
	await animation_player.animation_finished
	
	SignalHub.transition_done.emit()
	
	queue_free()

func _fade_out() -> void:
	animation_player.play("fade_out")
	
	await animation_player.animation_finished
	
	SignalHub.transition_done.emit()
	
	queue_free()
