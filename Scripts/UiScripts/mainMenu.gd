extends Control

func _ready() -> void:
	$CenterContainer/VBoxContainer/NewGameButton.pressed.connect(_on_new_game)
	$CenterContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit)

func _on_new_game() -> void:
	get_tree().change_scene_to_file("res://Maps/testVisuals.tscn")

func _on_quit() -> void:
	get_tree().quit()
