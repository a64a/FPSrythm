extends Control

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes/Root.tscn")


func _on_options_pressed():
	get_tree().change_scene_to_file("res://Scenes/options.tscn")


func _on_quit_pressed():
	get_tree().quit()
