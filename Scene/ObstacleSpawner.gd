extends Node2D

@export var obstacle_scene: PackedScene

func _ready():
	# Create timer
	var timer = Timer.new()
	timer.wait_time = 2.0  # Spawn every 2 seconds
	timer.timeout.connect(_spawn_obstacle)
	add_child(timer)
	timer.start()

func _spawn_obstacle():
	if obstacle_scene == null:
		print("No obstacle scene assigned!")
		return
		
	# Create obstacle
	var obstacle = obstacle_scene.instantiate()
	
	# Position it off screen to the right
	obstacle.position.x = 1300
	obstacle.position.y = 543  # Just above ground
	
	# Add to main scene
	get_parent().add_child(obstacle)
