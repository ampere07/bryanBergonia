extends ParallaxBackground

# Base scroll speed (pixels per second)
@export var base_scroll_speed = 400.0

# Reference to game manager for dynamic speed
var game_manager

func _ready():
	# Get game manager reference
	game_manager = get_tree().get_first_node_in_group("game_manager")

func _process(delta):
	# Get current game speed multiplier
	var speed_multiplier = 1.0
	if game_manager and game_manager.has_method("get"):
		speed_multiplier = game_manager.get("game_speed") if game_manager.get("game_speed") else 1.0
	
	# Scroll the background
	scroll_offset.x -= base_scroll_speed * speed_multiplier * delta
