extends State

func enter() -> void:
	anim.play("Idle")

func physics_update(delta: float) -> void:
	apply_gravity(delta)
	
	if DialogueManager.is_dialog_active:
		return
	
	var input := Input.get_vector("left", "right", "up", "down")
	
	if input.length() > 0.1:
		machine.change_state("walk")
		return
	
	player.velocity.x = move_toward(player.velocity.x, 0, 10.0 * delta)
	player.velocity.z = move_toward(player.velocity.z, 0, 10.0 * delta)
	
	player.move_and_slide()
