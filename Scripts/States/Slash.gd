extends State

const FRICTION = 25.0 # Fast deceleration so they stop cleanly

# Option A: Assign your Hitbox node via the Inspector on the Slash state node
@export var hitbox: Area3D 

# Option B: Or use @onready if the hitbox is attached to the player (adjust path if needed)
# @onready var hitbox: Area3D = player.get_node("Weapon/Hitbox")

func enter() -> void:
	anim.play("Slash")
	
	# Enable hitbox and clear previous hit history
	if hitbox:
		if hitbox.has_method("reset_hits"):
			hitbox.reset_hits()
		hitbox.monitoring = true
	
	# Connect the finished signal to a local callback function
	anim.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)

func physics_update(delta: float) -> void:
	apply_gravity(delta)
	
	if DialogueManager.is_dialog_active:
		return
	
	player.velocity.x = move_toward(player.velocity.x, 0, FRICTION * delta)
	player.velocity.z = move_toward(player.velocity.z, 0, FRICTION * delta)
	
	player.move_and_slide()

func exit() -> void:
	# Disable hitbox as soon as we leave the attack state
	if hitbox:
		hitbox.monitoring = false

	# Clean up signal connection if state changes early (e.g. taking damage)
	if anim.animation_finished.is_connected(_on_animation_finished):
		anim.animation_finished.disconnect(_on_animation_finished)

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Slash":
		machine.change_state("idle")
