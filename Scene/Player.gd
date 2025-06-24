extends CharacterBody2D

const GRAVITY = 980.0
const JUMP_VELOCITY = -550.0
const DOUBLE_JUMP_VELOCITY = -350.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

var is_dead = false
var can_double_jump = false  # For later if you want to add double jump

func _ready():
	# Start with running animation
	animated_sprite.play("run")
	# Add to player group
	add_to_group("player")
	
func _physics_process(delta):
	if is_dead:
		return
		
	# Add gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		# Reset double jump when on ground
		can_double_jump = true
	
	# Handle jump - check for both space and W
	if is_on_floor() and (Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("jump")):
		velocity.y = JUMP_VELOCITY
		animated_sprite.play("jump")
	
	# Optional: Add double jump
	# elif can_double_jump and not is_on_floor() and (Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("jump_alt")):
	#	velocity.y = DOUBLE_JUMP_VELOCITY
	#	can_double_jump = false
	#	animated_sprite.play("jump")
	
	# Return to run animation when landing
	if is_on_floor() and velocity.y >= 0 and animated_sprite.animation == "jump":
		animated_sprite.play("run")
	
	# Keep the player in the same X position (endless runner style)
	velocity.x = 0
	
	move_and_slide()

func die():
	is_dead = true
	animated_sprite.play("dead")
	set_collision_layer_value(1, false)  # Disable collision to prevent multiple hits
	# Emit signal to game manager
	get_tree().call_group("game_manager", "game_over")
	
func reset():
	is_dead = false
	can_double_jump = true
	set_collision_layer_value(1, true)  # Re-enable collision
	velocity = Vector2.ZERO
