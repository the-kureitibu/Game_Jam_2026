extends Node2D

#region Parallax Node References 

@onready var parallax_far: Parallax2D = $ParallaxBackground/ParallaxFar
@onready var parallax_mid_far: Parallax2D = $ParallaxBackground/ParallaxMidFar
@onready var parallax_mid: Parallax2D = $ParallaxBackground/ParallaxMid
@onready var parallax_mid_near: Parallax2D = $ParallaxBackground/ParallaxMidNear
@onready var parallax_near: Parallax2D = $ParallaxBackground/ParallaxNear
@onready var parallax_front: Parallax2D = $ParallaxBackground/ParallaxFront

#endregion -- Parallax Node References 

#region Sprite Node References 

@onready var sprite_far: Sprite2D = $ParallaxBackground/ParallaxFar/SpriteFar
@onready var sprite_mid_far: Sprite2D = $ParallaxBackground/ParallaxMidFar/SpriteMidFar
@onready var sprite_mid: Sprite2D = $ParallaxBackground/ParallaxMid/SpriteMid
@onready var sprite_mid_near: Sprite2D = $ParallaxBackground/ParallaxMidNear/SpriteMidNear
@onready var sprite_near: Sprite2D = $ParallaxBackground/ParallaxNear/SpriteNear
@onready var sprite_front: Sprite2D = $ParallaxBackground/ParallaxFront/SpriteFront

#endregion -- Sprite Node References 


#region Grassland References

@onready var CLOUDS: String = "res://assets/sprites/environment/Plains parallax separate layers/Plains parallax separate layers/clouds.png"
@onready var FOREST: String = "res://assets/sprites/environment/Plains parallax separate layers/Plains parallax separate layers/forest.png"
@onready var GRASS: String = "res://assets/sprites/environment/Plains parallax separate layers/Plains parallax separate layers/grass.png"
@onready var HILL: String = "res://assets/sprites/environment/Plains parallax separate layers/Plains parallax separate layers/hill.png"
@onready var PLAINS: String = "res://assets/sprites/environment/Plains parallax separate layers/Plains parallax separate layers/plains.png"
@onready var SKY: String = "res://assets/sprites/environment/Plains parallax separate layers/Plains parallax separate layers/sky.png"

#endregion -- Plains References

#region Demon Realm References

@onready var one: String = "res://assets/sprites/environment/free-pixel-art-cloud-and-sky-backgrounds/3. NEW CLOUDS/1.png"
@onready var two: String = "res://assets/sprites/environment/free-pixel-art-cloud-and-sky-backgrounds/3. NEW CLOUDS/2.png"
@onready var three: String = "res://assets/sprites/environment/free-pixel-art-cloud-and-sky-backgrounds/3. NEW CLOUDS/3.png"
@onready var four: String = "res://assets/sprites/environment/free-pixel-art-cloud-and-sky-backgrounds/3. NEW CLOUDS/4.png"
@onready var five: String = "res://assets/sprites/environment/free-pixel-art-cloud-and-sky-backgrounds/3. NEW CLOUDS/5.png"
@onready var six: String = "res://assets/sprites/environment/free-pixel-art-cloud-and-sky-backgrounds/3. NEW CLOUDS/6.png"

#endregion -- Demon Realm  References

#region Boss Level/Boss Room References

@onready var BACK: String = "res://assets/sprites/environment/parallax/back.png"
@onready var TREE: String = "res://assets/sprites/environment/parallax/tree..png"
@onready var WALL_1: String = "res://assets/sprites/environment/parallax/wall.png"
@onready var WALL_2: String = "res://assets/sprites/environment/parallax/wall2.png"
@onready var WALL_3 : String = "res://assets/sprites/environment/parallax/wall3.png"

#endregion -- Boss Level/Boss Room References

#region Michael Room References

@onready var cave_one: String = "res://assets/sprites/environment/Parallax Cave/1.png"
@onready var cave_two: String = "res://assets/sprites/environment/Parallax Cave/2.png"
@onready var cave_three: String = "res://assets/sprites/environment/Parallax Cave/3fx.png"
@onready var cave_four: String = "res://assets/sprites/environment/Parallax Cave/4.png"
@onready var cave_five: String = "res://assets/sprites/environment/Parallax Cave/7.png"
@onready var cave_six: String = "res://assets/sprites/environment/Parallax Cave/9.png"


#endregion -- Michael Room References

#region Functions

#region Processes

func _ready() -> void:
	match GameManager.game_scene_state:
		GameManager.GameLevelStates.GRASSLAND_SCENE:
			set_parallax_texture(SKY, CLOUDS, HILL, FOREST, PLAINS, GRASS)
			set_parallax_scroll(Vector2(0.0, 0.0), Vector2(0.08, 0.08), Vector2(0.09, 0.09), Vector2(0.1, 0.1), Vector2(0.3, 0.3), Vector2(0.8, 0.8))
			set_parallax_repeat_size(Vector2(640.0, 0.0), Vector2(640.0, 0.0), Vector2(640.0, 0.0), Vector2(640.0, 0.0), Vector2(640.0, 0.0), Vector2(640.0, 0.0))
			set_parallax_repeat_times(1, 1, 1, 1, 1, 1)
		GameManager.GameLevelStates.DEMON_REALM:
			set_parallax_texture(one, two, three, four, five, six)
			set_parallax_scroll(Vector2(0.0, 0.0), Vector2(0.08, 0.08), Vector2(0.01, 0.01), Vector2(0.2, 0.2), Vector2(0.6, 0.6), Vector2(0.1, 0.1))
			set_parallax_repeat_size(Vector2(576.0, 0.0), Vector2(576.0, 0.0), Vector2(576.0, 0.0), Vector2(576.0, 0.0), Vector2(576.0, 0.0), Vector2(640.0, 0.0))
			set_parallax_repeat_times(1, 1, 1, 1, 1, 1)
		GameManager.GameLevelStates.BOSS_LEVEL:
			set_parallax_texture(BACK, TREE, WALL_2, WALL_3, WALL_1, WALL_1)
			set_parallax_scroll(Vector2(0.0, 0.0), Vector2(0.08, 0.08), Vector2(0.02, 0.02), Vector2(0.3, 0.3), Vector2(0.25, 0.25), Vector2(0.5, 0.5))
			set_parallax_repeat_size(Vector2(0.0, 340), Vector2(0.0, 340), Vector2(0.0, 340), Vector2(0.0, 340), Vector2(0.0, 340), Vector2(0.0, 340))
			set_parallax_repeat_times(1, 1, 1, 1, 1, 1)
		GameManager.GameLevelStates.BOSS_ROOM:
			set_parallax_texture(BACK, TREE, WALL_2, WALL_3, WALL_1, WALL_1)
			set_parallax_scroll(Vector2(0.0, 0.0), Vector2(0.08, 0.08), Vector2(0.02, 0.02), Vector2(0.3, 0.3), Vector2(0.25, 0.25), Vector2(0.5, 0.5))
			set_parallax_repeat_size(Vector2(0.0, 340), Vector2(0.0, 340), Vector2(0.0, 340), Vector2(0.0, 340), Vector2(0.0, 340), Vector2(0.0, 340))
			set_parallax_repeat_times(1, 1, 1, 1, 1, 1)
		GameManager.GameLevelStates.MICHAEL_ROOM:
			set_parallax_texture(cave_one, cave_two, cave_three, cave_four, cave_five, cave_six)
			set_parallax_scroll(Vector2(0.0, 0.0), Vector2(0.2, 0.2), Vector2(0.1, 0.1), Vector2(0.4, 0.4), Vector2(0.5, 0.5), Vector2(1.0, 1.0))
			set_parallax_repeat_size(Vector2(640.0, 0.0), Vector2(640.0, 0.0), Vector2(640.0, 0.0), Vector2(640.0, 0.0), Vector2(640.0, 0.0), Vector2(640.0, 0.0))
			set_parallax_repeat_times(1, 1, 1, 1, 1, 1)


#endregion -- Processes

func set_parallax_texture(s_far: String, s_midfar: String, s_mid: String,
	s_midnear: String, s_near: String, s_front: String,) -> void:
	
	sprite_far.texture = load(s_far)
	sprite_mid_far.texture = load(s_midfar)
	sprite_mid.texture = load(s_mid)
	sprite_mid_near.texture = load(s_midnear)
	sprite_near.texture = load(s_near)
	sprite_front.texture = load(s_front)
	
func set_parallax_scroll(p_far: Vector2, p_midfar: Vector2, p_mid: Vector2,
	p_midnear: Vector2, p_near: Vector2, p_front: Vector2,) -> void:
	
	parallax_far.scroll_scale = p_far
	parallax_mid_far.scroll_scale = p_midfar
	parallax_mid.scroll_scale = p_mid
	parallax_mid_near.scroll_scale = p_midnear
	parallax_near.scroll_scale = p_near
	parallax_front.scroll_scale = p_front

func set_parallax_repeat_size(p_far: Vector2, p_midfar: Vector2, p_mid: Vector2,
	p_midnear: Vector2, p_near: Vector2, p_front: Vector2,) -> void:
	
	parallax_far.repeat_size = p_far
	parallax_mid_far.repeat_size = p_midfar
	parallax_mid.repeat_size = p_mid
	parallax_mid_near.repeat_size = p_midnear
	parallax_near.repeat_size = p_near
	parallax_front.repeat_size = p_front

func set_parallax_repeat_times(p_far: int, p_midfar: int, p_mid: int,
	p_midnear: int, p_near: int, p_front: int,) -> void:
	
	parallax_far.repeat_times = p_far
	parallax_mid_far.repeat_times = p_midfar
	parallax_mid.repeat_times = p_mid
	parallax_mid_near.repeat_times = p_midnear
	parallax_near.repeat_times = p_near
	parallax_front.repeat_times = p_front

func set_parallax_zoom_scale(p_far: Vector2, p_midfar: Vector2, p_mid: Vector2,
	p_midnear: Vector2, p_near: Vector2, p_front: Vector2,) -> void:
	
	parallax_far.scale = p_far
	parallax_mid_far.scale = p_midfar
	parallax_mid.scale = p_mid
	parallax_mid_near.scale = p_midnear
	parallax_near.scale = p_near
	parallax_front.scale = p_front


#endregion -- Functions
