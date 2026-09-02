extends Node

@export var pipe_scene : PackedScene

var game_running : bool
var game_over : bool
var scroll
var score
const SCROLL_SPEED : int = 4
var screen_size : Vector2i
var ground_height : int
var pipes : Array
const PIPE_DELAY : int = 300
const PIPE_RANGE : int = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	var groundSprite = $ground.get_node("Sprite2D")
	ground_height = groundSprite.texture.get_height() * groundSprite.scale.y * $ground.scale.y
	$ground.hit.connect(bird_hit)
	new_game()
	
	
func new_game():
	game_running = false
	game_over = false
	score = 0
	scroll = 0
	for pipe in pipes:
		pipe.queue_free()
	pipes.clear()
	$PipeTimer.stop()
	generate_pipes()
	$nathan.reset()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if game_over:
				new_game()
			elif game_running == false:
				start_game()
			elif $nathan.flying:
				$nathan.flap()

func start_game():
	game_running = true
	$nathan.flying = true
	$nathan.flap()
	$PipeTimer.start()
	
func _process(delta):
	if game_running:
		scroll += SCROLL_SPEED
		if scroll >= screen_size.x:
			scroll = 0

		$ground.position.x = -scroll
		for i in range(pipes.size() - 1, -1, -1):
			var pipe = pipes[i]
			pipe.position.x -= SCROLL_SPEED
			if pipe.position.x < -200:
				pipe.queue_free()
				pipes.remove_at(i)

func _on_pipe_timer_timeout():
	generate_pipes()
	
func generate_pipes():
	var pipe = pipe_scene.instantiate()
	pipe.position.x = screen_size.x + PIPE_DELAY
	pipe.position.y = (screen_size.y - ground_height) / 2 + randi_range(-PIPE_RANGE, PIPE_RANGE)
	pipe.hit.connect(bird_hit)
	add_child(pipe)
	pipes.append(pipe)

func bird_hit():
	if game_over:
		return
	game_over = true
	game_running = false
	$nathan.flying = false
	$nathan.falling = true
	$PipeTimer.stop()
