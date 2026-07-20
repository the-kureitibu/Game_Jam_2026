extends Resource

class_name PlayerStats

@export var player_health: int = 120
@export var player_speed: float = 120.0
@export var player_damage: int = 20
@export var rage_amount: float = 20.0
@export var rage_per_attack: int = 5

#region Timers
@export var invul_timer: float = 1.0
@export var attk_combo_timer: float = 2.0 
@export var dash_timer: float = 0.35
@export var rage_timer: float = 15.0
@export var rage_cd_timer: float = 5.0
@export var s1_cd_timer: float = 5.0
@export var s2_cd_timer: float = 7.0

#endregion
