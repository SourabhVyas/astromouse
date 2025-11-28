extends Node2D

func _ready() -> void:
	$Label.text = "Game Over \n" + str(GLOBAL.SCORE)
	
	$TextureButton.connect("mouse_entered", Callable(self, "_on_button_hover"))
	$TextureButton.connect("mouse_exited", Callable(self, "_on_button_exit"))



func _on_texture_button_button_down() -> void:
	GLOBAL.SCORE = 0
	get_tree().change_scene_to_file("res://main.tscn")


func _on_button_hover():
	$TextureButton.modulate = Color(1, 1, 1.2) # slight glow

func _on_button_exit():
	$TextureButton.modulate = Color(1, 1, 1) # reset
