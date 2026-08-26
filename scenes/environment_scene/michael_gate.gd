extends StaticBody2D


@onready var col: CollisionShape2D = $Col
@onready var gate: AnimatedSprite2D = $Gate
@onready var area_2d: CollisionShape2D = $InputArea/Area2D
@onready var line_edit: LineEdit = $LineEdit


var in_front_of_gate: bool = false
var gate_opened: bool = false
var password := "56709"
var is_pass_matched := false

signal can_play_bgm 

#region BGM

@onready var bgm_56709: String = "res://assets/audio/bgm/56709.ogg"
@onready var fall_of_arcana: String = "res://assets/audio/bgm/The Fall of Arcana.mp3"


#endregion -- BGM

#region SFX 
@onready var typing_sfx: String = "res://assets/audio/sfx/typewriter3.wav"


#region Gate Related

func unlock_gate() -> void:
	
	if is_pass_matched:
		AudioManager.play_music(typing_sfx, "oneshot", -6.0)
		
		line_edit.visible = false
		
		play_anim(gate)
	else: 
		return


#endregion

#region Processes
func _ready() -> void:
	line_edit.visible = false
	
func _process(delta: float) -> void:
	unlock_gate()
	
#endregion -- Processes

#region Area Signals

func _unhandled_input(event: InputEvent) -> void:
	if !in_front_of_gate:
		return
	
	if event.is_action_pressed("up"):
		AudioManager.play_music(typing_sfx, "oneshot", -6.0)

		line_edit.visible = true


func _on_input_area_body_entered(body: Node2D) -> void:
	
	var player = body.get_tree().get_first_node_in_group("Player_target")
	
	if player: 
		in_front_of_gate = true

func _on_input_area_body_exited(body: Node2D) -> void:
	if !gate_opened:
		in_front_of_gate = false

#endregion -- Area Signals

#region Music

func play_unlock_bgm() -> void:

	AudioManager.play_music(bgm_56709, "bgm", -10.0)
	
	await get_tree().create_timer(7.0).timeout
	
	can_play_bgm.emit()
	


#endregion Music 


#region Animation Related

func play_anim(sprite: AnimatedSprite2D) -> void:
	if gate_opened:
		return
	
	play_unlock_bgm()

	sprite.play("gate")

	
func _on_gate_animation_finished() -> void:
	col.set_deferred("disabled", true)
	area_2d.set_deferred("disabled", true)
	gate_opened = true


#endregion -- Animation Related

#region Player Input 

func _on_line_edit_text_submitted(new_text: String) -> void:
	if new_text == password:
		is_pass_matched = true
	else:
		line_edit.clear()
		
#endregion Player Input 
