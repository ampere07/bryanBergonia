#Player.gd
extends CharacterBody2D

const GRAVITY = 980.0
const JUMP_VELOCITY = -500.0
const DOUBLE_JUMP_VELOCITY = -450.0  # Slightly weaker than first jump
const FAST_FALL_MULTIPLIER = 2.0

var is_dead = false
var is_jumping = false
var jump_count = 0  # Track number of jumps
var max_jumps = 2   # Allow double jump

# Get the AnimatedSprite2D node
@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	add_to_group("player")
	
	# Start with run animation
	if animated_sprite:
		animated_sprite.play("run")
		# Connect animation finished signal for non-looping animations
		if not animated_sprite.animation_finished.is_connected(_on_animation_finished):
			animated_sprite.animation_finished.connect(_on_animation_finished)
	else:
		print("Warning: No AnimatedSprite2D found!")

func _physics_process(delta):
	if is_dead:
		return
	
	# Add gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		
		# Fast fall when releasing jump early
		if velocity.y < 0 and not Input.is_action_pressed("jump"):
			velocity.y += GRAVITY * FAST_FALL_MULTIPLIER * delta
	
	# Reset jump count when on floor
	if is_on_floor():
		jump_count = 0
		is_jumping = false
		
		# Play run animation if not already playing
		if animated_sprite.animation != "run":
			animated_sprite.play("run")
	
	# Handle jump and double jump
	if Input.is_action_just_pressed("jump") and jump_count < max_jumps:
		if jump_count == 0:
			# First jump (from ground or coyote time)
			velocity.y = JUMP_VELOCITY
			print("First jump!")
		else:
			# Double jump (in air)
			velocity.y = DOUBLE_JUMP_VELOCITY
			print("Double jump!")
		
		jump_count += 1
		is_jumping = true
		animated_sprite.play("jump")
	
	# Apply movement
	move_and_slide()

func _on_animation_finished():
	# When jump animation finishes, return to run if on ground
	if animated_sprite.animation == "jump" and is_on_floor():
		animated_sprite.play("run")

func die():
	if is_dead:
		return  # Prevent multiple death calls
		
	is_dead = true
	print("Player died!")
	
	# Stop horizontal movement
	velocity.x = 0
	
	# Play death animation if available
	if animated_sprite:
		if animated_sprite.sprite_frames.has_animation("dead"):
			animated_sprite.play("dead")
			# Wait for death animation to finish
			await animated_sprite.animation_finished
		elif animated_sprite.sprite_frames.has_animation("idle"):
			animated_sprite.play("idle")
			await animated_sprite.animation_finished
		else:
			animated_sprite.stop()
			# If no death animation, wait a short moment
			await get_tree().create_timer(0.5).timeout
	else:
		# No animated sprite, wait a moment
		await get_tree().create_timer(0.5).timeout
	
	# Call game over in GameManager after animation finishes
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager.game_over()
	else:
		print("ERROR: GameManager not found!")
		# Fallback: restart after delay
		await get_tree().create_timer(1.0).timeout
		get_tree().reload_current_scene()
