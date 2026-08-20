extends Control


@onready var amiya_thumbnail_path: String = "res://.godot/imported/Amiya_thumbnail.png-834829f972c9de96a3dafc59ae82382c.ctex"
@onready var bucko_thumbnail_path: String = "res://.godot/imported/bucko_thumbnail.png-5ed1b9fb6710ac235db47d0570e2fcb5.ctex"


#region Dialogue Collection

@onready var prelogue_text_collect: Dictionary = {
	"Amiya": {
		"seq_0": "Wait, Bucko.",
		"seq_1": "Salaryman Satou… despite wearing weird clothes, it is said that his power rivals the demon lord. Take caution, Bucko.",
		"seq_2": "....",
		"seq_3": "(pfft)"
	},
	"Bucko": {
		"seq_1": "You dress weird."
	},
	"Boss": {
		"seq_1": "Oho…? Cleric Aminya Aranha… or should I say the hero party's saint. Rumor has it that you're a powerful healer.",
		"seq_2": "Why don't you join us; and together, we will -",
		"seq_3": "Nevermind. I Satou, shall bring you demise."
	}
}

#endregion -- Dialogue Collection

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
