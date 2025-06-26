#ObstacleSpawner.gd
extends Node2D

@export var obstacle_scene: PackedScene

# Spawn positions
@export var ground_spawn_y = 580.0  # Ground level
@export var air_spawn_y = 400.0     # Air level for flying obstacles
@export var spawn_chance_air = 0.3  # 30% chance to spawn flying obstacles

# Spawn timing
var spawn_timer: Timer
var base_spawn_time = 2.0
var current_spawn_time = 2.0

func _ready():
	if obstacle_scene == null:
		print("WARNING: No obstacle scene assigned!")
		return
		
	# Create timer
	spawn_timer = Timer.new()
	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(_spawn_obstacle)
	add_child(spawn_timer)
	_start_next_spawn()

func _start_next_spawn():
	spawn_timer.wait_time = current_spawn_time
	spawn_timer.start()

func _spawn_obstacle():
	if obstacle_scene == null:
		_start_next_spawn()
		return
		
	# Create obstacle
	var obstacle = obstacle_scene.instantiate()
	
	# Add to scene FIRST before calling methods
	get_parent().add_child(obstacle)
	
	# Decide if we want a flying obstacle
	var spawn_flying = randf() < spawn_chance_air
	
	# Position it off screen
	obstacle.position.x = 1300
	
	if spawn_flying:
		# Spawn flying obstacle (type 2 or 3) in the air
		obstacle.position.y = air_spawn_y
		var flying_type = randi() % 2 + 2  # Random between 2 and 3 (for flying1 and flying2)
		obstacle.call_deferred("set_sprite_type", flying_type)
		print("Spawning FLYING obstacle type ", flying_type, " (", ["ground1", "ground2", "flying1", "flying2"][flying_type], ") at Y: ", air_spawn_y)
	else:
		# Spawn ground obstacle (type 0 or 1) on ground
		obstacle.position.y = ground_spawn_y
		var ground_type = randi() % 2  # Random between 0 and 1 (for ground1 and ground2)
		obstacle.call_deferred("set_sprite_type", ground_type)
		print("Spawning GROUND obstacle type ", ground_type, " (", ["ground1", "ground2", "flying1", "flying2"][ground_type], ") at Y: ", ground_spawn_y)
	
	# Set speed
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager and game_manager.has_method("get_current_obstacle_speed"):
		var speed = game_manager.get_current_obstacle_speed()
		if obstacle.has_method("set_speed"):
			obstacle.set_speed(speed)
	
	# Continue spawning
	_start_next_spawn()

func increase_speed(speed_multiplier):
	current_spawn_time = base_spawn_time / speed_multiplier
	current_spawn_time = max(0.5, current_spawn_time)
