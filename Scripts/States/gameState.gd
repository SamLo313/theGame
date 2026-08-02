extends Node

enum State { MENU, PLAYING, PAUSED, DIALOGUE }

var current = State.MENU

func set_state(new_state: State) -> void:
	current = new_state

func is_playing() -> bool:
	return current == State.PLAYING

func is_menu() -> bool:
	return current == State.MENU
