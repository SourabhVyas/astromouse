extends Node2D

var level: int = 1
var fuel: float = 10.0
const MAX_LEVELS: int = 6
const SPRITE_NAMES: Array = ["Red", "Yellow", "Green"]
var playerWidth: float = 0.0

func _ready() -> void:
	calculate_player_width()


func calculate_player_width() -> void:
	var sprite_node = $Sprite
	if sprite_node and sprite_node.texture:
		var tex_size = sprite_node.texture.get_size()
		playerWidth = tex_size.x * sprite_node.scale.x
	else:
		playerWidth = 0.0
		
