# Camera Pivot Script
extends Node3D

@export var rotation_speed = 2.5
@export var camera_rotation_degrees = 90
@export var zoom_speed = 10.0
@export var min_zoom = 5.0
@export var max_zoom = 20.0
@export var follow_speed = 5.0

@onready var camera: Camera3D = $Camera

var target_rotation
var target_zoom = 11.0
var target_position: Vector3

func _ready():
	top_level = true
	target_rotation = -0.7853
	target_position = get_parent().global_position

func _process(delta):
	target_position = get_parent().global_position
	
	global_position = global_position.lerp(target_position, follow_speed * delta)
	
	if Input.is_action_just_pressed("camera_left"):
		target_rotation -= deg_to_rad(camera_rotation_degrees)
	if Input.is_action_just_pressed("camera_right"):
		target_rotation += deg_to_rad(camera_rotation_degrees)
	
	rotation.y = lerp_angle(rotation.y, target_rotation, rotation_speed * delta)
	
	if camera and camera.projection == Camera3D.PROJECTION_ORTHOGONAL:
		camera.size = lerp(camera.size, target_zoom, zoom_speed * delta)
	
func _input(event):
	if camera and event is InputEventMouseButton and camera.projection == Camera3D.PROJECTION_ORTHOGONAL:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			target_zoom -= 2.0
			target_zoom = clamp(target_zoom, min_zoom, max_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			target_zoom += 2.0
			target_zoom = clamp(target_zoom, min_zoom, max_zoom)
