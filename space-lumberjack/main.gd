extends Node2D


var pipe: Array = [2,2]
var playerChoice: int = -1
var playerPos = 1

var blockScene: PackedScene = preload("res://blocks/blocks.tscn")
var centerX
var blockHeight = 0
var blockWidth = 0

func _ready() -> void:
	centerX = get_viewport().get_visible_rect().size.x / 2
	randomize()
	print(blockHeight)
	for i in range(10):
		pipe.append(randi()%3)
	
	for i in range(12):
		var block = blockScene.instantiate()
		blockHeight = block.get_height()
		blockWidth = block.get_width()
		block.global_position = Vector2(centerX, -blockHeight*i)
		block.branchSide = pipe[i]
		$Pipe.add_child(block)

func update_pipe() -> void:
	$Player._update_sprite()
	pipe.append(randi()%3)
	$Pipe.get_child(0).queue_free()
	for blocks in $Pipe.get_children():
		blocks.global_position += Vector2(0, blockHeight)
		
	var block = blockScene.instantiate()
	block.global_position = Vector2(centerX, -blockHeight*11)
	block.branchSide = pipe[9]
	$Pipe.add_child(block)
	$ParallaxBackground.scroll_offset.y += 10

func check_hit() -> void:
	if pipe.pop_front() == playerChoice: 
		print("death")
	update_pipe()
		
	
func _on_right_button_button_down() -> void:
	playerChoice = 1
	if playerPos == 0:
		$Player.position += Vector2(blockWidth*2,0)
		playerPos = 1
	check_hit()


func _on_left_button_button_down() -> void:
	playerChoice = 0
	if playerPos == 1:
		$Player.position -= Vector2(blockWidth*2,0)
		playerPos = 0
	check_hit()
