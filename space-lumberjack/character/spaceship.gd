extends Node2D

var level: int = 1
var fuel: float = 10.0
const MAX_LEVELS: int = 6
const SPRITE_NAMES: Array = ["Red", "Yellow", "Green"]
var playerWidth: float = 0.0

func _ready() -> void:
	update_sprites()
	calculate_player_width()

func update_sprites() -> void:
	hide_all_sprites()
	var activeLevelNode = get_level_node(level)
	if not activeLevelNode:
		return
	var spriteToShow = decide_sprite_color()
	show_sprite(activeLevelNode, spriteToShow)

func hide_all_sprites() -> void:
	for i in range(1, MAX_LEVELS + 1):
		var levelNode = get_level_node(i)
		if not levelNode:
			continue
		for spriteName in SPRITE_NAMES:
			var sprite = levelNode.get_node(spriteName)
			sprite.visible = false

func get_level_node(levelIndex: int) -> Node2D:
	return get_node_or_null("Level%d" % levelIndex)

func decide_sprite_color() -> String:
	if fuel < 0.33:
		return "Red"
	elif fuel < 0.66:
		return "Yellow"
	return "Green"

func show_sprite(levelNode: Node2D, spriteName: String) -> void:
	var sprite = levelNode.get_node(spriteName)
	sprite.visible = true

func calculate_player_width() -> void:
	var sprite_node = $Sprite
	if sprite_node and sprite_node.texture:
		var tex_size = sprite_node.texture.get_size()
		playerWidth = tex_size.x * sprite_node.scale.x
	else:
		playerWidth = 0.0
		

@export var min_alpha := 0.5
@export var max_alpha := 1.0

func _process(delta: float) -> void:
	$Line2D.modulate.a = (randf_range(min_alpha, max_alpha) + fuel)/2
