extends PlayerBase

#region Signals

signal stat_changed(s_name: String, s_value: int)
signal r_timer_changed(r_name: String, r_value: float)
signal tmp_send_ini_state(st_name: String, st_value: int)
signal update_text_bucko(text: String)

#endregion

var michael_summoned := false
var has_revive := false
var revive_finishing := false

#region Internal Action Owner

enum ActionOwner {
	NONE,
	HUMAN_ATTACK,
	WEB_ATTACK,
	SKILL_1,
	SKILL_2,
	BLOCK,
	DASH,
	HURT,
	TRANSFORM_TO_SPIDER,
	TRANSFORM_TO_HUMAN,
	DEAD,
	REVIVE,
}

var action_owner: ActionOwner = ActionOwner.NONE
var action_id: int = 0

const QUEUE_NONE := -1
var queued_form_change: int = QUEUE_NONE

#endregion


#region Base Vars

var is_hurt: bool = false
var is_busy: bool = false
var is_raging: bool = false
var is_rage_cooling: bool = false
var is_transforming: bool = false
var input_available: bool = true
var is_invulnerable: bool = false
var is_in_flatform: bool = false

var transformation_queued: bool = false

const MAX_HEALTH: int = 200
const MAX_DMG: int = 50
const MAX_RAGE: float = 100.0

@export var stats: PlayerStats

@export var p_health: float:
	set(value):
		var new_health = value
		
		if p_health == new_health:
			return
		
		p_health = clamp(new_health, 0.0, MAX_HEALTH)
		stat_changed.emit("p_health", int(p_health))

@export var p_speed: float

@export var p_damage: int:
	set(value):
		if value == p_damage:
			return
		
		p_damage = clamp(value, 0, MAX_DMG)
		stat_changed.emit("p_damage", p_damage)

@onready var r_amount: float = 0.0:
	set(value):
		if stats == null:
			r_amount = value
			return
		
		r_amount = clamp(value, 0.0, stats.rage_amount)
		stat_changed.emit("r_amount", int(r_amount))

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

var p_action_state: PlayerBase.PlayerActionState = PlayerActionState.NONE:
	set(value):
		if p_action_state == value:
			return
		
		p_action_state = value
		tmp_send_ini_state.emit("p_action_state", p_action_state)

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

var max_fall_speed := 450.0
var is_on_air := false
var facing_dir := 1
var p_direction: float = 0.0

var can_dash: bool = true
var dash_timer := 0.0
var dash_duration := 0.2
var can_dash_timer := 0.0
var dash_speed := 600.0
var is_dashing := false
var has_dashed_mid_air := false

#endregion


#region Attack Vars

var is_attacking := false
var combo_seq := 0
const MAX_COMBO = 2
var combo_input_queued: bool = false
var attack_window_open := false
var has_attk_mid_air := false
var is_blocking := false

#endregion


#region References Vars

@export var p_proj_sprite: Area2D

@onready var player_two: Node2D
@onready var hurt_box_col: CollisionShape2D = $HurtBox/HurtBoxCollision
@onready var mace_hit_box: CollisionShape2D = $HitBox/HitBoxCollision

const LIGHT_RAY = preload("res://scenes/projectiles_scene/light_ray_skill.tscn")
const MAGIC_BALL = preload("res://scenes/projectiles_scene/magic_ball_skill.tscn")
const WEB_ATTACK = preload("res://scenes/projectiles_scene/web_attack.tscn")
const MICHAEL = preload("res://scenes/player_scene/michael.tscn")

@onready var nearest_enemy: Node2D
@onready var magic_ball_marker: Marker2D = $MagicBallMarker
@onready var m_ball_marker_base_x = abs(magic_ball_marker.position.x)

@onready var web_markers_parent: Node2D = $WebAttackParent
@onready var web_marker1: Marker2D = $WebAttackParent/WebMarker1
@onready var web_marker2: Marker2D = $WebAttackParent/WebMarker2
@onready var web_marker3: Marker2D = $WebAttackParent/WebMarker3

@onready var michael_marker: Marker2D = $MichaelMarker
@onready var speech_bubble_marker: Marker2D = $SpeechBubbleMarker
@onready var speech_bubble: Control = $SpeechBubbleMarker/SpeechBubble

const MAX_WEB_COUNT := 3
const WEB_DELAY := 0.08
const WEB_ATTACK_LOCK_TIME := 0.75

var current_web_index := 0
var current_web_count := 0
var web_marker_queue: Array[Node] = []
var is_web_sequence_active := false

#endregion


#region Skill Vars

var web_ray_range: float = 280.0
var light_ray_range: float = 200.0
var can_skill: bool = true
var is_skilling := false

@onready var ray_skill_damage: float = 30.0
@onready var magic_ball_skill_damage: float = 25.0
@onready var rage_web_damage: float = 35.0

#endregion


#region Timers

@export var invulnerable_timer: float = 0.0
@export var attk_c_timer: float = 0.0

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
		r_timer_changed.emit("r_cd", value)

@export var s1_timer: float = 0.0
@export var s2_timer: float = 0.0
@onready var web_attk_timer: float = 0.0

#endregion


#region Camera Related

@onready var cam_r_offset := 50.0
@onready var cam_l_offset := -50.0
@onready var cam_t_offset := -80.0
@onready var cam_b_offset := -100.0

func grab_cam_limits() -> Dictionary:
	return {
		"cam_r_limit": global_position.x + cam_r_offset,
		"cam_l_limit": global_position.x + cam_l_offset,
		"cam_t_limit": global_position.y + cam_t_offset,
		"cam_b_limit": global_position.y + cam_b_offset
	}

#endregion


#region SFX

@onready var PLAYER_WALKING: String = "res://assets/audio/sfx/player_walking.mp3"
@onready var SFX_AGH: String = "res://assets/audio/sfx/sfx agh.wav"
@onready var SWOSH_WHOOSH_AIR_CUT: String = "res://assets/audio/sfx/swosh-whoosh-air-cut.mp3"
@onready var WHEW: String = "res://assets/audio/sfx/sfx whew.wav"
@onready var rage_sfx: String = "res://assets/audio/sfx/sfx angry noise.wav"
@onready var skill_sfx: String = "res://assets/audio/sfx/sfx ha.wav"

#endregion


#region Speech Bubble

var is_bubble_up := false

func open_and_update_text(word: String, for_bucko: String) -> void:
	if is_bubble_up:
		return
	
	is_bubble_up = true
	
	speech_bubble.update_text(word)
	update_text_bucko.emit(for_bucko)
	
	if not speech_bubble_marker.visible:
		speech_bubble_marker.visible = true
	
	var timer := 1.0
	if GameManager.game_scene_state == GameManager.GameLevelStates.TUTORIAL_SCENE:
		timer = 5.0
	
	await get_tree().create_timer(timer).timeout
	
	if not is_instance_valid(self):
		return
	
	var tween = create_tween()
	tween.tween_property(speech_bubble_marker, "modulate:a", 0.0, 2.0)
	await tween.finished
	
	if not is_instance_valid(self):
		return
	
	close_bubbles()

func close_bubbles() -> void:
	speech_bubble_marker.visible = false
	is_bubble_up = false
	speech_bubble_marker.modulate.a = 1.0

#endregion


#region Ready / Process

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
	
	if not mace_hit_box.disabled:
		mace_hit_box.set_deferred("disabled", true)
	
	attk_c_timer = stats.attk_combo_timer
	
	SignalHub.is_in_flatform.connect(in_flatform)
	SignalHub.not_in_flatform.connect(not_in_flatform)
	SignalHub.revival_complete.connect(unpause_after_revive)
	
	if GameManager.game_scene_state == GameManager.GameLevelStates.TUTORIAL_SCENE:
		open_and_update_text("行こう", "Oraa")
	
	SignalHub.falling_players.connect(open_and_update_text.bind("WEEEE", "WEEEE"))
	SignalHub.awoo_56709.connect(open_and_update_text.bind(".....", "AWOOO~"))
	SignalHub.michael.connect(open_and_update_text.bind("Michael?!", "BUCKO?!"))

func _physics_process(delta: float) -> void:
	handle_floor_state()
	reduce_timer(delta)
	update_rage_logic(delta)
	consume_queued_form_change()
	
	if p_health <= 0.0:
		handle_death()
	
	apply_gravity(delta)
	read_action_input()
	update_controlled_movement()
	update_web_sequence(delta)
	
	move_and_slide()
	
	handle_hitbox_pos()
	player_jump()
	handle_air_state()
	update_move_state()

#endregion


#region Initial Stats

func dec_ini_stats() -> void:
	if stats == null:
		return
	
	p_health = stats.player_health
	p_speed = stats.player_speed
	p_damage = stats.player_damage
	r_per_attk = stats.rage_per_attack
	
	SignalHub.set_ini_a_state.emit()
	SignalHub.set_ini_m_state.emit()

#endregion


#region Action Owner Core

func begin_action(new_owner: ActionOwner, public_state: PlayerActionState, force_interrupt := false) -> int:
	if action_owner == ActionOwner.DEAD and new_owner != ActionOwner.REVIVE:
		return -1
	
	if action_owner != ActionOwner.NONE:
		if not force_interrupt:
			return -1
		
		cancel_current_action()
	
	action_id += 1
	action_owner = new_owner
	p_action_state = public_state
	sync_legacy_flags()
	
	return action_id

func finish_action(expected_id: int, expected_owner: ActionOwner) -> void:
	if not is_current_action(expected_id, expected_owner):
		return
	
	cancel_current_action()
	action_owner = ActionOwner.NONE
	p_action_state = PlayerActionState.NONE
	sync_legacy_flags()
	
	consume_queued_form_change()
	force_move_animation()

func is_current_action(expected_id: int, expected_owner: ActionOwner) -> bool:
	return action_id == expected_id and action_owner == expected_owner

func cancel_current_action() -> void:
	match action_owner:
		ActionOwner.HUMAN_ATTACK:
			cleanup_human_attack()
		ActionOwner.WEB_ATTACK:
			cleanup_web_attack()
		ActionOwner.SKILL_1, ActionOwner.SKILL_2:
			cleanup_skill()
		ActionOwner.BLOCK:
			cleanup_block()
		ActionOwner.DASH:
			cleanup_dash()
		ActionOwner.HURT:
			cleanup_hurt()
		ActionOwner.TRANSFORM_TO_SPIDER, ActionOwner.TRANSFORM_TO_HUMAN:
			cleanup_transform()
		ActionOwner.DEAD:
			cleanup_death()
		ActionOwner.REVIVE:
			pass

func sync_legacy_flags() -> void:
	is_hurt = action_owner == ActionOwner.HURT
	is_attacking = action_owner == ActionOwner.HUMAN_ATTACK or action_owner == ActionOwner.WEB_ATTACK
	is_blocking = action_owner == ActionOwner.BLOCK
	is_dashing = action_owner == ActionOwner.DASH
	is_skilling = action_owner == ActionOwner.SKILL_1 or action_owner == ActionOwner.SKILL_2
	is_transforming = action_owner == ActionOwner.TRANSFORM_TO_SPIDER or action_owner == ActionOwner.TRANSFORM_TO_HUMAN
	
	is_busy = action_owner != ActionOwner.NONE \
		and action_owner != ActionOwner.DASH \
		and action_owner != ActionOwner.WEB_ATTACK \
		and action_owner != ActionOwner.SKILL_1 \
		and action_owner != ActionOwner.SKILL_2
	
	input_available = action_owner == ActionOwner.NONE

func can_start_normal_action() -> bool:
	if GameManager.game_scene_state == GameManager.GameLevelStates.BOSS_ROOM \
	and GameManager.can_start_boss_fight == false:
		return false
	
	if action_owner != ActionOwner.NONE:
		return false
	
	if p_action_state == PlayerActionState.REVIVE:
		return false
	
	if p_action_state == PlayerActionState.DEAD:
		return false
	
	return true

func can_control_movement() -> bool:
	match action_owner:
		ActionOwner.NONE:
			return true
		ActionOwner.WEB_ATTACK:
			return true
		ActionOwner.SKILL_1, ActionOwner.SKILL_2:
			return true
		_:
			return false

#endregion


#region Animation Wait Helpers

func wait_for_animation_or_timeout(anim_node: Node, timeout: float) -> void:
	var elapsed := 0.0
	
	while elapsed < timeout:
		await get_tree().process_frame
		
		if not is_instance_valid(self):
			return
		
		elapsed += get_process_delta_time()
		
		if anim_node is AnimatedSprite2D:
			if not anim_node.is_playing():
				return
		
		elif anim_node is AnimationPlayer:
			if not anim_node.is_playing():
				return
		
		else:
			return

func play_current_form_animation(anim_name: StringName, force_restart := true) -> void:
	if p_form_state == PlayerFormState.HUMAN_FORM:
		play_anim(p_sprite, anim_name, force_restart)
	else:
		play_anim(s_sprite, anim_name, force_restart)

func wait_current_form_animation_or_timeout(timeout: float) -> void:
	if p_form_state == PlayerFormState.HUMAN_FORM:
		await wait_for_animation_or_timeout(p_sprite, timeout)
	else:
		await wait_for_animation_or_timeout(s_sprite, timeout)

#endregion


#region Input

func read_action_input() -> void:
	if Input.is_action_just_pressed("attack") \
	and action_owner == ActionOwner.HUMAN_ATTACK:
		if attack_window_open and combo_seq < MAX_COMBO:
			combo_input_queued = true
		return
	
	if not can_start_normal_action():
		return
	
	if Input.is_action_just_pressed("dash"):
		start_dash()
		return
	
	if Input.is_action_just_pressed("block"):
		start_blocking()
		return
	
	if Input.is_action_just_pressed("attack"):
		if p_form_state == PlayerFormState.HUMAN_FORM:
			start_human_attack()
		else:
			start_web_attack()
		return
	
	if Input.is_action_just_pressed("skill_one"):
		start_skill_one()
		return
	
	if Input.is_action_just_pressed("skill_two"):
		start_skill_two()
		return

#endregion


#region Movement

func update_controlled_movement() -> void:
	if GameManager.game_scene_state == GameManager.GameLevelStates.BOSS_ROOM \
	and GameManager.can_start_boss_fight == false:
		velocity.x = 0.0
		return
	
	if action_owner == ActionOwner.DASH:
		velocity.x = facing_dir * dash_speed
		return
	
	if not can_control_movement():
		velocity.x = 0.0
		return
	
	if is_on_floor():
		is_on_air = false
	
	p_direction = Input.get_axis("left", "right")
	velocity.x = p_direction * p_speed
	
	if p_direction != 0 and is_on_floor():
		AudioManager.play_music(PLAYER_WALKING, "persistent", 1.0)
	
	if p_direction == 0 and AudioManager.persistent_sfx_player.is_playing():
		AudioManager.stop_music("persistent")
	
	if velocity.x > 0.0:
		facing_dir = 1
	elif velocity.x < 0.0:
		facing_dir = -1
	
	if p_direction != 0:
		if p_form_state == PlayerFormState.HUMAN_FORM:
			p_sprite.flip_h = p_direction < 0
		else:
			s_sprite.flip_h = p_direction < 0
		
		magic_ball_marker.position.x = m_ball_marker_base_x * p_direction

func player_jump() -> void:
	if not can_start_normal_action():
		return
	
	if is_hurt:
		return
	
	if not is_on_floor():
		return
	
	if is_in_flatform:
		return
	
	if Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

func in_flatform() -> void:
	is_in_flatform = true

func not_in_flatform() -> void:
	is_in_flatform = false

func handle_air_state() -> void:
	if not is_on_floor():
		is_on_air = true

func handle_floor_state() -> void:
	if is_on_floor():
		has_dashed_mid_air = false
		has_attk_mid_air = false

func apply_gravity(delta: float) -> void:
	if is_on_floor():
		return
	
	if action_owner == ActionOwner.DASH and not is_on_floor():
		velocity.y = 0.0
		return
	
	var current_gravity: float
	
	if velocity.y < 0.0:
		current_gravity = jump_gravity
	else:
		current_gravity = fall_gravity
	
	if abs(velocity.y) < apex_threshold:
		current_gravity *= apex_gravity_multiplier
	
	velocity.y += current_gravity * delta
	velocity.y = min(velocity.y, max_fall_speed)

func is_air_dashing() -> bool:
	return action_owner == ActionOwner.DASH and not is_on_floor()

func has_dashed_midair() -> bool:
	if not is_on_floor() and action_owner == ActionOwner.DASH:
		has_dashed_mid_air = true
	
	return has_dashed_mid_air

#endregion


#region Dash

func start_dash() -> void:
	if has_dashed_mid_air:
		return
	
	if not can_dash:
		return
	
	var my_id := begin_action(ActionOwner.DASH, PlayerActionState.NONE)
	if my_id == -1:
		return
	
	can_dash = false
	hurt_box_col.set_deferred("disabled", true)
	velocity.x = facing_dir * dash_speed
	dash_timer = dash_duration
	
	AudioManager.play_music(SWOSH_WHOOSH_AIR_CUT, "oneshot", -10.0)
	play_anim(anim_player, "dashing", true)
	
	await get_tree().create_timer(dash_duration).timeout
	
	if not is_current_action(my_id, ActionOwner.DASH):
		return
	
	cleanup_dash()
	action_owner = ActionOwner.NONE
	p_action_state = PlayerActionState.NONE
	sync_legacy_flags()
	
	force_move_animation()

func cleanup_dash() -> void:
	hurt_box_col.set_deferred("disabled", false)
	can_dash = true
	dash_timer = 0.0
	
	if not is_on_floor():
		has_dashed_mid_air = true

#endregion


#region Block

func start_blocking() -> void:
	if p_form_state != PlayerFormState.HUMAN_FORM:
		return
	
	if not is_on_floor():
		return
	
	var my_id := begin_action(ActionOwner.BLOCK, PlayerActionState.BLOCKING)
	if my_id == -1:
		return
	
	AudioManager.play_music(WHEW, "voice", -10.0)
	play_anim(p_sprite, "block", true)
	p_sprite.sprite_frames.set_animation_loop("block", true)

func _on_block_connect() -> void:
	if action_owner != ActionOwner.BLOCK:
		return
	
	hurt_box_col.set_deferred("disabled", true)

func end_blocking_state() -> void:
	if action_owner != ActionOwner.BLOCK:
		return
	
	cleanup_block()
	action_owner = ActionOwner.NONE
	p_action_state = PlayerActionState.NONE
	sync_legacy_flags()
	
	force_move_animation()

func cleanup_block() -> void:
	if p_sprite.is_playing() and p_sprite.animation == "block":
		p_sprite.sprite_frames.set_animation_loop("block", false)
		p_sprite.stop()
	
	hurt_box_col.set_deferred("disabled", false)

#endregion


#region Human Attack

func start_human_attack() -> void:
	if has_attk_mid_air:
		return
	
	var my_id := begin_action(ActionOwner.HUMAN_ATTACK, PlayerActionState.ATTACK)
	if my_id == -1:
		return
	
	AudioManager.play_music(SWOSH_WHOOSH_AIR_CUT, "oneshot", -10.0)
	
	combo_seq = 1
	combo_input_queued = false
	attack_window_open = true
	attk_c_timer = stats.attk_combo_timer
	mace_hit_box.set_deferred("disabled", false)
	
	while true:
		if not is_current_action(my_id, ActionOwner.HUMAN_ATTACK):
			return
		
		if combo_seq == 1:
			p_action_state = PlayerActionState.ATTACK
			play_anim(p_sprite, "attk_combo_1", true)
		else:
			p_action_state = PlayerActionState.COMBO_ATTACK
			play_anim(p_sprite, "attk_combo_2", true)
		
		await wait_for_animation_or_timeout(p_sprite, 0.75)
		
		if not is_current_action(my_id, ActionOwner.HUMAN_ATTACK):
			return
		
		if not is_on_floor():
			has_attk_mid_air = true
		
		if combo_input_queued and combo_seq < MAX_COMBO:
			combo_seq += 1
			combo_input_queued = false
			attack_window_open = true
			attk_c_timer = stats.attk_combo_timer
			continue
		
		break
	
	finish_action(my_id, ActionOwner.HUMAN_ATTACK)

func cleanup_human_attack() -> void:
	mace_hit_box.set_deferred("disabled", true)
	combo_input_queued = false
	attack_window_open = false
	combo_seq = 0
	attk_c_timer = 0.0
	reset_hit_box_pos()

func open_attack_window() -> void:
	attack_window_open = true

func close_attack_window() -> void:
	attack_window_open = false

func end_combo() -> void:
	if action_owner != ActionOwner.HUMAN_ATTACK:
		return
	
	cleanup_human_attack()
	action_owner = ActionOwner.NONE
	p_action_state = PlayerActionState.NONE
	sync_legacy_flags()
	
	consume_queued_form_change()
	force_move_animation()

#endregion


#region Web Attack

func start_web_attack() -> void:
	var my_id := begin_action(ActionOwner.WEB_ATTACK, PlayerActionState.ATTACK)
	if my_id == -1:
		return
	
	play_anim(s_sprite, "attack", true)
	
	var target := find_nearest_web_target()
	if target == null:
		finish_action(my_id, ActionOwner.WEB_ATTACK)
		return
	
	web_markers_parent.global_position = target.global_position
	start_web_sequence_from_marker_parent(web_markers_parent)
	
	await get_tree().create_timer(WEB_ATTACK_LOCK_TIME).timeout
	
	if not is_current_action(my_id, ActionOwner.WEB_ATTACK):
		return
	
	finish_action(my_id, ActionOwner.WEB_ATTACK)

func find_nearest_web_target() -> Node2D:
	var targets = get_tree().get_nodes_in_group("Enemy_target")
	
	var closest_target: Node2D = null
	var closest_distance := INF
	
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
	
	return closest_target

func start_web_sequence_from_marker_parent(marker_parent: Node2D) -> void:
	web_marker_queue = marker_parent.get_children()
	current_web_index = 0
	current_web_count = 0
	is_web_sequence_active = true
	web_attk_timer = 0.0

func update_web_sequence(delta: float) -> void:
	if action_owner != ActionOwner.WEB_ATTACK:
		return
	
	if not is_web_sequence_active:
		return
	
	web_attk_timer = set_timer(web_attk_timer, delta)
	
	if web_attk_timer > 0.0:
		return
	
	if current_web_index >= web_marker_queue.size():
		is_web_sequence_active = false
		return
	
	var marker := web_marker_queue[current_web_index] as Node2D
	current_web_index += 1
	
	spawn_web_ray(marker)
	web_attk_timer = WEB_DELAY

func spawn_web_ray(marker: Node2D) -> void:
	if marker == null:
		return
	
	var web_ray_scene = WEB_ATTACK.instantiate()
	web_ray_scene.global_position = marker.global_position
	web_ray_scene.scale = Vector2(1.0, 1.0)
	web_ray_scene.global_rotation = marker.global_rotation
	web_ray_scene.z_index = 10 - current_web_count
	
	var parent_node := get_projectile_parent()
	parent_node.add_child(web_ray_scene)
	
	current_web_count += 1

func cleanup_web_attack() -> void:
	is_web_sequence_active = false
	web_marker_queue.clear()
	current_web_index = 0
	current_web_count = 0
	web_attk_timer = 0.0

func end_web_combo() -> void:

	if action_owner != ActionOwner.WEB_ATTACK:
		return
	
	var saved_id := action_id
	finish_action(saved_id, ActionOwner.WEB_ATTACK)

#endregion


#region Skills

func start_skill_one() -> void:
	if not can_skill:
		return
	
	var my_id := begin_action(ActionOwner.SKILL_1, PlayerActionState.SKILL_ONE)
	if my_id == -1:
		return
	
	AudioManager.play_music(skill_sfx, "voice", -10.0)
	open_and_update_text("Raaa", "Oraa")
	
	var target := find_nearest_skill_target()
	if target == null:
		finish_action(my_id, ActionOwner.SKILL_1)
		return
	
	can_skill = false
	
	var light_ray_scene = LIGHT_RAY.instantiate()
	var y_offset = light_ray_scene.h_offset
	
	light_ray_scene.global_position = Vector2(
		target.global_position.x,
		target.global_position.y - y_offset
	)
	light_ray_scene.scale = Vector2(2.5, 1.0)
	
	get_projectile_parent().add_child(light_ray_scene)
	
	if light_ray_scene.has_signal("light_ray_done"):
		light_ray_scene.light_ray_done.connect(func():
			end_skill_if_current(my_id, ActionOwner.SKILL_1)
		, CONNECT_ONE_SHOT)
	
	await get_tree().create_timer(1.0).timeout
	
	if is_current_action(my_id, ActionOwner.SKILL_1):
		end_skill_if_current(my_id, ActionOwner.SKILL_1)

func start_skill_two() -> void:
	if not can_skill:
		return
	
	var my_id := begin_action(ActionOwner.SKILL_2, PlayerActionState.SKILL_TWO)
	if my_id == -1:
		return
	
	AudioManager.play_music(skill_sfx, "voice", -10.0)
	open_and_update_text("Raaa", "Oraa")
	
	can_skill = false
	
	var signed_dir := Vector2.RIGHT
	if facing_dir == -1:
		signed_dir = Vector2.LEFT
	
	var magic_ball_scene = MAGIC_BALL.instantiate()
	magic_ball_scene.dir = signed_dir
	magic_ball_scene.global_position = magic_ball_marker.global_position
	magic_ball_scene.marker_target = magic_ball_marker
	magic_ball_scene.scale = Vector2(2.5, 2.5)
	
	get_projectile_parent().add_child(magic_ball_scene)
	
	if magic_ball_scene.has_signal("launched_done"):
		magic_ball_scene.launched_done.connect(func():
			end_skill_if_current(my_id, ActionOwner.SKILL_2)
		, CONNECT_ONE_SHOT)
	
	await get_tree().create_timer(1.0).timeout
	
	if is_current_action(my_id, ActionOwner.SKILL_2):
		end_skill_if_current(my_id, ActionOwner.SKILL_2)

func find_nearest_skill_target() -> Node2D:
	var targets: Array
	
	if GameManager.can_start_boss_fight:
		targets = get_tree().get_nodes_in_group("Boss_target")
	else:
		targets = get_tree().get_nodes_in_group("Enemy_target")
	
	var closest_target: Node2D = null
	var closest_distance := INF
	
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
	
	return closest_target

func end_skill_if_current(my_id: int, expected_owner: ActionOwner) -> void:
	if not is_current_action(my_id, expected_owner):
		return
	
	finish_action(my_id, expected_owner)

func end_skill() -> void:
	if action_owner == ActionOwner.SKILL_1:
		end_skill_if_current(action_id, ActionOwner.SKILL_1)
	elif action_owner == ActionOwner.SKILL_2:
		end_skill_if_current(action_id, ActionOwner.SKILL_2)

func cleanup_skill() -> void:
	can_skill = true

#endregion


#region Rage / Transform

func accumulate_rage() -> void:
	if p_form_state == PlayerFormState.SPIDER_FORM:
		return
	
	if is_raging:
		return
	
	if p_action_state == PlayerActionState.RAGE_TRANSFORM:
		return
	
	if r_amount < MAX_RAGE:
		r_amount += r_per_attk
	
	if r_amount >= MAX_RAGE:
		request_form_change(PlayerFormState.SPIDER_FORM)

func update_rage_logic(delta: float) -> void:
	if p_form_state == PlayerFormState.HUMAN_FORM:
		if r_amount >= MAX_RAGE:
			request_form_change(PlayerFormState.SPIDER_FORM)
		return
	
	if p_form_state != PlayerFormState.SPIDER_FORM:
		return
	
	if is_raging:
		r_timer = set_timer(r_timer, delta)
		
		if r_timer <= 0.0:
			is_raging = false
			is_rage_cooling = true
			r_cd_timer = stats.rage_cd_timer
	
	if is_rage_cooling:
		r_cd_timer = set_timer(r_cd_timer, delta)
		r_amount = max(r_amount - 20.0 * delta, 0.0)
		
		if r_cd_timer <= 0.0:
			request_form_change(PlayerFormState.HUMAN_FORM)

func request_form_change(target_form: int) -> void:
	if p_health <= 0.0:
		return
	
	if p_form_state == target_form:
		return
	
	if action_owner != ActionOwner.NONE:
		queued_form_change = target_form
		transformation_queued = true
		return
	
	if target_form == PlayerFormState.SPIDER_FORM:
		start_transform_to_spider()
	elif target_form == PlayerFormState.HUMAN_FORM:
		start_transform_to_human()

func consume_queued_form_change() -> void:
	if queued_form_change == QUEUE_NONE:
		transformation_queued = false
		return
	
	if action_owner != ActionOwner.NONE:
		return
	
	var target_form := queued_form_change
	queued_form_change = QUEUE_NONE
	transformation_queued = false
	
	if target_form == PlayerFormState.SPIDER_FORM:
		start_transform_to_spider()
	elif target_form == PlayerFormState.HUMAN_FORM:
		start_transform_to_human()

func start_transform_to_spider() -> void:
	var my_id := begin_action(ActionOwner.TRANSFORM_TO_SPIDER, PlayerActionState.RAGE_TRANSFORM, true)
	if my_id == -1:
		return
	
	is_invulnerable = true
	
	open_and_update_text("OMAEE", "YABAっ")
	AudioManager.play_music(rage_sfx, "voice", 1.0)
	
	anim_player.play("rage_transform")
	await wait_for_animation_or_timeout(anim_player, 1.2)
	
	if not is_current_action(my_id, ActionOwner.TRANSFORM_TO_SPIDER):
		return
	
	p_form_state = PlayerFormState.SPIDER_FORM
	is_raging = true
	is_rage_cooling = false
	is_invulnerable = false
	r_timer = stats.rage_timer
	
	finish_action(my_id, ActionOwner.TRANSFORM_TO_SPIDER)

func start_transform_to_human() -> void:
	var my_id := begin_action(ActionOwner.TRANSFORM_TO_HUMAN, PlayerActionState.RAGE_TRANSFORM, true)
	if my_id == -1:
		return
	
	is_invulnerable = true
	
	anim_player.play("to_human_transform")
	await wait_for_animation_or_timeout(anim_player, 1.2)
	
	if not is_current_action(my_id, ActionOwner.TRANSFORM_TO_HUMAN):
		return
	
	p_form_state = PlayerFormState.HUMAN_FORM
	is_raging = false
	is_rage_cooling = false
	is_invulnerable = false
	r_amount = 0.0
	r_timer = 0.0
	r_cd_timer = 0.0
	
	finish_action(my_id, ActionOwner.TRANSFORM_TO_HUMAN)

func cleanup_transform() -> void:
	is_transforming = false

#endregion


#region Hurt / Death / Revive

func handle_hurt(damage: float) -> void:
	if is_invulnerable:
		return
	
	if action_owner == ActionOwner.DEAD:
		return
	
	start_hurt(damage)

func start_hurt(damage: float) -> void:
	var my_id := begin_action(ActionOwner.HURT, PlayerActionState.HURT, true)
	if my_id == -1:
		return
	
	open_and_update_text("MUUU", "YABAっ")
	AudioManager.play_music(SFX_AGH, "voice", -10.0)
	
	is_invulnerable = true
	invulnerable_timer = stats.invul_timer
	
	if p_health > 0.0:
		p_health -= damage
	
	if p_form_state == PlayerFormState.HUMAN_FORM:
		play_anim(p_sprite, "hurt", true)
		await wait_for_animation_or_timeout(p_sprite, 0.55)
	else:
		play_anim(s_sprite, "hurt", true)
		await wait_for_animation_or_timeout(s_sprite, 0.55)
	
	if not is_current_action(my_id, ActionOwner.HURT):
		return
	
	finish_action(my_id, ActionOwner.HURT)

func cleanup_hurt() -> void:
	velocity.x = 0.0

func end_hurt() -> void:
	if action_owner != ActionOwner.HURT:
		return
	
	finish_action(action_id, ActionOwner.HURT)

func handle_death() -> void:
	if p_health > 0.0:
		return
	
	if action_owner == ActionOwner.DEAD:
		return
	
	if action_owner == ActionOwner.REVIVE:
		return
		
	start_death()

func start_death() -> void:
	var my_id := begin_action(ActionOwner.DEAD, PlayerActionState.DEAD, true)
	if my_id == -1:
		return
	
	is_invulnerable = true
	velocity = Vector2.ZERO
	
	if p_form_state == PlayerFormState.SPIDER_FORM and s_sprite.sprite_frames.has_animation("death"):

		play_anim(s_sprite, "death", true)
		await wait_for_animation_or_timeout(s_sprite, 0.5)
	else:
		p_form_state = PlayerFormState.HUMAN_FORM
		play_anim(p_sprite, "death", true)
		await wait_for_animation_or_timeout(p_sprite, 0.5)
	
	if not is_current_action(my_id, ActionOwner.DEAD):
		return
	
	if GameManager.is_immortal:
		handle_revive()
	else:
		death()

func cleanup_death() -> void:
	velocity = Vector2.ZERO

func handle_revive() -> void:
	if action_owner == ActionOwner.REVIVE:
		return

	if action_owner != ActionOwner.DEAD:
		return
	
	if not GameManager.is_immortal:
		return
	
	start_revive()

func start_revive() -> void:
	var my_id := begin_action(ActionOwner.REVIVE, PlayerActionState.REVIVE, true)
	if my_id == -1:
		return
	
	p_form_state = PlayerFormState.HUMAN_FORM
	
	play_anim(p_sprite, "revive", true)
	summon_michael(MICHAEL)
	
	await get_tree().process_frame
	get_tree().paused = true
	
	# Explicit pause-safe failsafe.
	await get_tree().create_timer(3.0, true, false, true).timeout
	
	if is_current_action(my_id, ActionOwner.REVIVE):
		print("Revive failsafe triggered")
		finish_revive()


func summon_michael(scene: PackedScene) -> void:
	if michael_summoned:
		return
	
	var mic_scene = scene.instantiate()
	mic_scene.process_mode = Node.PROCESS_MODE_ALWAYS
	mic_scene.captured_pos = michael_marker.global_position
	
	get_tree().current_scene.add_child(mic_scene)
	michael_summoned = true


func unpause_after_revive() -> void:
	print_debug("ever made it here?")
	if action_owner != ActionOwner.REVIVE:
		return
	
	finish_revive()


func finish_revive() -> void:
	if revive_finishing:
		return
	
	revive_finishing = true
	
	get_tree().paused = false
	
	p_health = stats.player_health
	r_amount = 0.0
	r_timer = 0.0
	r_cd_timer = 0.0
	
	is_raging = false
	is_rage_cooling = false
	is_invulnerable = false
	queued_form_change = QUEUE_NONE
	transformation_queued = false
	
	michael_summoned = false
	
	action_owner = ActionOwner.NONE
	p_action_state = PlayerActionState.NONE
	sync_legacy_flags()
	
	force_move_animation()

func adjust_health_and_state() -> void:
	finish_revive()


#endregion


#region Hitbox

func hit() -> int:
	return p_damage

func handle_hitbox_pos() -> void:
	if action_owner != ActionOwner.HUMAN_ATTACK:
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
				pass_hitbox_values(10.0, 30.0, Vector2.ZERO, 0.0, true)

func pass_hitbox_values(radius: float, height: float, pos: Vector2, rot: float, change_rot: bool) -> void:
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
	mace_hit_box.position = Vector2.ZERO
	mace_hit_box.rotation = 0.0

#endregion


#region Move State / Animation

func change_move_state(new_state: PlayerMoveState) -> void:
	if p_action_state == PlayerActionState.DEAD:
		return
	
	if action_owner == ActionOwner.HUMAN_ATTACK:
		return
	
	if p_move_state == new_state:
		return
	
	p_move_state = new_state
	
	if p_form_state == PlayerFormState.HUMAN_FORM:
		match_form_movement(p_move_state, p_sprite, "jump", "walk", "idle")
	else:
		match_form_movement(p_move_state, s_sprite, "jump", "walk", "idle")

func match_form_movement(
	f_state: PlayerBase.PlayerMoveState,
	sprt: AnimatedSprite2D,
	jump: StringName,
	walk: StringName,
	idle: StringName
) -> void:
	if p_action_state == PlayerActionState.DEAD:
		return
	
	if action_owner != ActionOwner.NONE \
	and action_owner != ActionOwner.WEB_ATTACK \
	and action_owner != ActionOwner.SKILL_1 \
	and action_owner != ActionOwner.SKILL_2:
		return
	
	match f_state:
		PlayerMoveState.JUMP:
			play_anim(sprt, jump)
		PlayerMoveState.RUN:
			play_anim(sprt, walk)
		PlayerMoveState.IDLE:
			play_anim(sprt, idle)

func update_move_state() -> void:
	if p_action_state == PlayerActionState.DEAD:
		return
	
	if action_owner != ActionOwner.NONE \
	and action_owner != ActionOwner.WEB_ATTACK \
	and action_owner != ActionOwner.SKILL_1 \
	and action_owner != ActionOwner.SKILL_2:
		return
	
	if not is_on_floor():
		change_move_state(PlayerMoveState.JUMP)
	elif abs(velocity.x) > 0.1:
		change_move_state(PlayerMoveState.RUN)
	else:
		change_move_state(PlayerMoveState.IDLE)

func force_move_animation() -> void:
	if action_owner != ActionOwner.NONE:
		return
	
	var input_dir := Input.get_axis("left", "right")
	
	if not is_on_floor():
		if p_form_state == PlayerFormState.HUMAN_FORM:
			play_anim(p_sprite, "jump")
		else:
			play_anim(s_sprite, "jump")
	elif abs(input_dir) > 0.1:
		if p_form_state == PlayerFormState.HUMAN_FORM:
			play_anim(p_sprite, "walk")
		else:
			play_anim(s_sprite, "walk")
	else:
		p_move_state = PlayerMoveState.IDLE
		
		if p_form_state == PlayerFormState.HUMAN_FORM:
			play_anim(p_sprite, "idle")
		else:
			play_anim(s_sprite, "idle")

#endregion


#region Timers

func reduce_timer(delta: float) -> void:
	attk_c_timer = set_timer(attk_c_timer, delta)
	if attk_c_timer <= 0.0:
		close_attack_window()
	
	invulnerable_timer = set_timer(invulnerable_timer, delta)
	if invulnerable_timer <= 0.0:
		if action_owner != ActionOwner.TRANSFORM_TO_SPIDER \
		and action_owner != ActionOwner.TRANSFORM_TO_HUMAN \
		and action_owner != ActionOwner.DEAD \
		and action_owner != ActionOwner.REVIVE:
			is_invulnerable = false
	
	s1_timer = set_timer(s1_timer, delta)
	s2_timer = set_timer(s2_timer, delta)

#endregion


#region Area2D Related

func _on_hit_box_area_entered(area: Area2D) -> void:
	var from_area = area.get_tree().get_first_node_in_group("Enemy_target")
	
	if from_area:
		accumulate_rage()

#endregion


#region Old Animation Signal Compatibility

func _on_main_sprite_animation_finished() -> void:

	if p_sprite.animation == "revive":
		print("animation ever finished?")
		adjust_health_and_state()

func _on_spider_sprite_animation_finished() -> void:
	pass

#endregion


#region Utility

func get_projectile_parent() -> Node:
	var scene := get_tree().current_scene
	
	if scene and scene.has_node("Projectiles"):
		return scene.get_node("Projectiles")
	
	return scene

func print_default(message: String, object: Variant) -> void:
	print("%s , %s" % [message, object])

func print_debug_with_timestamp(message: String, object: Variant) -> void:
	var time_ms = Time.get_ticks_msec()
	var frame = Engine.get_process_frames()
	print("[%s | Frame %d] %s %s" % [time_ms, frame, message, object])

func print_debug_state() -> void:
	print("------ PLAYER DEBUG ------")
	print("action_owner: ", ActionOwner.keys()[action_owner])
	print("action_id: ", action_id)
	print("p_action_state: ", PlayerBase.PlayerActionState.keys()[p_action_state])
	print("p_form_state: ", PlayerBase.PlayerFormState.keys()[p_form_state])
	print("input_available: ", input_available)
	print("is_busy: ", is_busy)
	print("is_attacking: ", is_attacking)
	print("is_hurt: ", is_hurt)
	print("is_blocking: ", is_blocking)
	print("is_dashing: ", is_dashing)
	print("is_skilling: ", is_skilling)
	print("is_transforming: ", is_transforming)
	print("is_invulnerable: ", is_invulnerable)
	print("is_raging: ", is_raging)
	print("is_rage_cooling: ", is_rage_cooling)
	print("r_amount: ", r_amount)
	print("r_timer: ", r_timer)
	print("r_cd_timer: ", r_cd_timer)
	print("queued_form_change: ", queued_form_change)
	print("transformation_queued: ", transformation_queued)
	print("--------------------------")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		print_debug_state()

#endregion
