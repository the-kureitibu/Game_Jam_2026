extends PlayerBase

#region Signals
signal stat_changed(s_name: String, s_value: int)
signal r_timer_changed(r_name: String, r_value: float)
signal tmp_send_ini_state(st_name: String, st_value: int)

#endregion


#region Base Vars

var is_hurt: bool = false
var is_busy: bool = false
var is_raging: bool = false
var is_rage_cooling: bool = false
var is_transforming: bool = false
var input_available: bool = true
var is_invulnerable: bool = false


const MAX_HEALTH: int = 200
const MAX_DMG: int = 50
const MAX_RAGE: float = 100.0

@export var stats: PlayerStats
@export var p_health: int:
	set(value):
		if p_health == value:
			return
		
		p_health = clamp(value, 0, MAX_HEALTH)
		
		stat_changed.emit("p_health", value)
		
@export var p_speed: float
@export var p_damage: int:
	set(value):
		if value == p_damage:
			return
		
		p_damage = clamp(value, 0, MAX_DMG)
		stat_changed.emit("p_damage", value)
		
@export var r_amount: float:
	set(value):
		
		r_amount = clamp(value, 0, stats.rage_amount)
		stat_changed.emit("r_amount", value)
		
@export var r_per_attk: int
@export var p_sprite: AnimatedSprite2D
@export var s_sprite: AnimatedSprite2D
@export var anim_player: AnimationPlayer

@export var p_move_state: PlayerBase.PlayerMoveState = PlayerMoveState.IDLE:
	set(value):
		if p_move_state == value:
			return
		
		p_move_state = value
		tmp_send_ini_state.emit("p_move_state", p_move_state)
@export var p_form_state: PlayerBase.PlayerFormState = PlayerFormState.HUMAN_FORM:
	set(value):
		if p_form_state == value:
			return
		
		p_form_state = value
		tmp_send_ini_state.emit("p_form", p_form_state)

var p_direction: float = 0.0
var can_dash: bool

#endregion 

#region Movement Vars
@onready var jump_height := 100.0

@onready var time_to_apex := 0.35
@onready var time_to_fall := 0.25
@onready var apex_threshold := 35.0
@onready var apex_gravity_multiplier := 0.25

@onready var jump_gravity := (2.0 * jump_height) / pow(time_to_apex, 2.0)
@onready var fall_gravity := (2.0 * jump_height) / pow(time_to_fall, 2.0)

@onready var jump_velocity := -jump_gravity * time_to_apex
var is_on_air := false
var facing_dir := 1

#endregion

#region Attack Base Vars
var is_attacking := false
var combo_seq := 0
const MAX_COMBO = 2
var combo_input_queued: bool
var attack_window_open := false
var has_attk_mid_air := false
var is_blocking := false

var p_action_state: PlayerBase.PlayerActionState = PlayerActionState.NONE:
	set(value):
		if p_action_state == value:
			return
		
		p_action_state = value
		tmp_send_ini_state.emit("p_action_state", p_action_state)

#endregion
#region References Vars

@export var p_proj_sprite: Area2D
@onready var player_two: Node2D
@onready var hurt_box_col: CollisionShape2D = $HurtBox/HurtBoxCollision
const LIGHT_RAY = preload("res://scenes/projectiles_scene/light_ray_skill.tscn")
const MAGIC_BALL = preload("res://scenes/projectiles_scene/magic_ball_skill.tscn")
const WEB_ATTACK = preload("res://scenes/projectiles_scene/web_attack.tscn")

@onready var nearest_enemy: Node2D
@onready var magic_ball_marker: Marker2D = $MagicBallMarker
@onready var m_ball_marker_base_x = abs(magic_ball_marker.position.x)

const MAX_TARGET := 1

#endregion

#region Skill Base Vars

var web_ray_range: float = 250.0
var light_ray_range: float = 180.0
var can_skill: bool = true
var is_skilling := false

#endregion

#region Hitboxes, Hurtboxes Vars

@onready var mace_hit_box: CollisionShape2D = $HitBox/HitBoxCollision


#endregion

#region Consts

const UP_DIRECTION: Vector2 = Vector2.UP

#endregion

#region Timers

@export var invulnerable_timer: float = 0.0
@export var attk_c_timer: float = 0.0
@export var d_timer: float = 0.0
@export var r_timer: float = 0.0:
	set(value):
		if r_timer == value:
			return
		
		r_timer = value
		r_timer_changed.emit("rage_dur", value)


@export var r_cd_timer: float = 0.0:
	set(value):
		if r_cd_timer == value:
			return
		
		r_cd_timer = value
		r_timer_changed.emit("r_cd",value)

@export var s1_timer: float = 0.0
@export var s2_timer: float = 0.0

#endregion 

#region Camera Related 
@onready var cam_r_offset := 50.0
@onready var cam_l_offset := -50.0
@onready var cam_t_offset := -80.0
@onready var cam_b_offset := -100.0

#endregion

#region Test vars
var p_cur_state = p_move_state

#endregion 

#region Camera Support 
func grab_cam_limits() -> Dictionary:
	return {
		"cam_r_limit": global_position.x + cam_r_offset,
		"cam_l_limit": global_position.x + cam_l_offset,
		"cam_t_limit": global_position.y + cam_t_offset,
		"cam_b_limit": global_position.y + cam_b_offset
	}
	
	
	
#endregion


#region Test and Draw 

func _draw() -> void:
	var sp_texture = p_sprite.sprite_frames.get_frame_texture("idle", 0)
	var sp_height = sp_texture.get_height() / -2.0
	var y_offset = sp_height
	
	var draw_pos: Vector2 = Vector2(0, y_offset)
	draw_circle(draw_pos, 180.0, Color.RED, false, 2.0)

#endregion

#region Processes 

func _ready() -> void:

	SignalHub.blocking_anim_done.connect(end_blocking_state)

	dec_ini_stats()
	
	await get_tree().process_frame

	player_two = get_tree().get_first_node_in_group("Player_two")
	
	if player_two:
		player_two.blocking_started.connect(_on_block_connect)

	if not p_sprite.is_playing():
		p_sprite.play("idle")

	if stats == null:
		return
	
	if !mace_hit_box.disabled:
		mace_hit_box.set_deferred("disabled", true)
	
	attk_c_timer = stats.attk_combo_timer



func _physics_process(delta: float) -> void:
	#queue_redraw()
	#p_sprite.play("idle") - animation never runs without this
	reduce_timer(delta)
	apply_gravity(delta)
	player_move()
	start_attack()
	handle_hitbox_pos()
	handle_skill_one()
	handle_skill_two()
	start_block()
	player_jump()
	handle_air_state()
	update_move_state()
	update_rage_timer(delta)
	update_rage_cooling(delta)

#endregion

#region Initial Stats declaration
func dec_ini_stats() -> void:
	p_health = stats.player_health
	p_speed = stats.player_speed
	p_damage = stats.player_damage
	r_per_attk = stats.rage_per_attack
	SignalHub.set_ini_a_state.emit()
	SignalHub.set_ini_m_state.emit()

#endregion

#region Base movement

func player_move() -> void:
	if is_transforming:
		return
	
	if is_busy:
		return
	
	if is_blocking:
		return
	
	if is_on_floor():
		is_on_air = false

	if is_attacking:
		return

	p_direction = Input.get_axis("left", "right")

	velocity.x = p_direction * p_speed
	if velocity.x > 0:
		facing_dir = 1
	elif velocity.x < 0:
		facing_dir = -1

	if p_direction != 0:
		if p_form_state == PlayerFormState.HUMAN_FORM:
			p_sprite.flip_h = p_direction < 0
		else:
			s_sprite.flip_h = p_direction < 0
			
		magic_ball_marker.position.x = m_ball_marker_base_x * p_direction
	
	move_and_slide()


func player_jump() -> void:
	if !is_on_floor():
		return
	
	if Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

func handle_air_state() -> void:
	if !is_on_floor():
		is_on_air = true

func apply_gravity(delta) -> void:
	if is_on_floor():
		return
	
	var current_gravity: float
	
	if velocity.y < 0.0:
		current_gravity = jump_gravity
	else:
		current_gravity = fall_gravity
	
	if abs(velocity.y) < apex_threshold:
		current_gravity *= apex_gravity_multiplier
		
	velocity.y += current_gravity * delta



#endregion


#region Attack Related 
func start_block() -> void:
	if is_skilling:
		return
	
	if is_transforming:
		return
	
	if is_busy:
		return
	
	if is_attacking and !is_on_floor():
		return
	elif !is_on_floor():
		return
		
	if not Input.is_action_just_pressed("block"):
		return

	start_blocking()

func start_blocking() -> void:
	
	is_busy = true
	is_blocking = true
	
	p_action_state = PlayerActionState.BLOCKING
	play_anim(p_sprite, "block", true)
	p_sprite.sprite_frames.set_animation_loop("block", true)
	
func _on_block_connect() -> void:
	hurt_box_col.set_deferred("disabled", true)
	

func end_blocking_state() -> void:
	if !is_blocking:
		return
		
	end_blocking()

func end_blocking() -> void:
	
	if p_sprite.is_playing() and p_sprite.animation == "block":
		p_sprite.sprite_frames.set_animation_loop("block", false)
		p_sprite.stop()

	is_busy = false
	is_blocking = false
	p_action_state = PlayerActionState.NONE
	hurt_box_col.set_deferred("disabled", false)
	
	force_move_animation()

func start_attack() -> void:
	if is_skilling:
		return
	
	if is_transforming:
		return
	
	if !input_available:
		return

	if is_blocking:
		return
	
	if is_on_floor():
		has_attk_mid_air = false
	
	if not Input.is_action_just_pressed("attack"):
		return
	
	if is_attacking:
		
		if attack_window_open and combo_seq < MAX_COMBO:
			combo_input_queued = true
		return
		
	if p_form_state == PlayerFormState.HUMAN_FORM:
		start_attk_combo(1)
	else: 
		handle_web_attack()

func open_attack_window() -> void:
	attack_window_open = true
		
func close_attack_window() -> void:
	attack_window_open = false

func start_attk_combo(combo_count: int) -> void:

	if has_attk_mid_air:
		return
	
	is_busy = true
	is_attacking = true
	mace_hit_box.set_deferred("disabled", false)
	attack_window_open = false
	combo_input_queued = false
	combo_seq = combo_count
	attk_c_timer = stats.attk_combo_timer

	if p_form_state == PlayerFormState.HUMAN_FORM:
		if p_form_state == PlayerFormState.SPIDER_FORM:
			return
		
		match combo_seq:
			1:
				p_action_state = PlayerActionState.ATTACK
				play_anim(p_sprite, "attk_combo_1", true)
			2:
				p_action_state = PlayerActionState.COMBO_ATTACK
				play_anim(p_sprite, "attk_combo_2", true)
				

	if p_form_state == PlayerFormState.SPIDER_FORM:
		if p_form_state == PlayerFormState.HUMAN_FORM:
			return
		
		p_action_state = PlayerActionState.ATTACK
		play_anim(s_sprite, "attack", true)
	
	open_attack_window()

func _on_main_sprite_animation_finished() -> void:
	
	if is_hurt and p_action_state == PlayerActionState.HURT:
		end_hurt()

	if is_attacking:
		if is_on_air:
			has_attk_mid_air = true
			end_combo()

		if combo_input_queued and combo_seq < MAX_COMBO:
			start_attk_combo(combo_seq + 1)
		elif combo_seq == MAX_COMBO:
			end_combo()
		else:
			end_combo()

func _on_spider_sprite_animation_finished() -> void:
	
	if is_hurt and p_action_state == PlayerActionState.HURT:
		end_hurt()
		

	if is_attacking:
		if is_on_air:
			has_attk_mid_air = true
			

	end_combo()


func accumulate_rage() -> void:
	if p_form_state == PlayerFormState.SPIDER_FORM:
		print("Player is Spider form")
		return
	
	if p_action_state == PlayerActionState.RAGE_TRANSFORM:
		print("Player is rage transforming")
		return
	
	if is_raging:
		print("Player raging. ", is_raging)
		return
	
	if r_amount < MAX_RAGE:
		r_amount += r_per_attk
	
	handle_rage()


func handle_rage() -> void:
	if r_amount < MAX_RAGE:
		return

	rage_transform()


func rage_transform() -> void:
	
	if is_raging or is_transforming:
		return
	
	is_transforming = true

	p_action_state = PlayerActionState.RAGE_TRANSFORM
	anim_player.play("rage_transform")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	
	if anim_name == "rage_transform":
		is_transforming = false
		is_raging = true
		
		p_form_state = PlayerFormState.SPIDER_FORM
		p_action_state = PlayerActionState.NONE
		
		r_timer = stats.rage_timer
		
	if anim_name == "to_human_transform":
		is_transforming = false
		end_rage()

func to_human_transform() -> void:
	
	if is_transforming:
		return
	
	is_transforming = true

	p_action_state = PlayerActionState.RAGE_TRANSFORM
	anim_player.play("to_human_transform")

func update_rage_timer(delta) -> void:
	if !is_raging:
		return
	
	r_timer = set_timer(r_timer, delta)
	
	if r_timer <= 0.0:
		handle_rage_cooling()

func handle_rage_cooling() -> void:
	if is_rage_cooling:
		return

	is_rage_cooling = true
	r_cd_timer = stats.rage_cd_timer
	

func update_rage_cooling(delta) -> void:
	if !is_rage_cooling:
		return
	
	r_cd_timer = set_timer(r_cd_timer, delta)
	r_amount = max(r_amount - 20.0 * delta, 0)

	if r_cd_timer <= 0.0:
		to_human_transform()

func end_rage() -> void:
	if !is_raging: 
		return
	
	is_rage_cooling = false
	is_raging = false
	p_form_state = PlayerFormState.HUMAN_FORM


func end_combo() -> void:
	is_busy = false
	is_attacking = false
	mace_hit_box.set_deferred("disabled", true)
	combo_input_queued = false
	combo_seq = 0
	attk_c_timer = 0.0
	p_action_state = PlayerActionState.NONE
	
	force_move_animation()
	reset_hit_box_pos()

func force_move_animation() -> void:
	
	if !is_on_floor():
		play_anim(p_sprite, "jump")
	elif abs(velocity.x) > 0.1:
		play_anim(p_sprite, "walk")
	else:
		play_anim(p_sprite, "idle")

		
#endregion 

#region HurtBox

func handle_hurt(damage: int) -> void:
	if is_invulnerable:
		return
	
	start_hurt(damage)


func start_hurt(damage: int) -> void:
	is_busy = true
	input_available = false
	
	if is_invulnerable:
		return

	is_invulnerable = true
	is_hurt = true
	
	
	p_action_state = PlayerActionState.HURT
	if p_form_state == PlayerFormState.HUMAN_FORM:
		play_anim(p_sprite, "hurt")
	else:
		play_anim(s_sprite, "hurt")
	
	if not (p_health <= 0):
		p_health -= damage
	else:
		death()
	
	invulnerable_timer = stats.invul_timer

func end_hurt() -> void:
	
	input_available = true
	is_busy = false
	is_hurt = false
	p_action_state = PlayerActionState.NONE
	force_move_animation()

#endregion

#region HitBox
func hit() -> int:
	return p_damage

func handle_hitbox_pos() -> void:
	if !is_attacking:
		return
	
	var cur_frame = p_sprite.frame
	
	update_hit_box_pos(cur_frame)

func update_hit_box_pos(frame: int) -> void:
	
	var current_pos := frame
	if p_sprite.animation == "attk_combo_1":
		match current_pos:
			1:
				if p_sprite.flip_h:
					pass_hitbox_values(10.0, 30.0, Vector2(-19.0, -37.0), 43.9, false)
				else:
					pass_hitbox_values(10.0, 30.0, Vector2(19.0, -37.0), 43.9, false)
			2:
				if p_sprite.flip_h:
					pass_hitbox_values(12.0, 36.1, Vector2(-36.1, -46.0), -91.6, false)
				else:
					pass_hitbox_values(12.0, 36.1, Vector2(36.1, -46.0), -91.6, false)
			_:
				pass

	if p_sprite.animation == "attk_combo_2":
		match current_pos:
			0, 1:
				if p_sprite.flip_h:
					pass_hitbox_values(12.0, 36.1, Vector2(-45.0, -50.0), -93.1, true)
				else:
					pass_hitbox_values(12.0, 36.1, Vector2(45.0, -50.0), -93.1, true)
			2:
				if p_sprite.flip_h:
					pass_hitbox_values(12.0, 36.1, Vector2(-45.0, -50.0), -93.1, true)
					p_proj_sprite.position = Vector2(-89.0, -43.0)
				else:
					pass_hitbox_values(12.0, 36.1, Vector2(45.0, -50.0), -93.1, true)
					p_proj_sprite.position = Vector2(89.0, -43.0)
				
				p_proj_sprite.handle_initial_attack()
			3, 4, 5:
				pass_hitbox_values(10.0, 30.0, Vector2(0.0, 0.0), 0.0, true)
			_:
				pass

func pass_hitbox_values(radius: float, height: float, pos: Vector2, rot: float, change_rot: bool):

	mace_hit_box.shape.radius = radius
	mace_hit_box.shape.height = height
	mace_hit_box.position = pos
	
	if change_rot:
		mace_hit_box.rotation_degrees = rot
	else:
		mace_hit_box.rotation = rad_to_deg(rot)

	
func reset_hit_box_pos() -> void:
	mace_hit_box.shape.radius = 10.0
	mace_hit_box.shape.height = 30.0
	mace_hit_box.position = Vector2(0.0, 0.0)
	mace_hit_box.rotation = 0



#endregion

#region Player States 

func change_move_state(new_state: PlayerMoveState) -> void:
	if is_attacking and p_form_state == PlayerFormState.HUMAN_FORM:
		print("Did this worked")
		return

	if p_move_state == new_state:
		return
	
	p_move_state = new_state
	
	if p_form_state == PlayerFormState.HUMAN_FORM:
		match_spider_human_movement(p_move_state, p_sprite, "jump", "walk", "idle")
	if p_form_state == PlayerFormState.SPIDER_FORM:
		match_spider_human_movement(p_move_state, s_sprite, "jump", "walk", "idle")

func match_spider_human_movement(f_state: PlayerBase.PlayerMoveState, sprt: AnimatedSprite2D,
	jump: StringName, walk: StringName, idle: StringName) -> void:
		match f_state:
			PlayerMoveState.JUMP:
				play_anim(sprt, jump)
			PlayerMoveState.RUN:
				play_anim(sprt, walk)
			PlayerMoveState.IDLE:
				play_anim(sprt, idle)
	

func update_move_state() -> void:
	
	if !is_on_floor():
		change_move_state(PlayerMoveState.JUMP)
	elif abs(velocity.x) > 0.1:
		change_move_state(PlayerMoveState.RUN)
	else:
		change_move_state(PlayerMoveState.IDLE)
		

func change_action_state(new_state) -> void:
	if p_action_state == new_state:
		return
	
	p_action_state = new_state
	print(p_action_state)

#endregion 

#region Skill related Logic 

#region Light Ray Skill
func handle_skill_one() -> void:
	if !can_skill:
		return
	
	if is_skilling:
		return
	
	if Input.is_action_just_pressed("skill_one"):
		start_skill_one()

func start_skill_one() -> void:
	if is_skilling:
		return

	handle_light_ray()
	
func handle_light_ray() -> void:
	find_nearest_enemy()

func find_nearest_enemy() -> void:
	var targets = get_tree().get_nodes_in_group("Enemy_target")

	
	var closest_target: Node2D = null
	var closest_distance := INF
	var acquired_target := 0
	
	for target in targets:
		
		if target == null or not is_instance_valid(target):
			continue
		
		if target is not Node2D:
			continue
		
		var distance := global_position.distance_to(target.global_position)
		
		if distance > light_ray_range:
			continue
		
		if distance < closest_distance:
			closest_distance = distance
			closest_target = target
		
		if closest_target == null:
			print("No enemy in range")
			return
		
	
	nearest_enemy = closest_target
	start_light_ray_skill(nearest_enemy, LIGHT_RAY)

func start_light_ray_skill(n: Node2D, scene: PackedScene):
	if n == null:
		print("No target acquired")
		return

	is_skilling = true
	
	var light_ray_scene = scene.instantiate()
	var y_offset = light_ray_scene.h_offset
	
	light_ray_scene.global_position = Vector2(n.global_position.x, 
									n.global_position.y + -y_offset) 
	light_ray_scene.scale = Vector2(2.5, 1.0)
	
	var parent_node = get_tree().current_scene.get_node("Projectiles")
	parent_node.add_child(light_ray_scene)

	can_skill = false
	light_ray_scene.light_ray_done.connect(end_skill)
#endregion

#region Magic Ball Skill

func handle_skill_two() -> void:
	if !can_skill:
		return
	
	if is_skilling:
		return
	
	if Input.is_action_just_pressed("skill_two"):
		start_skill_two()

func start_skill_two() -> void:
	if is_skilling:
		return
	
	launch_magic_ball(MAGIC_BALL, facing_dir, magic_ball_marker.global_position)


func launch_magic_ball(scene: PackedScene, dir: int, pos: Vector2) -> void:
	is_skilling = true
	can_skill = false
	
	var signed_dir: Vector2 = Vector2.ZERO
	if dir == -1:
		signed_dir = Vector2.LEFT
	else: 
		signed_dir = Vector2.RIGHT
	
	var magic_ball_scene = scene.instantiate()
	magic_ball_scene.dir = signed_dir
	magic_ball_scene.global_position = pos
	magic_ball_scene.marker_target = magic_ball_marker
	magic_ball_scene.scale = Vector2(2.5, 2.5)
	
	var parent_node = get_tree().current_scene.get_node("Projectiles")
	parent_node.add_child(magic_ball_scene)
	
	magic_ball_scene.launched_done.connect(end_skill)
	
	
#endregion

#region Web Attack 
func handle_web_attack() -> void:
	if !p_form_state == PlayerFormState.SPIDER_FORM:
		return

	start_web_attack()

func start_web_attack() -> void:
	
	if is_attacking:
		return

	
	is_busy = true
	is_attacking = true

	handle_web_rays()
	
func handle_web_rays() -> void:
	find_nearest_target()

func find_nearest_target() -> void:
	var targets = get_tree().get_nodes_in_group("Enemy_target")

	var closest_target: Node2D = null
	var closest_distance := INF
	var acquired_target := 0
	
	for target in targets:
		
		if target == null or not is_instance_valid(target):
			continue
		
		if target is not Node2D:
			continue
		
		var distance := global_position.distance_to(target.global_position)
		
		if distance > web_ray_range:
			continue
		
		if distance < closest_distance:
			closest_distance = distance
			closest_target = target
		
		if closest_target == null:
			print("No enemy in range")
			return
		
	
	nearest_enemy = closest_target
	start_web_ray(nearest_enemy, WEB_ATTACK)

func start_web_ray(n: Node2D, scene: PackedScene):
	if n == null:
		print("No target acquired") #play anim here
		return

	var web_ray_scene = scene.instantiate()
	var y_offset = web_ray_scene.h_offset
	
	web_ray_scene.global_position = Vector2(n.global_position.x, 
									n.global_position.y) 
	web_ray_scene.scale = Vector2(2.5, 1.0)
	
	var parent_node = get_tree().current_scene.get_node("Projectiles")
	parent_node.add_child(web_ray_scene)

	can_skill = false
	web_ray_scene.web_attack_done.connect(end_web_combo)

#endregion

func end_web_combo() -> void:
	
	is_busy = false
	is_attacking = false
	attk_c_timer = 0.0
	p_action_state = PlayerActionState.NONE
	
	force_move_animation()


func end_skill() -> void:
	is_skilling = false
	can_skill = true
	print("Skill ended")


#endregion



#region Timers func

func reduce_timer(delta: float) -> void:
	attk_c_timer = set_timer(attk_c_timer, delta)
	if attk_c_timer <= 0.0:
		close_attack_window()
	
	invulnerable_timer = set_timer(invulnerable_timer, delta)
	if invulnerable_timer <= 0.0:
		is_invulnerable = false
	
	d_timer = set_timer(d_timer, delta)
	

	s1_timer = set_timer(s1_timer, delta)
	s2_timer = set_timer(s2_timer, delta)

#endregion

#region Area2d Related 
func _on_hurt_box_area_entered(area: Area2D) -> void:
	var from_enemy = area.get_tree().get_first_node_in_group("Enemy_target")
	
	if from_enemy:
		var en_damage: int
		
		if "hit" in from_enemy:
			from_enemy.hit()
			en_damage = from_enemy.hit()
			handle_hurt(en_damage)

func _on_hit_box_area_entered(area: Area2D) -> void:
	var from_area = area.get_tree().get_first_node_in_group("Enemy_target")
	
	if from_area:
		accumulate_rage()


#endregion


#region Test func

func view_state() -> void:
	print(p_cur_state)
	
func test_signal() -> void:
	print("test worked")
	

#endregion

#region Debuggings
func print_default(message: String, object: Variant):

	print("%s , %s" % [message, object])

func print_debug_with_timestamp(message: String, object: Variant):
	var time_ms = Time.get_ticks_msec()
	var frame = Engine.get_process_frames()
	print("[%s | Frame %d] %s %s" % [time_ms, frame, message, object])
#endregion
