#ParallaxBackground2.gd
extends ParallaxBackground

# Scroll speed for the background
@export var scroll_speed = 50.0  # Pixels per second

func _process(delta):
	# Move the background left
	scroll_offset.x -= scroll_speed * delta
