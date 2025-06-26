extends Node

var score = 0
var game_speed = 1.0  # Speed multiplier
var base_obstacle_speed = 400.0  # Base speed for obstacles

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
	# Create a CanvasLayer for UI as a sibling of GameManager
	ui_layer = CanvasLayer.new()
	ui_layer.name = "UILayer"
	ui_layer.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	get_parent().call_deferred("add_child", ui_layer)
	
	# Wait for the layer to be added
	await get_tree().process_frame
	
	# Create pause button
	pause_button = Button.new()
	pause_button.text = "PAUSE"
	pause_button.position = Vector2(10, 10)
	pause_button.size = Vector2(100, 40)
	pause_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	pause_button.add_theme_font_size_override("font_size", 16)
	ui_layer.add_child(pause_button)
	
	# Connect pause button
	pause_button.pressed.connect(_on_pause_pressed)
	
	print("Pause button created in GameManager")

func _increase_score():
	score += 1
	if score_label:
		score_label.text = "Score: " + str(score)
	
	# Increase game speed every 100 points
	if score % 100 == 0:
		game_speed += 0.5
		print("Game speed increased to: ", game_speed)

func get_current_obstacle_speed():
	return base_obstacle_speed * game_speed

func game_over():
	print("Game Over! Final Score: ", score)
	# Show game over screen instead of pause menu
	_show_game_over_menu()

func _on_pause_pressed():
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
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_pressed():
	print("Going to main menu...")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scene/main_scene.tscn")

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
	go_panel.size = Vector2(400, 300)
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
	
	# Pause the game
	get_tree().paused = true

# Handle ESC key for pause
func _input(event):
	if event.is_action_pressed("ui_cancel") and not get_tree().paused:
		_on_pause_pressed()
	elif event.is_action_pressed("ui_cancel") and get_tree().paused and pause_menu_container:
		_on_resume_pressed()
