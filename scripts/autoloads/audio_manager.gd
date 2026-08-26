extends Node2D

@onready var bgm_player: AudioStreamPlayer = $BGMPlayer
@onready var persistent_sfx_player: AudioStreamPlayer = $PersistentSFXPlayer
@onready var skill_sfx_player: AudioStreamPlayer = $SkillSFXPlayer
@onready var voice_sfx_player: AudioStreamPlayer = $VoiceSFXPlayer
@onready var one_shot_sfx_player: AudioStreamPlayer = $OneShotSFXPlayer


var current_bgm_path: String = ""
var current_persistent_sfx_path: String = ""
	
func play_music(path: String, type: String, volume_db: float = 0.0) -> void:
	
	match type:
		"bgm":
			if current_bgm_path == path and bgm_player.playing:
				return
	
			current_bgm_path = path
			
			bgm_sfx_helper(bgm_player, path, "Music", volume_db)
		"skill":
			bgm_sfx_helper(skill_sfx_player, path, "SFX", volume_db)
		"persistent":
			if current_persistent_sfx_path == path and persistent_sfx_player.playing:
				return
	
			
			current_persistent_sfx_path = path
				
			bgm_sfx_helper(persistent_sfx_player, path, "SFX", volume_db)
		"voice":
			bgm_sfx_helper(voice_sfx_player, path, "SFX", volume_db)
		"oneshot":
			bgm_sfx_helper(one_shot_sfx_player, path, "SFX", volume_db)
	
	

func bgm_sfx_helper(m_player: AudioStreamPlayer, m_path: String, bus: String, volume_db: float = 0.0) -> void:
	
	var stream: AudioStream = load(m_path)
	if stream == null:
		push_error("BGM not found: " + m_path)
		return
		
	m_player.stream = stream
	m_player.volume_db = volume_db
	m_player.bus = bus
	m_player.play()

func stop_music(player: String) -> void:
	
	match player:
		"bgm":
			bgm_player.stop()
			current_bgm_path = ""
		"skill":
			skill_sfx_player.stop()
		"persistent":
			persistent_sfx_player.stop()
			current_persistent_sfx_path = ""
		"voice":
			voice_sfx_player.stop()
		"oneshot":
			one_shot_sfx_player.stop()
			

	
func fade_out_bgm(type: String, duration: float = 1.0) -> void:
	var tween := create_tween()
	tween.tween_property(bgm_player, "volume_db", -80.0, duration)
	await tween.finished
	
	stop_music(type)
	

func fade_to_bgm(path: String, type: String, volume_db: float = -6.0, duration: float = 1.0) -> void:
	if current_bgm_path == path:
		return
	
	var tween := create_tween()
	tween.tween_property(bgm_player, "volume_db", -80.0, duration)
	await tween.finished
	
	play_music(path, type, volume_db) 
	
	var fade_in := create_tween()
	fade_in.tween_property(bgm_player, "volume_db", volume_db, duration)
