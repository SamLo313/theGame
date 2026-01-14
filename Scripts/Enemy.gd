extends CharacterBody3D

@export var speed = 3.0
@export var chase_speed = 5.0
@export var patrol_points: Array[Node3D] = []
@export var detection_range = 10.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var detection_area: Area3D = $DetectionArea
@onready var state_machine: StateMachine = $StateMachine

var player = null
var current_patrol_index = 0

func _ready():
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	
	var collision_shape = detection_area.get_child(0)
	if collision_shape is CollisionShape3D:
		collision_shape.shape.radius = detection_range
	
	if patrol_points.is_empty():
		_generate_default_patrol_points()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body
		state_machine.change_state("Chase")

func _on_body_exited(body):
	if body.is_in_group("player") and body == player:
		player = null
		state_machine.change_state("Patrol")

func _generate_default_patrol_points():
	var spawn_pos = global_position
	for i in range(4):
		var marker = Node3D.new()
		var angle = i * PI / 2
		var offset = Vector3(cos(angle) * 5, 0, sin(angle) * 5)
		marker.global_position = spawn_pos + offset
		add_child(marker)
		patrol_points.append(marker)
