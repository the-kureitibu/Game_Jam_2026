extends CanvasLayer

#region References

@onready var text_label: RichTextLabel = $MainControl/MainMargin/TextLabel
@onready var current_scene_name = get_tree().current_scene.name
@onready var saved_scene_name = current_scene_name

#endregion --  References

func _ready() -> void:
	print("current_scene_name: ", current_scene_name)
	print("saved_scene_name: ", saved_scene_name)

#pass the previous scene name from GAme manager to here 
#compare current scene name vs previous scene name from manager 
#if tween is running, kill, update

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
