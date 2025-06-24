extends Area2D

var speed = 400.0

func _ready():
	add_to_group("obstacles")
	# Connect collision signal
	body_entered.connect(_on_body_entered)

func _process(delta):
	# Move left
	position.x -= speed * delta
	
	# Delete when off screen
	if position.x < -100:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.die()
