extends Node

class_name PlayerBase

var player_health: int
var player_speed: float
var player_damage: int

func _init(p_health: int, p_speed: float, p_damage: int) -> void:
	player_health = p_health
	player_speed = p_speed
	player_damage = p_damage
