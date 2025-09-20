extends Node2D

var level: int = 1
var fuel: float = 10.0

func _update_sprite():
	# Hide all sprites in all levels first
	for i in range(1, 7): # Levels 1 to 5
		var level_node = get_node("Level%d" % i)  # ✅ use get_node with string
		if level_node:
			for sprite_name in ["Red", "Yellow", "Green"]:
				var sprite = level_node.get_node(sprite_name)
				sprite.visible = false

	# Pick the active level node
	var active_level = get_node("Level%d" % level)
	if not active_level:
		return

	# Decide which color to show based on fuel
	var sprite_to_show: String
	if fuel < 3.33:
		sprite_to_show = "Red"
	elif fuel < 6.66:
		sprite_to_show = "Yellow"
	else:
		sprite_to_show = "Green"

	# Show only that sprite
	active_level.get_node(sprite_to_show).visible = true

func _ready() -> void:
	_update_sprite()
