extends Node

# Path to the map scene you want loaded on startup
@export_file("*.tscn") var default_map_path: String = "res://Maps/testMechanics.tscn"

@onready var map_container: Node3D = $SubViewportContainer/SubViewport/MapContainer

func _ready() -> void:
	load_map(default_map_path)

func load_map(path: String) -> void:
	# Load and instantiate the map scene
	var map_resource = load(path)
	if map_resource:
		var map_instance = map_resource.instantiate()
		map_container.add_child(map_instance)
	else:
		push_error("Failed to load map at: " + path)
