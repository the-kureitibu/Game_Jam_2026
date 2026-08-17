extends Node2D

#region References

@onready var michael_statue: AnimatedSprite2D = $MichaelStatue
var cur_statue_frame := 0
var max_statue_frame := 3
@onready var michael_marker: Marker2D = $MichaelMarker

#region -- References

#region Functions

#region Statue related

func update_statue_sprite(sprite: AnimatedSprite2D, target_frame: int) -> void:
	sprite.frame = target_frame
	
	if sprite.frame == max_statue_frame:
		print("Summon Michael")

#endregion -- Statue related

#region Area Signals

func _on_statue_hurt_box_area_entered(area: Area2D) -> void:
	var player = area.name
	
	if player == 'HitBox':
		cur_statue_frame += 1
		update_statue_sprite(michael_statue, cur_statue_frame)
	else:
		print("Not Hitbox: ")

#endregion -- Area Signals

#endregion -- Functions
