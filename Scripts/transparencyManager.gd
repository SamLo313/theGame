# WallTransparencyManager.gd
extends Node

var player: CharacterBody3D
var camera: Camera3D

func _ready() -> void:
	await get_tree().process_frame
	#player = get_tree().current_scene.get_node_or_null("SubViewportContainer/SubViewport/Player")
	player = get_tree().current_scene.get_node_or_null("Player")
	
	if player:
		camera = player.get_node_or_null("CameraPivot/Camera")
		
	if not player:
		print("Error in transparencyManager: missing player")
	if not camera:
		print("Error in transparencyManager: missing camera")


func _process(delta: float) -> void:
	
	var camera_forward = camera.global_transform.basis.z
	var screen_pos = camera.unproject_position(player.global_position + Vector3.UP * 1.25)
	var viewport_size = get_tree().root.get_visible_rect().size
	var screen_uv = screen_pos / viewport_size
	var player_pos = player.global_transform.origin
	
	# Get all meshes in the "transparent_wall" group
	var transparent_meshes = get_tree().get_nodes_in_group("transparent_wall")
	
	for mesh in transparent_meshes:
		if mesh is MeshInstance3D and mesh.material_override:
			mesh.material_override.set_shader_parameter("player_screen_pos", screen_uv)
			mesh.material_override.set_shader_parameter("player_position", player_pos)
			mesh.material_override.set_shader_parameter("camera_forward", camera_forward)
