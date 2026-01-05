extends State

const SPEED = 5.0
const ROTATE_SPEED = 10.0
const ACCELERATION = 20.0
const FRICTION = 15.0

@onready var camera_pivot: Node3D = get_node_or_null("../../CameraPivot")

func enter() -> void:
		anim.play("Walk")

func physics_update(delta: float) -> void:
	apply_gravity(delta)
	
	var input_dir := Input.get_vector("left", "right", "up", "down")
	
	if input_dir.length() < 0.1:
		player.velocity.x = move_toward(player.velocity.x, 0, FRICTION * delta)
		player.velocity.z = move_toward(player.velocity.z, 0, FRICTION * delta)
		
		if player.velocity.length() < 0.1:
			player.velocity.x = 0
			player.velocity.z = 0
			machine.change_state("idle")
			player.move_and_slide()
			return
	else:
		var camera_basis := Basis()
		if camera_pivot:
			camera_basis = Basis(Vector3.UP, camera_pivot.rotation.y)
		
		var direction := (camera_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		var target_velocity := direction * SPEED
		player.velocity.x = move_toward(player.velocity.x, target_velocity.x, ACCELERATION * delta)
		player.velocity.z = move_toward(player.velocity.z, target_velocity.z, ACCELERATION * delta)
		
		var target_angle := atan2(direction.x, direction.z)
		player.rotation.y = lerp_angle(player.rotation.y, target_angle, ROTATE_SPEED * delta)
	
	player.move_and_slide()
