extends CanvasLayer

var pause_button: Button
var pause_menu_container: Control
var overlay: ColorRect
var menu_panel: Panel
var resume_btn: Button
var restart_btn: Button
var main_menu_btn: Button

func _ready():
	# Make sure this layer works when paused
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# Create only the pause button
	pause_button = Button.new()
	pause_button.text = "PAUSE"
	pause_button.position = Vector2(10, 10)
	pause_button.size = Vector2(100, 40)
	pause_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	add_child(pause_button)
	
	# Connect pause button
	pause_button.pressed.connect(_on_pause_pressed)
	
	print("Pause system ready - click PAUSE button")

func _on_pause_pressed():
	print("Creating pause menu...")
	
	# Pause the game
	get_tree().paused = true
	pause_button.hide()
	
	# Create container for everything
	pause_menu_container = Control.new()
	pause_menu_container.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	add_child(pause_menu_container)
	
	# Create dark overlay
	overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.7)
	overlay.size = get_viewport().size
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_menu_container.add_child(overlay)
	
	# Create menu panel
	menu_panel = Panel.new()
	menu_panel.size = Vector2(300, 350)
	menu_panel.position = (get_viewport().size - menu_panel.size) / 2
	pause_menu_container.add_child(menu_panel)
	
	# Create title
	var title = Label.new()
	title.text = "PAUSED"
	title.add_theme_font_size_override("font_size", 32)
	title.position = Vector2(100, 30)
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
	print("Resuming...")
	# Unpause
	get_tree().paused = false
	# Remove the pause menu
	if pause_menu_container:
		pause_menu_container.queue_free()
	# Show pause button again
	pause_button.show()

func _on_restart_pressed():
	print("Restarting...")
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_pressed():
	print("Going to main menu...")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scene/main_scene.tscn")
	print("Add your main menu scene path above")

# Optional: ESC key support
func _input(event):
	if event.is_action_pressed("esc"):
		if get_tree().paused:
			_on_resume_pressed()
		else:
			_on_pause_pressed()
