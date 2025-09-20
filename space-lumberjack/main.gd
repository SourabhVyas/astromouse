extends Node2D

const VISIBLE_BLOCK_COUNT: int = 12

var pipe: Array = [2, 2]
var playerChoice: int = -1
var playerPos: int = 1
var blockScene: PackedScene = preload("res://blocks/blocks.tscn")

var centerX: float
var blockHeight: float = 0
var blockWidth: float = 0

var playerExtraOffset: float = 30.0
var switchLen: float = 0.0

func _ready() -> void:
	initialize_center_x()
	randomize()
	initialize_pipe_branches(10)
	initialize_initial_blocks()

	$Player.calculate_player_width()
	set_initial_player_position()

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
			KEY_RIGHT:
				handle_right_input()

func _handle_screen_press(pos: Vector2) -> void:
	var screenWidth = get_viewport().get_visible_rect().size.x
	if pos.x < screenWidth * 0.5:
		handle_left_input()
	else:
		handle_right_input()

func handle_left_input() -> void:
	playerChoice = 0
	if playerPos == 1:
		$Player.position.x -= switchLen * 2
		playerPos = 0
	check_hit()

func handle_right_input() -> void:
	playerChoice = 1
	if playerPos == 0:
		$Player.position.x += switchLen * 2
		playerPos = 1
	check_hit()

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
	var last_val = pipe[ pipe.size() - 1 ]
	pipe.append(2 if last_val != 2 and new_val != last_val else new_val)

func create_and_add_block(rowIndex: int, branchSide: int) -> void:
	var block = blockScene.instantiate()
	if blockHeight == 0 or blockWidth == 0:
		blockHeight = block.get_height()
		blockWidth = block.get_width()
	block.global_position = Vector2(centerX, -blockHeight * rowIndex)
	block.branchSide = branchSide
	$Pipe.add_child(block)

func update_pipe() -> void:
	$Player.update_sprites()
	append_pipe_branch()
	remove_oldest_block()
	move_blocks_down()
	add_newest_block()
	$ParallaxBackground.scroll_offset.y += 10

func add_newest_block() -> void:
	var row_index = VISIBLE_BLOCK_COUNT - 1
	var branch_side = pipe[ pipe.size() - 1 ]
	create_and_add_block(row_index, branch_side)

func remove_oldest_block() -> void:
	$Pipe.get_child(0).queue_free()

func move_blocks_down() -> void:
	for blk in $Pipe.get_children():
		blk.global_position.y += blockHeight

func check_hit() -> void:
	var nxt_block = pipe[1]
	pipe.pop_front()
	$Label.text = str("left" if nxt_block == 0 else "right")
	if nxt_block == playerChoice:
		print("death")
	update_pipe()
