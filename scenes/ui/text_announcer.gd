extends CanvasLayer

#region References

@onready var text_label: RichTextLabel = $MainControl/MainMargin/TextLabel
var can_send_signal := false

#endregion --  References

#pass the previous scene name from GAme manager to here 
#compare current scene name vs previous scene name from manager 
#if tween is running, kill, update

func _enter_tree() -> void:
	add_to_group("text_announcer")
	if GameManager.game_scene_state == GameManager.GameLevelStates.END_GAME:
		can_send_signal = true

func announce(text: String) -> void:
	
	var tween = create_tween()
	
	text_label.text = text
		
	tween.tween_property(text_label, "modulate:a", 0.0, 2.0)
	tween.tween_property(text_label, "modulate:a", 1.0, 2.0)
	tween.tween_property(text_label, "modulate:a", 0.0, 2.0)
		
	await tween.finished 
	
	if can_send_signal:
		SignalHub.start_end_game_dialogue.emit()
		
	queue_free()


func announce_death(text: String) -> void:
	
	var tween = create_tween()

	text_label.text = text
	
	tween.tween_property(text_label, "modulate:a", 0.0, 4.0)
	
	await tween.finished 
	
	SignalHub.stage_restart.emit()
	
	queue_free()
