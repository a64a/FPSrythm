extends Control

@preload a

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")


func _on_check_box_button_down():
	dither.visible = !dither.visible
