# weapon.gd
class_name Weapon
extends Node3D


## Base damage dealt by this weapon.
@export var damage: float = 10.0:
	set(value):
		damage = value
		_update_hitbox_damage()

## Drag and drop your HitboxComponent (Area3D) node here in the Inspector
@export var hitbox: Area3D


func _ready() -> void:
	# If WeaponData resource is assigned, pull stats from it first
	_update_hitbox_damage()


func _update_hitbox_damage() -> void:
	if hitbox:
		# Assumes your HitboxComponent has a 'damage' variable
		hitbox.damage = damage


func execute_attack() -> void:
	# Trigger weapon attack logic (e.g., enable hitbox, play sounds)
	pass
