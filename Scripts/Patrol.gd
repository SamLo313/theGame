extends State

var enemy

func enter() -> void:
	enemy = player
	anim.play("Idle")
	

func physics_update(delta: float) -> void:
	apply_gravity(delta)
	
	enemy.move_and_slide()
