extends Node2D

func _ready() -> void:
	$Label.text = "Score: " + str(GLOBAL.SCORE)
