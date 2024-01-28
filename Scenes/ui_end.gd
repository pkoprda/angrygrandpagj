extends Control


func _ready():
	$end_game_screen/VBoxContainer/RestartButton.grab_focus()

func _on_restart_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Main/Main.tscn")

func _on_return_to_menu_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/ui.tscn")
