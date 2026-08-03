extends Control

func _ready() -> void:
	GameState.current = GameState.State.MENU
	$CenterContainer/VBoxContainer/NewGameButton.pressed.connect(_on_new_game)
	$CenterContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit)

func _on_new_game() -> void:
	GameState.current = GameState.State.PLAYING
	get_tree().change_scene_to_file("res://Maps/testMechanics.tscn")

func _on_quit() -> void:
	get_tree().quit()
