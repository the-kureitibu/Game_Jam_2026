extends EnemyBase

#region Declared Vars

#region Signals

signal update_health(value: float)

#endregion

#region Base Vars

var speed: float = 60.0
var target_x: float = 0.0
var is_attacking: bool = false
var MAX_HEALTH: float = 100.0

var m_health: float = 100.0: 
	set(value):
		var new_health = value
		
		if m_health == new_health:
			return
		
		m_health = clamp(new_health, 0.0, MAX_HEALTH)
		
		update_health.emit(new_health)
		
		
var dmg: float = 10.0

#endregion

#region HitBox/HurtBox

@onready var hit_box: CollisionShape2D = $HitBox/HitBoxCol
@onready var hurt_box: CollisionShape2D = $HurtBox/HurtBoxCol

var is_hurt: bool = false

#endregion

#region Movement related

var patrol_distance: float = 50.0
var starting_x: float
var patrol_dir: int = 1
var is_target_nearby: bool = false

@onready var jump_height := 70.0
@onready var time_to_apex := 0.35
@onready var time_to_fall := 0.25
@onready var apex_threshold := 35.0
@onready var apex_gravity_multiplier := 0.25
@onready var jump_gravity := (2.0 * jump_height) / pow(time_to_apex, 2.0)
@onready var fall_gravity := (2.0 * jump_height) / pow(time_to_fall, 2.0)

@onready var jump_velocity := -jump_gravity * time_to_apex

var jump_attack_speed_min := 120.0
var jump_attack_speed_max := 360.0
var landing_offset := 24.0

#region References

@onready var t_player: Node2D = get_tree().get_first_node_in_group("Player_target")
@onready var m_sprite: AnimatedSprite2D = $MainSprite
@onready var monster_health_bar: Control = $MonsterHealthBar


#endregion

#region Timers
@onready var attk_timer := 0.0
#endregion

#region States
@onready var mob_one_state: EnemyBase.MobStates = MobStates.IDLE

#endregion

#endregion 

#region Tests 
#
#func _draw() -> void:
	#
	#draw_circle(Vector2(0, 0), 100.0, Color.RED, false, -2.0)

#endregion

#region Processes
func _ready() -> void:
	starting_x = global_position.x
	target_x = starting_x + patrol_distance
	patrol_dir = 1
	
	monster_health_bar.declare_initial_stats(m_health)


func _physics_process(delta: float) -> void:
	#queue_redraw()

	check_target_nearby()
	apply_gravity(delta)
	
	if mob_one_state == MobStates.ATTACKING:
		update_attack_movement()
	elif is_target_nearby:
		jump_to_target()
	else:
		patrol_idle()
	
	
	move_and_slide()
	handle_anim()
	update_attack_state(delta)

#endregion

#region Target and Movement
func check_target_nearby() -> void:
	if t_player == null:
		return
	
	var dis_to_player = t_player.global_position.x - global_position.x
	var dir_to_player = sign(dis_to_player)
	var abs_dis = abs(dis_to_player)
	
	var detection_range := 100.0

	if abs_dis <= detection_range and dir_to_player == patrol_dir:
		is_target_nearby = true
	else:
		is_target_nearby = false
		

func patrol_idle() -> void:
	if get_tree().paused:
		velocity.x = 0
		return

	var distance_to_target := target_x - global_position.x
	patrol_dir = sign(distance_to_target)
	
	if abs(distance_to_target) <= 2.0:
		if target_x > starting_x:
			target_x = starting_x - patrol_distance
		else:
			target_x = starting_x + patrol_distance
	
	velocity.x = patrol_dir * speed

func handle_anim() -> void:
	if velocity.x > 0.0 and mob_one_state == MobStates.IDLE:
		play_anim(m_sprite, "walk")
		
	if is_hurt: 
		play_anim(m_sprite, "hurt")

func apply_gravity(delta) -> void:
	if get_tree().paused:
		velocity.y = 0
		return

	if is_on_floor():
		return
	
	var current_gravity: float
	
	if velocity.y < 0.0:
		current_gravity = jump_gravity
	else:
		current_gravity = fall_gravity
	
	velocity.y += current_gravity * delta

#endregion

#region Attack 

func hit() -> float:
	
	return dmg

func jump_to_target() -> void:
	if get_tree().paused:
		velocity.y = 0
		velocity.x = 0
		
		return


	if t_player == null:
		return 
	
	if not is_on_floor():
		return

	if mob_one_state == MobStates.ATTACKING: 
		return
	
	is_attacking = true
	mob_one_state = MobStates.ATTACKING
	
	var dis_to_player = t_player.global_position.x - global_position.x
	var dir_to_player = sign(dis_to_player)
	
	if dir_to_player == 0:
		dir_to_player = patrol_dir
		
	# Land near the player, not exactly on center.
	var target_landing_x = t_player.global_position.x - dir_to_player * landing_offset
	var distance_to_landing = target_landing_x - global_position.x
	
	# Approximate total air time.
	var estimated_air_time := time_to_apex + time_to_fall
	
	var needed_x_speed = distance_to_landing / estimated_air_time
	needed_x_speed = clamp(needed_x_speed, -jump_attack_speed_max, jump_attack_speed_max)
	
	if abs(needed_x_speed) < jump_attack_speed_min:
		needed_x_speed = dir_to_player * jump_attack_speed_min
	
	velocity.x = needed_x_speed
	velocity.y = jump_velocity
	
	attk_timer = 3.0

func update_attack_state(delta) -> void:
	if not is_attacking:
		return
	
	attk_timer -= delta
	
	if attk_timer <= 0.0:
		end_attack()

func update_attack_movement() -> void:
	if get_tree().paused:
		velocity.y = 0
		return
	
	if not is_on_floor():
		return
	
	# Once landed, stop sliding.
	velocity.x = 0.0

func end_attack() -> void:
	is_attacking = false
	mob_one_state = MobStates.IDLE
	velocity.x = 0.0
	reset_patrol_target()

func reset_patrol_target() -> void:
	if global_position.x >= starting_x:
		target_x = starting_x - patrol_distance
	else:
		target_x = starting_x + patrol_distance

#endregion


#region HurtBox Handler

func handle_hurt(damage: float) -> void:
	if is_hurt:
		return
	
	start_hurt(damage)
	

func start_hurt(damage: float) -> void:
	
	is_hurt = true
	m_health -= damage

func handle_death() -> void:
	pass

#endregion

#region HurtBox and HitBox Signals

func _on_hit_box_area_entered(area: Area2D) -> void:
	var p_target = area.get_tree().get_first_node_in_group("Player_target")
	
	if p_target and "handle_hurt" in p_target:
		p_target.handle_hurt(dmg)


func _on_hurt_box_area_entered(area: Area2D) -> void:
	var p_target = area.get_tree().get_first_node_in_group("Player_target")
	
	if p_target and "hit" in p_target:
		var p_dmg = p_target.hit()
		handle_hurt(p_dmg)


#endregion


#region Animation Signal

func _on_main_sprite_animation_finished() -> void:
	if m_sprite.animation == "hurt":
		is_hurt = false
		mob_one_state = MobStates.IDLE
		

#endregion
