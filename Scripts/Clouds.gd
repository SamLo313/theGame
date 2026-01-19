extends Node3D

@export var player: Node3D  # Drag your player here in the inspector
@export var height_offset: float = 10.0  # How high above player

func _process(delta):
	if player:
		global_position = player.global_position
		global_position.y += height_offset
