extends Resource

class_name PlayerStats

@export var player_health: float = 200.0
@export var player_speed: float = 150.0
@export var player_damage: float = 20.0
@export var rage_amount: float = 100.0
@export var rage_per_attack: float = 5.0

#region Timers
@export var invul_timer: float = 1.0
@export var attk_combo_timer: float = 2.0 
@export var dash_timer: float = 0.35
@export var rage_timer: float = 15.0
@export var rage_cd_timer: float = 5.0
@export var s1_cd_timer: float = 5.0
@export var s2_cd_timer: float = 7.0

#endregion
