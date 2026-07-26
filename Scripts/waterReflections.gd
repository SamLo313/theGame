@tool
extends Node3D

@export_group("Camera & Setup")
@export var main_camera: Camera3D
@export var reflection_camera: Camera3D

@export_group("Exclusions")
@export var water_mesh: VisualInstance3D
@export var ground_mesh: VisualInstance3D

@export_group("Reflection Tweaks")
## Extra pitch tilt applied on top of the mirrored view (local axis, doesn't break the mirror)
@export_range(-45.0, 45.0, 0.5) var pitch_offset_degrees: float = 0.0
@export var depth_offset: float = 0.0

func _ready() -> void:
	if water_mesh:
		water_mesh.layers = 1 << 2  # Layer 3
	if ground_mesh:
		ground_mesh.layers = 1 << 1  # Layer 2
	if reflection_camera:
		reflection_camera.cull_mask = 1 << 0  # Layer 1 only

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if not is_instance_valid(main_camera) or not is_instance_valid(reflection_camera):
		return

	# 1. Match orthographic projection settings
	reflection_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	reflection_camera.size = main_camera.size
	reflection_camera.near = 0.01
	reflection_camera.far = main_camera.far

	# 2. True mirror reflection across the horizontal water plane.
	# Doing this with Euler angles (negate pitch/yaw + force 180 roll) can't
	# correctly represent a mirror (determinant -1) for a general camera
	# orientation - it's why left/right ends up flipped. Reflecting the
	# actual transform (origin + basis) is exact and avoids that entirely.
	var normal := Vector3.UP
	var plane_d := normal.dot(global_position)

	var cam_t := main_camera.global_transform

	# Reflect position across the plane
	var dist := normal.dot(cam_t.origin) - plane_d
	var reflected_origin := cam_t.origin - normal * (2.0 * dist)
	reflected_origin.y -= depth_offset

	# Reflect each basis axis (these are directions, so no plane offset needed)
	var rx := cam_t.basis.x - normal * (2.0 * normal.dot(cam_t.basis.x))
	var ry := cam_t.basis.y - normal * (2.0 * normal.dot(cam_t.basis.y))
	var rz := cam_t.basis.z - normal * (2.0 * normal.dot(cam_t.basis.z))

	reflection_camera.global_transform = Transform3D(Basis(rx, ry, rz), reflected_origin)

	# 3. Optional manual pitch tweak - rotate around the camera's own local
	# right axis so it doesn't disturb the mirror math above.
	if pitch_offset_degrees != 0.0:
		reflection_camera.rotate_object_local(Vector3.RIGHT, deg_to_rad(pitch_offset_degrees))
