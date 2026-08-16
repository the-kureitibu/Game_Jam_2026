extends CanvasLayer

#region References

@onready var text_label: RichTextLabel = $MainControl/MainMargin/TextLabel

#endregion --  References

func announce(text: String) -> void:
	
	var tween = create_tween()

	text_label.text = text
	
	tween.tween_property(text_label, "modulate:a", 0.0, 2.0)
	tween.tween_property(text_label, "modulate:a", 1.0, 2.0)
	tween.tween_property(text_label, "modulate:a", 0.0, 2.0)
	
	await tween.finished 
	
	queue_free()

func announce_death(text: String) -> void:
	
	var tween = create_tween()

	text_label.text = text
	
	tween.tween_property(text_label, "modulate:a", 0.0, 2.0)
	
	await tween.finished 
	
	SignalHub.stage_restart.emit()
	
	queue_free()
