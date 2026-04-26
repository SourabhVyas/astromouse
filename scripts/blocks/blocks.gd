extends Node2D
var branchSide := -1

func _ready() -> void:
	$Left.visible = branchSide == 0
	$Right.visible = branchSide == 1

func get_height():
	return $Spine.texture.get_height() * scale.y

func get_width():
	return $Spine.texture.get_width() * scale.x
