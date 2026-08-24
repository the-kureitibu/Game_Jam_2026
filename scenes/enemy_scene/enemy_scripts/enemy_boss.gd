extends EnemyBase


#region Base Variables

var b_health: int = 100
var b_damage: int = 20
var b_speed: float = 60.0
var b_acceleration := 2.5
var slowing_speed := 70.0
	
@onready var jump_height: float = 120.0
@onready var time_to_apex: float = 0.35
@onready var jump_gravity := (2.0 * jump_height) / pow(time_to_apex, 2.0)

#endregion

#region References

@onready var m_sprite: AnimatedSprite2D = $e_sprite
@onready var d_sprite: AnimatedSprite2D = $d_sprite
@onready var s_texture = m_sprite.sprite_frames.get_frame_texture("walk", 0)
@onready var s_height = s_texture.get_height() / - 2.0
@onready var main_col: CollisionShape2D = $MainCol
@onready var hurt_col: CollisionShape2D = $Hurtbox/HurtCol

@onready var c_marker: Marker2D = $ChairMarker
@onready var bf_marker: Marker2D = $BookFMarker
@onready var frontal_s_marker: Marker2D = $FrontalSMarker

@onready var p_anim: AnimationPlayer = $AnimationPlayer

@onready var c_marker_base_x = abs(c_marker.position.x)
@onready var bf_marker_base_x = abs(bf_marker.position.x)
@onready var frontal_s_marker_x = abs(frontal_s_marker.position.x)
@onready var facing_dir: int = 0

signal update_health

@onready var MAX_HEALTH: float = 200.0
@onready var boss_health: float = 10.0: 
	set(value):
		var new_health = value
		
		if boss_health == new_health:
			return
		
		boss_health = clamp(new_health, 0.0, MAX_HEALTH)
		
		update_health.emit(new_health)

const CHAIR_SCENE = preload("res://scenes/projectiles_scene/chair_skill.tscn")
const BOOK_FALL_SCENE = preload("res://scenes/projectiles_scene/book_fall_skill.tscn")
const DIRECTORY_SCENE = preload("res://scenes/projectiles_scene/directory_skill.tscn")
const FRONTAL_SPELL = preload("res://scenes/projectiles_scene/frontal_spell.tscn")


var c_marker_dir: float

#endregion

#region Combo Base Variables

var skill_bag: Array[int] = []
var available_skills: Array[int] = [1, 2, 3]
var available_skills_second_phase: Array[int] = [1, 2, 3, 4]
var available_shots: Array[int] = [1, 2, 3]
var chair_shots_fired := 0
const MAX_CHAIR_SHOTS := 3
const CHAIR_SHOT_INTERVAL := 1.5

var is_recovering: bool = false
var pending_skill := 0


#endregion

#region Signals 
#UI signals
signal send_timers(timer: String, value: float)

#endregion

#region Timers 

@onready var recovery_timer := 0.0:
	set(value):
		var new_value = max(value, 0.0)
		
		if recovery_timer == new_value:
			return
		
		recovery_timer = new_value
		
		send_timers.emit("recover_timer", value)

@onready var chase_timer := 0.0:
	set(value):
		var new_value = max(value, 0.0)
		
		if chase_timer == new_value:
			return
		
		chase_timer = new_value
		send_timers.emit("chase_timer", chase_timer)

@onready var stunned_timer := 0.0:
	set(value):
		var new_value = max(value, 0.0)
		
		if stunned_timer == new_value:
			return
		
		stunned_timer = new_value
		
		send_timers.emit("stunned_timer", value)

@onready var shots_timer := 0.0:
	set(value):
		var new_value = max(value, 0.0)
		
		if shots_timer == new_value:
			return
		
		shots_timer = new_value

@onready var directory_summon_timer := 0.0
@onready var channeling_skill_timer := 0.0
@onready var is_third_skill_running: bool = false

#endregion

#region Gate Keepers
var is_transforming := false
var is_hurt := false
var hurt_count := [] #make boss stunned after 3 hits
var is_flying := false
var is_human := false
var is_demon := false
var is_stunned := false
var is_chasing := false
var is_skilling := false
var is_shooting := false
var is_hurt_ongoing := false

#endregion

#region Skill Arrays and Markers
@onready var spawn_point_1: Marker2D = $Skill3Markers/SpawnPoint1
@onready var spawn_point_2: Marker2D = $Skill3Markers/SpawnPoint2
@onready var spawn_point_3: Marker2D = $Skill3Markers/SpawnPoint3
@onready var spawn_point_4: Marker2D = $Skill3Markers/SpawnPoint4
@onready var spawn_point_5: Marker2D = $Skill3Markers/SpawnPoint5
@onready var spawn_point_6: Marker2D = $Skill3Markers/SpawnPoint6

@onready var skill_3_markers: Array[Marker2D] = [
	spawn_point_1,
	spawn_point_2,
	spawn_point_3,
	spawn_point_4,
	spawn_point_5,
	spawn_point_6
]


#endregion -- Skill Arrays

#region Target
@onready var p_target = get_tree().get_first_node_in_group("Player_target")

var slowing_d_radius := 150.0
var stopping_radius := 70.0
var b_max_speed := 100.0

#endregion

#region States and Vars

@onready var boss_form_state: EnemyBase.EnemyFormState = EnemyFormState.HUMAN_FORM
@onready var boss_state: EnemyBase.BossStates = BossStates.IDLE

#region Phase 2 Stats

@onready var PHASE2_MAX_HEALTH: float = 200.0
@onready var p2_boss_health: float = 0.0: 
	set(value):
		var new_health = value
		
		if p2_boss_health == new_health:
			return
		
		p2_boss_health = clamp(new_health, 0.0, PHASE2_MAX_HEALTH)
		
		update_health.emit(new_health)

var is_phase_two: bool = false
var is_first_death: bool = false

#endregion -- Phase 2 Stats

#endregion -- States and Vars 

func draw_speed_limit() -> void:
	pass

func _enter_tree() -> void:
	p_target = get_tree().get_first_node_in_group("Player_target")

func _ready() -> void:
	if p_target == null:
		push_error("Player does not exist")
	
	find_target()
	
	print("Number of shots ", chair_shots_fired)
	SignalHub.is_needed_flip.connect(flip_to_target)
	SignalHub.start_second_phase.connect(start_phase_two)
	
	if not d_sprite.animation_finished.is_connected(_on_d_sprite_animation_finished):
		d_sprite.animation_finished.connect(_on_d_sprite_animation_finished)
	
func _physics_process(delta: float) -> void:
	if boss_state == BossStates.FIRST_DEATH:
		velocity.x = 0.0
		move_and_slide()
		return
	
	if boss_state == BossStates.TRUE_DEATH:
		velocity.x = 0.0
		move_and_slide()
		return
	
	if !is_phase_two and boss_health <= 0.0:
		if !is_first_death:
			is_first_death = true
			handle_first_death()
	
		velocity.x = 0.0
		move_and_slide()
		return


	if is_phase_two and p2_boss_health <= 0.0:
		#handle_true_death()
		velocity.x = 0.0
		move_and_slide()
		return
	
	if is_hurt:
		velocity.x = 0.0
		handle_anim(boss_state)
		move_and_slide()
		return
	
	handle_boss_logic(delta)
	update_chair_skill(delta)
	update_summon_directory(delta)
	update_recovery(delta)
	
	handle_anim(boss_state)

	move_and_slide()
	
#region Misc

func flip_to_target() -> void:
	var target_dis = p_target.global_position.x - global_position.x
	var signed_dir = sign(target_dis)
	
	if signed_dir != 0:
		d_sprite.flip_h = signed_dir == 1

#endregion -- Misc

#region Movement func

func handle_movement() -> void:
	if (GameManager.game_scene_state == GameManager.GameLevelStates.BOSS_ROOM 
		and GameManager.can_start_boss_fight == false):
		velocity.x = 0.0
		return
	
	if p_target == null:
		return

	var signed_distance = find_target()
	var signed_direction = sign(signed_distance)
	var abs_distance = abs(signed_distance)
	
	chase_target(signed_direction, abs_distance)
	get_m_dis(c_marker)
	

func get_m_dis(marker: Marker2D) -> void:
	
	var marker_dis = marker.global_position.x - global_position.x
	var signed_dir = sign(marker_dis)
	
	pass_marker_dir(signed_dir)

func pass_marker_dir(s_dir: int) -> void:
	if s_dir == 1:
		c_marker_dir = 1
	elif s_dir == -1:
		c_marker_dir = -1
	else:
		print("value is zero")
	
	
#endregion

#region Animations 

func get_active_sprite() -> AnimatedSprite2D:
	if is_phase_two:
		return d_sprite
	return m_sprite


func play_boss_anim(anim_name: StringName, force: bool = false) -> void:
	var active_sprite := get_active_sprite()
	
	if force:
		active_sprite.play(anim_name)
		return
	
	if active_sprite.animation == anim_name and active_sprite.is_playing():
		return
	
	active_sprite.play(anim_name)
	


func handle_anim(state: EnemyBase.BossStates) -> void:

	match state:
		BossStates.IDLE:
			play_boss_anim("idle")

		BossStates.CHASING:
			play_boss_anim("walk")

		BossStates.SKILLING:
			play_boss_anim("skill")
		
		BossStates.CHASE_ATTACK:
			play_boss_anim("attk_one")
	
		#BossStates.FIRST_DEATH:
			#play_boss_anim("death", true)

		BossStates.HURT:
			pass



#endregion -- Animations


#region Target related func 


func chase_target(dir: float, abs_dis: float) -> void:

	if (GameManager.game_scene_state == GameManager.GameLevelStates.BOSS_ROOM 
		and GameManager.can_start_boss_fight == false):
		velocity.x = 0.0
		return
	
	if is_hurt:
		return
	
	if is_skilling:
		return

	boss_state = BossStates.CHASING
	
	
	var current_speed: float
	
	if abs_dis <= stopping_radius:
		
		current_speed = 0
		velocity.x = current_speed

	elif abs_dis < slowing_d_radius:
		velocity.x = dir * slowing_speed
		
	else:
		current_speed = b_speed * b_acceleration
		velocity.x = dir * current_speed

	
func find_target() -> float:
	if p_target == null:
		push_error("Player does not Exist")
	
	var target_dis = p_target.global_position.x - global_position.x

	return target_dis
#endregion


#region Boss Logic

func handle_boss_logic(delta: float) -> void:
	if (GameManager.game_scene_state == GameManager.GameLevelStates.BOSS_ROOM 
		and GameManager.can_start_boss_fight == false):
		velocity.x = 0.0
		return
	
	var signed_distance = find_target()
	var signed_direction = sign(int(signed_distance))
	var abs_distance = abs(signed_distance)
	
	if signed_direction != 0:
		var boss_facing_dir = signed_direction
		facing_dir = signed_direction
		
		if boss_form_state == EnemyFormState.HUMAN_FORM:
			m_sprite.flip_h = signed_direction == 1
		else:
			d_sprite.flip_h = signed_direction == 1
		
		c_marker.position.x = c_marker_base_x * boss_facing_dir
		bf_marker.position.x = bf_marker_base_x * boss_facing_dir
		frontal_s_marker.position.x = frontal_s_marker_x * boss_facing_dir

	if is_skilling:
		velocity.x = 0
		return
	
	if is_shooting:
		velocity.x = 0
		return
	
	if is_recovering:
		handle_movement()
		return
	
	
	if chase_timer > 0.0:
		chase_timer = set_timer(chase_timer, delta)
		handle_movement()
		return
	
	if pending_skill == 0:
		pending_skill = get_next_skill()
	
	if skill_needs_range(pending_skill) and abs_distance > stopping_radius:
		handle_movement()
		return
	
	
	var skill_to_start = pending_skill
	
	pending_skill = 0
	start_skill(skill_to_start)
	

#endregion


#region Skills

#region Chase Attack Skill

func frontal_spell(scene: PackedScene, pos: Vector2, direct: int) -> void:
	is_skilling = true
	
	boss_state = BossStates.CHASE_ATTACK
	
	var spell_scene = scene.instantiate()
	spell_scene.target_pos = pos
	#spell_scene.dir = direct
	
	var spell_parent = get_tree().current_scene.get_node("Projectiles")
	spell_parent.add_child(spell_scene)
	

#endregion -- Chase Attack Skill

#region Fall Book Skill

func fall_book(scene: PackedScene, pos: Vector2) -> void:

	is_skilling = true
	
	var book_scene = scene.instantiate()

	book_scene.global_position = pos
	
	var book_parent = get_tree().current_scene.get_node("Projectiles")
	book_parent.add_child(book_scene)
	
	if book_scene.is_inside_tree():
		book_scene.anim_done.connect(end_skill)
		print("Books scene connected?: ", book_scene.anim_done.is_connected(end_skill))

#endregion -- Fall Book Skill

#region Chair Skill

func start_chair_skill() -> void:

	is_skilling = true
	is_shooting = true
	chair_shots_fired = 0
	shots_timer = 0.0

func update_chair_skill(delta) -> void:
	
	if !is_shooting:
		return
	
	shots_timer = set_timer(shots_timer, delta)
	
	if shots_timer > 0.0:
		return

	launch_chair(CHAIR_SCENE, c_marker.global_position, c_marker_dir)
	chair_shots_fired += 1

	if chair_shots_fired >= MAX_CHAIR_SHOTS:
		end_skill()
	else: 
		shots_timer = CHAIR_SHOT_INTERVAL

	
func launch_chair(scene: PackedScene, pos: Vector2, direction: int) -> void:
	is_skilling = true
	is_shooting = true
	
	var chair_scene = scene.instantiate()
	chair_scene.global_position = pos
	chair_scene.marker_dir = direction
	
	var projectile_parent = get_tree().current_scene.get_node("Projectiles")
	
	projectile_parent.add_child(chair_scene)

	print(" I throw chair")
	shots_timer = 1.5
	print("Shots timer refilled? ", shots_timer)
	

#endregion -- Chair Skill

#region Summon Directories Skill


func handle_directory_skill() -> void:
	is_skilling = true
	is_third_skill_running = true
	channeling_skill_timer = 5.0

func start_summon_directory(scene: PackedScene) -> void:
	
	var random_marker = skill_3_markers.pick_random()

	var directory_scene = scene.instantiate()
	directory_scene.marker_pos = random_marker.global_position
	
	var parent_scene = get_tree().current_scene
	var target_node = parent_scene.get_node("Projectiles")
	target_node.add_child(directory_scene)
	
	directory_summon_timer = 0.3

func update_summon_directory(delta: float) -> void:
	if !is_third_skill_running:
		return
	
	if directory_summon_timer > 0.0:
		directory_summon_timer -= delta
		
	if channeling_skill_timer > 0.0:
		channeling_skill_timer -= delta
	
	if channeling_skill_timer > 0.0: #until there's a timer, summon every half a sec
		if directory_summon_timer <= 0.0:
			start_summon_directory(DIRECTORY_SCENE)

	else:
		is_third_skill_running = false
		end_skill()



#endregion -- Summon Directories Skill

#endregion 

#region Handle Skill

func get_next_skill() -> int:
	
	print("BEFORE get_next_skill, bag: ", skill_bag)
	if skill_bag.is_empty():
		print("BAG EMPTY, REFILLING")
		refill_skill_bag()
	
	var skill = skill_bag.pop_front()
	print("PICKED SKILL: ", skill, " | BAG AFTER PICK: ", skill_bag)
	return skill

func refill_skill_bag() -> void:
	if !is_phase_two:
		skill_bag = available_skills.duplicate()
	else:
		skill_bag = available_skills_second_phase.duplicate()
		
	skill_bag.shuffle()

func skill_needs_range(skill_num: int) -> bool:
	return skill_num == 1 or skill_num == 3 or skill_num == 4
	
func start_skill(num: int) -> void:
	
	if is_hurt:
		return
	
	is_skilling = true
	boss_state = BossStates.SKILLING
	
	match num:
		1:
			fall_book(BOOK_FALL_SCENE, bf_marker.global_position)
		2:
			start_chair_skill()
		3:
			handle_directory_skill()
		4:
			frontal_spell(FRONTAL_SPELL, frontal_s_marker.global_position, facing_dir)
		_:
			is_skilling = false
	
	



#endregion




#region Default Signals

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pass

#endregion

#region End Actions

func end_skill() -> void:

	is_skilling = false
	is_shooting = false
	
	print("bag now: ", skill_bag)
	
	if skill_bag.is_empty() and pending_skill == 0:
		start_recovery()
	else:
		chase_timer = 3.0

func start_recovery() -> void:
	boss_state = BossStates.RECOVERY
	
	is_recovering = true
	recovery_timer = 3.0


func update_recovery(delta: float) -> void:
	if not is_recovering:
		return
	
	recovery_timer = set_timer(recovery_timer, delta)
	
	if recovery_timer <= 0.0:
		is_recovering = false
		

#endregion


#region Timers Func

func reduce_timer(delta: float) -> void:

	stunned_timer = set_timer(stunned_timer, delta)
	recovery_timer = set_timer(recovery_timer, delta)
	

#endregion

#region Health Related 

func handle_hurt(damage: float) -> void:
	if is_hurt:
		print("still hurt") #-- this never fired
		return
	
	start_hurt(damage)

func start_hurt(damage: float) -> void:
	
	if boss_state == BossStates.FIRST_DEATH:
		return
	
	if boss_state == BossStates.TRUE_DEATH:
		return
	
	is_hurt = true
	is_skilling = false
	is_shooting = false
	is_third_skill_running = false
	is_recovering = false
	
	pending_skill = 0
	shots_timer = 0.0
	directory_summon_timer = 0.0
	channeling_skill_timer = 0.0
	chair_shots_fired = 0
	
	velocity.x = 0.0
	
	boss_state = BossStates.HURT
	
	if is_phase_two:
		p2_boss_health -= damage
	else:
		boss_health -= damage
		
	play_boss_anim("hurt", true)

func handle_first_death() -> void:
	if boss_state == BossStates.FIRST_DEATH:
		return
	
	boss_state = BossStates.FIRST_DEATH
	play_boss_anim("death")


#func handle_death() -> void:
	#
	#if boss_state == BossStates.FIRST_DEATH:
		#return
	#
	#boss_state = BossStates.FIRST_DEATH
	#SignalHub.ready_for_second_phase.emit()
	##play_anim(m_sprite, "death")
	
#endregion -- Health Related 


#region Phase 2 Related 

func start_phase_two() -> void:
	if !GameManager.can_start_second_phase:
		return

	is_phase_two = true
		
	boss_form_state = EnemyFormState.DEMON_LORD
	boss_state = BossStates.CHASING
	
	is_hurt = false
	is_skilling = false
	is_shooting = false
	is_third_skill_running = false
	is_recovering = false
	
	pending_skill = 0
	skill_bag.clear()
	chase_timer = 1.0
	
	if m_sprite.visible:
		m_sprite.visible = false
	
	if !d_sprite.visible:
		d_sprite.visible = true
	
	p2_boss_health = PHASE2_MAX_HEALTH
	
	print(EnemyBase.BossStates.keys()[boss_state])
	print(EnemyBase.EnemyFormState.keys()[boss_form_state])
	print("is_hurt?: ", is_hurt)
	print("chase_timer?: ", chase_timer)


#endregion -- Phase 2 Related 


#region Area Signals 

func _on_hurtbox_area_entered(area: Area2D) -> void:
	var player_target = area.get_tree().get_first_node_in_group("Player_target")
	var p_projectile = area.get_tree().get_first_node_in_group("player_projectile")
	
	if player_target or p_projectile and "hit" in p_target or p_projectile:
		var p_dmg: float
		
		if player_target:
			p_dmg = player_target.hit()
		if p_projectile:
			p_dmg = p_projectile.hit()
		
		handle_hurt(p_dmg)

#endregion -- Area Signals 


#region Animation Signals 

func _on_e_sprite_animation_finished() -> void:
	
	if boss_form_state == EnemyFormState.HUMAN_FORM:
		if m_sprite.animation == "hurt":
			print("animation finished, human hurt")
			end_hurt()

	if m_sprite.animation == "death":
		end_first_death()
	
func _on_d_sprite_animation_finished() -> void:
	
	if d_sprite.animation == "hurt":
		print("animation finished, demon hurt")
		end_demon_hurt()
	
	if d_sprite.animation == "attk_one":
		end_skill()

	

#endregion -- Animation Signals

#region Animation Ends

func end_hurt() -> void:
	if boss_state == BossStates.FIRST_DEATH:
		return
	
	is_hurt = false
	is_hurt_ongoing = false
	boss_state = BossStates.IDLE
	chase_timer = 1.0

func end_demon_hurt() -> void:
	if boss_state == BossStates.TRUE_DEATH:
		return
	
	is_hurt = false
	is_hurt_ongoing = false
	boss_state = BossStates.IDLE
	chase_timer = 1.0

func end_first_death() -> void:
	boss_state = BossStates.TRANSITION_TO_DEMON
	m_sprite.visible = false
	SignalHub.ready_for_second_phase.emit()
	
#endregion -- Animation Ends
