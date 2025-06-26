extends Area2D

var speed = 400.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

# Expanded animation names
var animation_names = [
	"ground1", "ground2",
	"flying1", "flying2"
]

var current_type = 0
var is_flying_type = false

func _ready():
	add_to_group("obstacles")
	body_entered.connect(_on_body_entered)
	
	# Make sure visible
	visible = true
	z_index = 10
	
	# Debug check
	if animated_sprite:
		print("AnimatedSprite2D found, current animation: ", animated_sprite.animation)
		print("Is playing: ", animated_sprite.is_playing())

func set_sprite_type(index: int):
	"""Called by spawner to set which animation to play"""
	current_type = index
	is_flying_type = (index >= 2)  # Indices 4 and above are flying types
	
	# Wait for node to be ready if needed
	if not is_node_ready():
		await ready
	
	if animated_sprite and index < animation_names.size():
		var animation = animation_names[index]
		animated_sprite.visible = true
		animated_sprite.animation = animation  # Set animation first
		animated_sprite.play()  # Then play it
		animated_sprite.frame = 0  # Start from first frame
		
		print("Setting animation to: ", animation, " (index: ", index, ")")
		print("Animation is playing: ", animated_sprite.is_playing())
		print("Animation frame count: ", animated_sprite.sprite_frames.get_frame_count(animation))

func _process(delta):
	# Move left
	position.x -= speed * delta
	
	# Debug every second
	if Engine.get_process_frames() % 60 == 0 and animated_sprite:
		print("Obstacle ", current_type, " at X: ", position.x, " | Animation: ", animated_sprite.animation, " | Playing: ", animated_sprite.is_playing())
	
	# Delete when off screen
	if position.x < -100:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.die()

func set_speed(new_speed):
	speed = new_speed

func get_is_flying_type() -> bool:
	return is_flying_type
