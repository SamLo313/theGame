extends Control

@onready var panel := $CanvasLayer/CenterContainer

func _ready() -> void:
	GameState.current = GameState.State.PAUSED
	panel.hide()
	$CanvasLayer/CenterContainer/VBoxContainer/ResumeButton.pressed.connect(_on_resume)
	$CanvasLayer/CenterContainer/VBoxContainer/QuitToMenuButton.pressed.connect(_on_quit_to_menu)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()

func _toggle_pause() -> void:
	GameState.current = GameState.State.PLAYING
	get_tree().paused = not get_tree().paused
	panel.visible = get_tree().paused

func _on_resume() -> void:
	_toggle_pause()

func _on_quit_to_menu() -> void:
	GameState.current = GameState.State.MENU
	get_tree().paused = false
	DialogueManager.hide()
	panel.hide()
	get_tree().change_scene_to_file("res://UI/mainMenu.tscn")
