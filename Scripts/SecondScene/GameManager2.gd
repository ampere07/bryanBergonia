extends Node

var score = 0
var game_speed = 1.0  # Speed multiplier
var base_obstacle_speed = 400.0  # Base speed for obstacles
var is_game_over = false  # Track if game is over

@onready var score_label = $"./ScoreLabel"
@onready var obstacle_spawner = $"./ObstacleSpawner"

# Pause menu variables
var pause_button: Button
var pause_menu_container: Control
var overlay: ColorRect
var menu_panel: Panel
var resume_btn: Button
var restart_btn: Button
var main_menu_btn: Button
var ui_layer: CanvasLayer  # Store reference to UI layer

func _ready():
	# Add to game_manager group
	add_to_group("game_manager")
	
	# Score timer
	var timer = Timer.new()
	timer.wait_time = 0.1
	timer.timeout.connect(_increase_score)
	add_child(timer)
	timer.start()
	
	# Create pause button after a short delay
	call_deferred("_create_pause_button")

func _create_pause_button():
	# First, check if UILayer already exists and remove it
	var existing_ui = get_parent().get_node_or_null("UILayer")
	if existing_ui:
		existing_ui.queue_free()
		await get_tree().process_frame
	
	# Create a CanvasLayer for UI as a sibling of GameManager
	ui_layer = CanvasLayer.new()
	ui_layer.name = "UILayer"
	ui_layer.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	ui_layer.layer = 100  # Make sure it's on top
	get_parent().call_deferred("add_child", ui_layer)
	
	# Wait for the layer to be added
	await get_tree().process_frame
	
	# Create pause button
	pause_button = Button.new()
	pause_button.text = "||"
	pause_button.position = Vector2(10, 10)
	pause_button.size = Vector2(40, 40)
	pause_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	pause_button.add_theme_font_size_override("font_size", 16)
	pause_button.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_button.focus_mode = Control.FOCUS_ALL
	ui_layer.add_child(pause_button)
	
	# Debug: Make button more visible
	pause_button.modulate = Color(1, 1, 1, 1)
	
	# Connect pause button with debug
	if pause_button.pressed.connect(_on_pause_pressed) == OK:
		print("Pause button signal connected successfully")
	else:
		print("ERROR: Failed to connect pause button signal")
	
	# Also add button_down as backup
	pause_button.button_down.connect(func(): print("Button down detected"))
	pause_button.button_up.connect(func(): print("Button up detected"))
	
	# Add mouse entered/exited for debug
	pause_button.mouse_entered.connect(func(): print("Mouse entered pause button"))
	pause_button.mouse_exited.connect(func(): print("Mouse exited pause button"))
	
	print("Pause button created at position: ", pause_button.global_position)
	print("Pause button size: ", pause_button.size)
	print("UI Layer: ", ui_layer.layer)

func _increase_score():
	# Don't increase score if game is over
	if is_game_over:
		return
		
	score += 1
	if score_label:
		score_label.text = "Score: " + str(score)
	
	# Check if score reached 300 to change scene
	if score >= 500:
		print("Score reached 500! Changing to mission complete scene...")
		get_tree().paused = false
		get_tree().change_scene_to_file("res://Scene/missionComplete2.tscn")
		return
	
	# Play sound and increase game speed every 100 points
	if score % 100 == 0 and score > 0:
		# Play the 100 score sound effect
		var sound_fx = get_node_or_null("./100ScoreFx")
		if sound_fx and sound_fx is AudioStreamPlayer:
			sound_fx.play()
			print("Playing 100 score sound effect at score: ", score)
		else:
			print("Warning: 100ScoreFx AudioStreamPlayer not found!")
		
		game_speed += 0.2
		print("Game speed increased to: ", game_speed)
		
		# Update obstacle spawner timing if it exists
		if obstacle_spawner and obstacle_spawner.has_method("increase_speed"):
			obstacle_spawner.increase_speed(game_speed)
		
		# Make all current obstacles go faster
		get_tree().call_group("obstacles", "set_speed", base_obstacle_speed * game_speed)

func get_current_obstacle_speed():
	return base_obstacle_speed * game_speed

func game_over():
	print("Game Over! Final Score: ", score)
	
	# Mark game as over to stop all game mechanics
	is_game_over = true
	
	# Stop obstacle spawner
	if obstacle_spawner and obstacle_spawner.has_method("stop_spawning"):
		obstacle_spawner.stop_spawning()
	
	# Stop/freeze all obstacles
	get_tree().call_group("obstacles", "stop_movement")
	
	# Stop background scrolling
	get_tree().call_group("background", "stop_scrolling")
	
	# Stop any other moving elements
	get_tree().call_group("moving_elements", "stop_movement")
	
	print("All game elements stopped")
	
	# Show game over screen
	_show_game_over_menu()

func _on_pause_pressed():
	# Don't allow pause if game is over
	if is_game_over:
		return
		
	print("Pausing game...")
	get_tree().paused = true
	pause_button.hide()
	
	# Use the stored UI layer reference
	if not ui_layer:
		print("ERROR: UI Layer not found!")
		return
	
	# Create pause menu container
	pause_menu_container = Control.new()
	pause_menu_container.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	pause_menu_container.set_meta("is_pause_menu", true)
	ui_layer.add_child(pause_menu_container)
	
	# Create dark overlay
	overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.7)
	overlay.size = get_viewport().size
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_menu_container.add_child(overlay)
	
	# Create menu panel
	menu_panel = Panel.new()
	menu_panel.size = Vector2(300, 350)
	var viewport_size = get_viewport().size
	menu_panel.position = Vector2(
		(viewport_size.x - menu_panel.size.x) / 2,
		(viewport_size.y - menu_panel.size.y) / 2
	)
	pause_menu_container.add_child(menu_panel)
	
	# Create title
	var title = Label.new()
	title.text = "PAUSED"
	title.add_theme_font_size_override("font_size", 32)
	title.position = Vector2(menu_panel.size.x/2 - 60, 30)
	menu_panel.add_child(title)
	
	# Create Resume button
	resume_btn = Button.new()
	resume_btn.text = "RESUME"
	resume_btn.position = Vector2(50, 100)
	resume_btn.size = Vector2(200, 50)
	resume_btn.add_theme_font_size_override("font_size", 18)
	menu_panel.add_child(resume_btn)
	resume_btn.pressed.connect(_on_resume_pressed)
	
	# Create Restart button
	restart_btn = Button.new()
	restart_btn.text = "RESTART"
	restart_btn.position = Vector2(50, 170)
	restart_btn.size = Vector2(200, 50)
	restart_btn.add_theme_font_size_override("font_size", 18)
	menu_panel.add_child(restart_btn)
	restart_btn.pressed.connect(_on_restart_pressed)
	
	# Create Main Menu button
	main_menu_btn = Button.new()
	main_menu_btn.text = "MAIN MENU"
	main_menu_btn.position = Vector2(50, 240)
	main_menu_btn.size = Vector2(200, 50)
	main_menu_btn.add_theme_font_size_override("font_size", 18)
	menu_panel.add_child(main_menu_btn)
	main_menu_btn.pressed.connect(_on_main_menu_pressed)

func _on_resume_pressed():
	print("Resuming game...")
	get_tree().paused = false
	if pause_menu_container:
		pause_menu_container.queue_free()
	pause_button.show()

func _on_restart_pressed():
	print("Restarting game...")
	
	# Reset game over state
	is_game_over = false
	
	# Force remove all UI elements
	if ui_layer and is_instance_valid(ui_layer):
		ui_layer.queue_free()
		ui_layer = null
	
	# Also try to find and remove any lingering UI layers
	var existing_ui = get_parent().get_node_or_null("UILayer")
	if existing_ui:
		existing_ui.queue_free()
	
	# Unpause the game
	get_tree().paused = false
	
	# Reload the scene immediately
	get_tree().reload_current_scene()

func _on_main_menu_pressed():
	print("Going to main menu...")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scene/mainmenu.tscn")

func _show_game_over_menu():
	# Hide pause button when game over
	if pause_button:
		pause_button.hide()
	
	# Use the stored UI layer reference
	if not ui_layer:
		print("ERROR: UI Layer not found for game over menu!")
		return
	
	# Create game over container
	var game_over_container = Control.new()
	game_over_container.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	ui_layer.add_child(game_over_container)
	
	# Create dark overlay
	var go_overlay = ColorRect.new()
	go_overlay.color = Color(0, 0, 0, 0.8)
	go_overlay.size = get_viewport().size
	go_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	game_over_container.add_child(go_overlay)
	
	# Create game over panel
	var go_panel = Panel.new()
	go_panel.size = Vector2(400, 350)
	var viewport_size = get_viewport().size
	go_panel.position = Vector2(
		(viewport_size.x - go_panel.size.x) / 2,
		(viewport_size.y - go_panel.size.y) / 2
	)
	game_over_container.add_child(go_panel)
	
	# Game over title
	var go_title = Label.new()
	go_title.text = "GAME OVER"
	go_title.add_theme_font_size_override("font_size", 36)
	go_title.position = Vector2(go_panel.size.x/2 - 100, 30)
	go_panel.add_child(go_title)
	
	# Score display
	var score_display = Label.new()
	score_display.text = "Final Score: " + str(score)
	score_display.add_theme_font_size_override("font_size", 24)
	score_display.position = Vector2(go_panel.size.x/2 - 80, 100)
	go_panel.add_child(score_display)
	
	# Restart button
	var go_restart = Button.new()
	go_restart.text = "RESTART"
	go_restart.position = Vector2(100, 180)
	go_restart.size = Vector2(200, 50)
	go_restart.add_theme_font_size_override("font_size", 18)
	go_panel.add_child(go_restart)
	go_restart.pressed.connect(_on_restart_pressed)
	
	# Main Menu button
	var go_main_menu = Button.new()
	go_main_menu.text = "MAIN MENU"
	go_main_menu.position = Vector2(100, 250)
	go_main_menu.size = Vector2(200, 50)
	go_main_menu.add_theme_font_size_override("font_size", 18)
	go_panel.add_child(go_main_menu)
	go_main_menu.pressed.connect(_on_game_over_main_menu)
	
	# Pause the game
	get_tree().paused = true

func _on_game_over_main_menu():
	print("Going to main menu from game over...")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scene/mainmenu.tscn")

# Handle ESC key for pause
func _input(event):
	# Don't allow pause input if game is over
	if is_game_over:
		return
		
	# Debug mouse clicks
	if event is InputEventMouseButton and event.pressed:
		print("Mouse clicked at: ", event.position)
		if pause_button and pause_button.visible:
			var button_rect = Rect2(pause_button.global_position, pause_button.size)
			print("Button rect: ", button_rect)
			if button_rect.has_point(event.position):
				print("Click is within button bounds!")
	
	if event.is_action_pressed("ui_cancel") and not get_tree().paused:
		_on_pause_pressed()
	elif event.is_action_pressed("ui_cancel") and get_tree().paused and pause_menu_container:
		_on_resume_pressed()

func _exit_tree():
	# Clean up when scene is being freed
	if pause_menu_container and is_instance_valid(pause_menu_container):
		pause_menu_container.queue_free()
	if ui_layer and is_instance_valid(ui_layer):
		ui_layer.queue_free()
