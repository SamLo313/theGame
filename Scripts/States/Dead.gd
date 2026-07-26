extends State

func enter() -> void:
	anim.play("Dying")
	player.velocity.x = 0
	player.velocity.y = 0

func physics_update(delta: float) -> void:
	apply_gravity(delta)

	player.move_and_slide()
