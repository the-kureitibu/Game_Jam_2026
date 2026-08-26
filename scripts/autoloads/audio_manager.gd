extends Node2D

@onready var bgm_player: AudioStreamPlayer = $BGMPlayer
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer

var current_bgm_path: String = ""
var current_sfx_path: String = ""

func play_bgm(path: String, volume_db: float = 0.0) -> void:
	if current_bgm_path == path and bgm_player.playing:
		return
	
	current_bgm_path = path
	
	var stream: AudioStream = load(path)
	if stream == null:
		push_error("BGM not found: " + path)
		return
	
	bgm_player.stream = stream
	bgm_player.volume_db = volume_db
	bgm_player.bus = "Music"
	bgm_player.play()


func stop_bgm() -> void:
	bgm_player.stop()
	current_bgm_path = ""
	

func stop_sfx() -> void:
	sfx_player.stop()
	current_sfx_path = ""
	

func play_sfx(path: String, volume_db: float = 0.0) -> void:
	if current_sfx_path == path and sfx_player.playing:
		return
	
	current_sfx_path = path
	
	var stream: AudioStream = load(path)
	if stream == null:
		push_error("SFX not found: " + path)
		return
	
	sfx_player.stream = stream
	sfx_player.volume_db = volume_db
	sfx_player.bus = "SFX"
	sfx_player.play()
	
	
func fade_out_bgm(duration: float = 1.0) -> void:
	var tween := create_tween()
	tween.tween_property(bgm_player, "volume_db", -80.0, duration)
	await tween.finished
	stop_bgm()
	

func fade_to_bgm(path: String, volume_db: float = -6.0, duration: float = 1.0) -> void:
	if current_bgm_path == path:
		return
	
	var tween := create_tween()
	tween.tween_property(bgm_player, "volume_db", -80.0, duration)
	await tween.finished
	
	play_bgm(path, -80.0)
	
	var fade_in := create_tween()
	fade_in.tween_property(bgm_player, "volume_db", volume_db, duration)
