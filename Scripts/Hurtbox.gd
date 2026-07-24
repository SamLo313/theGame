class_name Hurtbox
extends Area3D

## Emitted when a Hitbox successfully deals damage to this Hurtbox.
signal received_damage(amount: float, knockback: Vector3)

## When active, incoming attacks are completely ignored.
@export var is_invincible: bool = false:
	set(value):
		is_invincible = value
		# Automatically disable/enable collision detection to save performance
		set_deferred("monitoring", not is_invincible)
		set_deferred("monitorable", not is_invincible)

@export_group("I-Frames")
## Optional timer to temporarily grant invincibility after getting hit.
@export var iframe_timer: Timer

func _ready() -> void:
	# Ensure the Hurtbox only detects incoming Area3D nodes (Hitboxes)
	if iframe_timer:
		iframe_timer.timeout.connect(_on_iframe_timeout)

## Called by incoming Hitbox scripts or area_entered detection
func take_damage(amount: float, knockback_vector: Vector3 = Vector3.ZERO) -> void:
	# Ignore hits if we are currently invincible
	if is_invincible:
		return
		
	received_damage.emit(amount, knockback_vector)
	
	# Trigger temporary invincibility if a Timer is assigned
	if iframe_timer and iframe_timer.wait_time > 0:
		is_invincible = true
		iframe_timer.start()

func _on_iframe_timeout() -> void:
	is_invincible = false
