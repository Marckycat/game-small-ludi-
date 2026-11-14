extends Control



func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Escenas/Test_gameplay.tscn")


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Escenas/Options.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
