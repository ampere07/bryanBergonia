extends CanvasLayer

var pause_button: Button
var pause_menu_panel: Panel
var resume_button: Button
var restart_button: Button
var main_menu_button: Button
var background_overlay: ColorRect

func _ready():
	# Set this node to work when paused
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# Create pause button (top-left corner)
	pause_button = Button.new()
	pause_button.text = "||"
	pause_button.position = Vector2(10, 10)
	pause_button.size = Vector2(50, 50)
	pause_button.add_theme_font_size_override("font_size", 16)
	add_child(pause_button)
	
	# Create background overlay (dark semi-transparent)
	background_overlay = ColorRect.new()
	background_overlay.color = Color(0, 0, 0, 0.7)  # Black with 70% opacity
	background_overlay.size = get_viewport().size
	background_overlay.mouse_filter = Control.MOUSE_FILTER_STOP  # Block clicks
	background_overlay.hide()
	add_child(background_overlay)
	
	# Create pause menu panel
	pause_menu_panel = Panel.new()
	pause_menu_panel.size = Vector2(300, 400)
	var viewport_size = get_viewport().size
	pause_menu_panel.position = Vector2(
		(viewport_size.x - pause_menu_panel.size.x) / 2,
		(viewport_size.y - pause_menu_panel.size.y) / 2
	)
	pause_menu_panel.hide()
	add_child(pause_menu_panel)
	
	# Create VBoxContainer for menu items
	var vbox = VBoxContainer.new()
	vbox.position = Vector2(20, 20)
	vbox.size = pause_menu_panel.size - Vector2(40, 40)
	vbox.add_theme_constant_override("separation", 20)
	pause_menu_panel.add_child(vbox)
	
	# Create title label
	var title_label = Label.new()
	title_label.text = "PAUSED"
	title_label.add_theme_font_size_override("font_size", 32)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title_label)
	
	# Add spacer
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 30
	vbox.add_child(spacer)
	
	# Create Resume button
	resume_button = Button.new()
	resume_button.text = "RESUME"
	resume_button.custom_minimum_size = Vector2(0, 50)
	resume_button.add_theme_font_size_override("font_size", 20)
	vbox.add_child(resume_button)
	
	# Create Restart button
	restart_button = Button.new()
	restart_button.text = "RESTART"
	restart_button.custom_minimum_size = Vector2(0, 50)
	restart_button.add_theme_font_size_override("font_size", 20)
	vbox.add_child(restart_button)
	
	# Create Main Menu button
	main_menu_button = Button.new()
	main_menu_button.text = "MAIN MENU"
	main_menu_button.custom_minimum_size = Vector2(0, 50)
	main_menu_button.add_theme_font_size_override("font_size", 20)
	vbox.add_child(main_menu_button)
	
	# Connect button signals
	pause_button.pressed.connect(_on_pause_pressed)
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	
	# Set process modes for pause functionality
	pause_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	background_overlay.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	pause_menu_panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _on_pause_pressed():
	get_tree().paused = true
	pause_menu_panel.show()
	background_overlay.show()
	pause_button.hide()

func _on_resume_pressed():
	get_tree().paused = false
	pause_menu_panel.hide()
	background_overlay.hide()
	pause_button.show()

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_pressed():
	get_tree().paused = false
	# Change to your main menu scene path
	# get_tree().change_scene_to_file("res://main_menu.tscn")
	print("Main menu pressed - add your main menu scene path")

# Optional: ESC key to pause/resume
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			_on_resume_pressed()
		else:
			_on_pause_pressed()
