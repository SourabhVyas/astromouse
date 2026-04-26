extends Node2D

var replay
var scoreText
var replay_text
var comment
@export var my_videos: VideoCollection

func _ready() -> void:
	scoreText = $Score
	scoreText.text = str(GLOBAL.SCORE)
	replay_text = $Replay
	replay = $Replay/Button
	
	comment = "Nice\nScore!"
	
	
	
	if GLOBAL.SCORE <= 50:
		$left_player.stream = my_videos.sad_score
		comment="you\ntried..."
	elif GLOBAL.HIGHSCORE > 50:
		if GLOBAL.SCORE > GLOBAL.HIGHSCORE:
			$left_player.stream = my_videos.high_score
			comment = "HIGH\nSCORE!"
		elif GLOBAL.HIGHSCORE - GLOBAL.SCORE <= 20:
			$left_player.stream = my_videos.close
			comment = "so close\nyet so far"
	else:
		$left_player.stream = my_videos.normal
	$Label.text = comment
	$left_player.play()
	
	GLOBAL.HIGHSCORE = max(GLOBAL.SCORE, GLOBAL.HIGHSCORE)

func _on_button_button_down() -> void:
	GLOBAL.SCORE = 0
	get_tree().change_scene_to_file("res://scenes/game/main.tscn")


var size_tween: Tween

func _on_button_mouse_entered() -> void:
	replay.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_animate_font_size(104)

func _on_button_mouse_exited() -> void:
	replay.mouse_default_cursor_shape = Control.CURSOR_ARROW
	_animate_font_size(96)

func _animate_font_size(target_size: int) -> void:
	if size_tween and size_tween.is_running():
		size_tween.kill()
	
	size_tween = create_tween()
	
	size_tween.tween_property(
		replay_text, 
		"theme_override_font_sizes/font_size", 
		target_size, 
		0.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
