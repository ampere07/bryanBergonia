#GameManager.gd
extends Node

var score = 0
var game_speed = 1.0  # Speed multiplier
var base_obstacle_speed = 400.0  # Base speed for obstacles

@onready var score_label = $"../ScoreLabel"
@onready var obstacle_spawner = $"../ObstacleSpawner"

func _ready():
	# Add to game_manager group
	add_to_group("game_manager")
	
	# Score timer
	var timer = Timer.new()
	timer.wait_time = 0.1
	timer.timeout.connect(_increase_score)
	add_child(timer)
	timer.start()

func _increase_score():
	score += 1
	score_label.text = "Score: " + str(score)
	
	# Increase speed every 100 points
	if score % 100 == 0:
		_increase_game_speed()

func _increase_game_speed():
	game_speed += 0.1  # 10% faster
	print("Speed increased! New multiplier: ", game_speed)
	
	# Update obstacle spawner timing
	if obstacle_spawner and obstacle_spawner.has_method("increase_speed"):
		obstacle_spawner.increase_speed(game_speed)
	
	# Make all current obstacles go faster
	get_tree().call_group("obstacles", "set_speed", base_obstacle_speed * game_speed)

func get_current_obstacle_speed():
	return base_obstacle_speed * game_speed

func game_over():
	# Reset speed when game over
	game_speed = 1.0
	get_tree().reload_current_scene()
