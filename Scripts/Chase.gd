extends State

var enemy: CharacterBody3D

func enter() -> void:
	enemy = player  # 'player' variable actually holds enemy reference
	anim.play("Walk")

func physics_update(delta: float) -> void:
	apply_gravity(delta)
	if not enemy.player:
		machine.change_state("Patrol")
		return
	
	# Update target to player position
	enemy.nav_agent.target_position = enemy.player.global_position
	
	var next_pos = enemy.nav_agent.get_next_path_position()
	var direction = (next_pos - enemy.global_position).normalized()
	
	enemy.velocity = direction * enemy.chase_speed
	enemy.look_at(enemy.global_position + direction, Vector3.UP)
	enemy.move_and_slide()
	
	# Check if close enough to attack
	#if enemy.global_position.distance_to(enemy.player.global_position) < 2.0:
	#	machine.change_state("Attack")
