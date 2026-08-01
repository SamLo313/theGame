class_name Player
extends CharacterBody3D

signal health_changed(current_hp: float, max_hp: float)
signal died

@export_group("Stats")
@export var max_hp: float = 100.0

var state_machine: Node
var hurtbox: Area3D
var animation_player: AnimationPlayer

var current_hp: float

func _ready() -> void:
	current_hp = max_hp
	
	if hurtbox:
		hurtbox.received_damage.connect(_on_received_damage)

## Called automatically when the Hurtbox detects a Hitbox
func _on_received_damage(amount: float, knockback: Vector3) -> void:
	if current_hp <= 0:
		return
		
	current_hp = max(0.0, current_hp - amount)
	health_changed.emit(current_hp, max_hp)
	
	# Pass physical knockback directly to CharacterBody3D velocity
	velocity += knockback
	
	if current_hp <= 0:
		_die()
	elif state_machine:
		state_machine.change_state("hurt")

func _die() -> void:
	died.emit()
	if state_machine:
		state_machine.change_state("dead")
