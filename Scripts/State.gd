extends Node
class_name State

var player: CharacterBody3D
var skin: Node3D
var anim: AnimationPlayer
var anim_state: AnimationNodeStateMachinePlayback
var machine

func enter(): 
	pass

func exit(): 
	pass

func physics_update(_delta): 
	pass

func apply_gravity(delta):
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
