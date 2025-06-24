extends CharacterBody2D

const GRAVITY = 980.0
const JUMP_VELOCITY = -500.0

var is_dead = false

func _ready():
	add_to_group("player")
	print("Player ready!")
	print("Starting position: ", position)

func _physics_process(delta):
	if is_dead:
		return
	
	# Add gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# Handle jump
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		print("Jumping!")
	
	# Apply movement
	move_and_slide()
	
	# Debug info
	if Input.is_action_just_pressed("jump") and not is_on_floor():
		print("Can't jump - not on floor! Y position: ", position.y)

func die():
	is_dead = true
	print("Game Over!")
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()
