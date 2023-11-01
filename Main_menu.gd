extends Control

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes/Map_assets/Root.tscn")


func _on_options_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menus/options.tscn")


func _on_quit_pressed():
	get_tree().quit()


func _on_authors_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menus/authors.tscn")
