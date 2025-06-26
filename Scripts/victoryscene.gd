extends Node2D


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/mainmenu.tscn")


func _on_restart_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/main_scene.tscn")
