extends Node2D

func _on_next_level_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/main_scene2.tscn")

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/mainmenu.tscn")
