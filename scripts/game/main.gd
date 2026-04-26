extends Node2D

const VISIBLE_BLOCK_COUNT: int = 12

var pipe: Array = [2, 2]
var playerChoice: int = -1
var playerPos: int = 1
var blockScene: PackedScene = preload("res://scenes/blocks/blocks.tscn")

var centerX: float
var blockHeight: float = 0
var blockWidth: float = 0

var playerExtraOffset: float = 53.0
var switchLen: float = 0.0

var clickToLevel: Array = [0, 100, 210, 320, 430, 540, 650]
var fuelDecay: Array = [0, 0.1, 0.2, 0.25, 0.3, 0.3, 0.4]
var fuelAdd: float = 0.04
var backgroundScrollSpeed: Array = [0, 1, 2, 3, 4, 5, 6]
var over: bool = false

var move_sound: AudioStreamPlayer


func _ready() -> void:
	initialize_center_x()
	randomize()
	initialize_pipe_branches(10)
	initialize_initial_blocks()
	$Player.calculate_player_width()
	set_initial_player_position()
	
	move_sound = $Action


func _process(delta: float) -> void:
	if $Player.fuel <= 0:
		game_over()
		return

	if GLOBAL.SCORE > 0:
		$Player.fuel -= fuelDecay[$Player.level] * delta

	$PanelContainer/GridContainer/ProgressBar.value = $Player.fuel
	$PanelContainer/GridContainer/Score.text = str(GLOBAL.SCORE)

	for blk in $Pipe.get_children():
		_apply_block_scaling(blk)


func game_over() -> void:
	if over:
		return

	over = true
	$Player/AnimationPlayer.stop()
	$"Level Sound".stop()
	$"Last Yell".play()
	print("Game Over")

	var target_pos = $Marker2D.global_position + Vector2(0, 80)
	var tween = create_tween()

	tween.parallel().tween_property($Player, "global_position", target_pos, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property($Player, "rotation_degrees", 360, 1.5).set_trans(Tween.TRANS_LINEAR)
	tween.parallel().tween_property($Player, "scale", Vector2(0.0, 0.0), 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_callback(Callable(self, "_on_game_over_animation_done")).set_delay(0.5)


func _on_game_over_animation_done() -> void:
	$Player.queue_free()
	get_tree().change_scene_to_file("res://scenes/ui/home.tscn")


func set_initial_player_position() -> void:
	switchLen = blockWidth * 0.5 + playerExtraOffset + $Player.playerWidth * 0.5
	var px = centerX + switchLen
	$Player.position = Vector2(px, $Pipe.position.y)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_handle_screen_press(event.position)
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_screen_press(event.position)
		return

	if event is InputEventKey and event.is_pressed() and not event.echo:
		match event.keycode:
			KEY_LEFT:
				handle_left_input()
				move_sound.play()
			KEY_RIGHT:
				handle_right_input()
				move_sound.play()


func _handle_screen_press(pos: Vector2) -> void:
	var screenWidth = get_viewport().get_visible_rect().size.x
	if pos.x < screenWidth * 0.5:
		handle_left_input()
	else:
		handle_right_input()


func handle_left_input() -> void:
	playerChoice = 0
	if check_hit():
		return
	if playerPos == 1:
		$Player.position.x -= switchLen * 2
		playerPos = 0


func handle_right_input() -> void:
	playerChoice = 1
	if check_hit():
		return
	if playerPos == 0:
		$Player.position.x += switchLen * 2
		playerPos = 1
		


func update_level_fuel() -> void:
	if GLOBAL.SCORE == clickToLevel[$Player.level]:
		$Player.level = min($Player.level + 1, 6)
	$Player.fuel = min(1, $Player.fuel + fuelAdd)


func initialize_center_x() -> void:
	centerX = get_viewport().get_visible_rect().size.x * 0.5


func initialize_pipe_branches(count: int) -> void:
	for i in range(count):
		append_pipe_branch()


func initialize_initial_blocks() -> void:
	for i in range(VISIBLE_BLOCK_COUNT):
		create_and_add_block(i, pipe[i])


func append_pipe_branch() -> void:
	var new_val = randi() % 3
	var last_val = pipe[pipe.size() - 1]
	pipe.append(2 if last_val != 2 and new_val != last_val else new_val)


func create_and_add_block(rowIndex: int, branchSide: int) -> void:
	var block = blockScene.instantiate()

	if blockHeight == 0 or blockWidth == 0:
		blockHeight = block.get_height()
		blockWidth = block.get_width()

	block.global_position = Vector2(centerX, -blockHeight * rowIndex)
	block.branchSide = branchSide

	_apply_block_scaling(block)
	$Pipe.add_child(block)


func update_pipe() -> void:
	append_pipe_branch()

	if len(pipe) > 12:
		remove_oldest_block()

	move_blocks_down()
	add_newest_block()
	$ParallaxBackground.scroll_offset.y += backgroundScrollSpeed[$Player.level]


func add_newest_block() -> void:
	var row_index = VISIBLE_BLOCK_COUNT - 1
	var branch_side = pipe[pipe.size() - 1]
	create_and_add_block(row_index, branch_side)


func remove_oldest_block() -> void:
	$Pipe.get_child(0).queue_free()


func move_blocks_down() -> void:
	for blk in $Pipe.get_children():
		blk.global_position.y += blockHeight
		_apply_block_scaling(blk)


func check_hit() -> bool:
	var nxt_block = pipe[1]

	if nxt_block == playerChoice or over:
		game_over()
		return true

	pipe.pop_front()
	update_pipe()
	GLOBAL.SCORE += 1
	update_level_fuel()
	return false


func _apply_block_scaling(block: Node2D) -> float:
	var distance = block.global_position.y - $Marker2D.global_position.y

	var falloff_distance: float = 300.0
	var min_scale: float = 0.3
	var max_scale: float = 1.0

	var t = clamp(distance / falloff_distance, 0.0, 1.0)
	var multiplier = lerp(max_scale, min_scale, t)

	block.scale = block.scale * multiplier
	return multiplier
