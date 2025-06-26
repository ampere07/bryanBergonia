#ScrollingFloor.gd
extends Node2D

@export var scroll_speed = 400.0

var floor_texture = preload("res://Assets/tileset/floornew2.png")
var floor_sprites = []
var floor_width: float
var total_offset: float = 0.0

func _ready():
	if not floor_texture:
		print("Failed to load floor texture!")
		return
	
	floor_width = floor_texture.get_width()
	var screen_width = get_viewport().size.x
	
	# Create just enough sprites to cover screen + 1 extra
	var num_sprites = int(ceil(screen_width / floor_width)) + 2
	
	for i in range(num_sprites):
		var sprite = Sprite2D.new()
		sprite.texture = floor_texture
		sprite.position.y = 0
		add_child(sprite)
		floor_sprites.append(sprite)

func _process(delta):
	# Update total offset
	total_offset += scroll_speed * delta
	
	# Use modulo to keep offset within bounds
	var wrapped_offset = fmod(total_offset, floor_width)
	
	# Position each sprite based on wrapped offset
	for i in range(floor_sprites.size()):
		floor_sprites[i].position.x = (i * floor_width) - wrapped_offset
