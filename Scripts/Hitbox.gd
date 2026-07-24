class_name Hitbox
extends Area3D

## Base damage dealt by this attack.
@export var damage: float = 10.0

## Force applied to knock the target back upon impact.
@export var knockback_force: float = 8.0

## Tracks which Hurtboxes were already hit during a single swing 
## to prevent multi-hitting the same target every frame.
var hits_recorded: Array[Hurtbox] = []

func _ready() -> void:
	# Listen for when another Area3D enters this Hitbox
	area_entered.connect(_on_area_entered)
	
	# Start disabled so the weapon doesn't deal passive damage
	monitoring = false

func _on_area_entered(area: Area3D) -> void:
	# Only interact with Hurtbox nodes
	if area is Hurtbox:
		var hurtbox := area as Hurtbox
		
		# Skip if we already hit this target during the current attack swing
		if hurtbox in hits_recorded:
			return
			
		hits_recorded.append(hurtbox)
		
		# Direction pointing away from the attack origin toward the hurtbox
		var knockback_direction := (hurtbox.global_position - global_position).normalized()
		var total_knockback := knockback_direction * knockback_force
		
		# Trigger damage and pass knockback data
		hurtbox.take_damage(damage, total_knockback)

## Call this at the start of every attack animation track in AnimationPlayer
func reset_hits() -> void:
	hits_recorded.clear()
