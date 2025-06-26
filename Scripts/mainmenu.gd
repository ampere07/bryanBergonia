extends Node2D

var controls_panel

func _ready():
	# Create the controls panel but keep it hidden initially
	create_controls_panel()

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/main_scene.tscn")

func _on_controls_pressed() -> void:
	controls_panel.visible = true

func _on_quit_pressed() -> void:
	get_tree().quit()

func create_controls_panel():
	# Create main panel that covers the whole screen
	controls_panel = ColorRect.new()
	controls_panel.color = Color(0, 0, 0, 0.8)  # Semi-transparent black background
	controls_panel.size = Vector2(1152, 648)
	controls_panel.position = Vector2(0, 0)
	controls_panel.visible = false
	add_child(controls_panel)
	
	# Create the content panel
	var panel_container = PanelContainer.new()
	panel_container.position = Vector2(376, 174)  # Centered: (1152-400)/2, (648-300)/2
	panel_container.size = Vector2(400, 300)
	controls_panel.add_child(panel_container)
	
	# Create vertical container for content
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	panel_container.add_child(vbox)
	
	# X button (top right corner)
	var x_button = Button.new()
	x_button.text = "X"
	x_button.custom_minimum_size = Vector2(30, 30)
	x_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	x_button.add_theme_font_size_override("font_size", 18)
	vbox.add_child(x_button)
	
	# Title label
	var title_label = Label.new()
	title_label.text = "CONTROLS"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title_label)
	
	# Controls content label
	var controls_label = Label.new()
	controls_label.text = "Spacebar - Jump\nSpacebar + Spacebar - Double Jump\nEsc - Pause"
	controls_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(controls_label)
	
	# Connect X button signal
	x_button.pressed.connect(_on_close_controls_pressed)

func _on_close_controls_pressed():
	controls_panel.visible = false
