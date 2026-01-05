extends Node
class_name StateMachine

@export var initial_state: NodePath

var current_state: State
var states: Dictionary = {}

var player: CharacterBody3D
var anim: AnimationPlayer

func _ready() -> void:
	# Cache references to player components
	player = get_parent() as CharacterBody3D
	if not player:
		push_error("StateMachine must be a child of CharacterBody3D")
		return
	
	anim = player.get_node_or_null("AnimationPlayer")
	
	await get_tree().process_frame
	
	_register_states()
	_initialize_first_state()

func _register_states() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			_setup_state(child)

func _setup_state(state: State) -> void:
	state.player = player
	state.anim = anim
	state.machine = self

func _initialize_first_state() -> void:
	if initial_state:
		var first_state = get_node_or_null(initial_state)
		if first_state is State:
			current_state = first_state
			current_state.enter()
		else:
			push_error("Invalid initial state: " + str(initial_state))
	elif not states.is_empty():
		current_state = states.values()[0]
		current_state.enter()
		push_warning("No initial state set, using: " + current_state.name)

func change_state(state_name: String) -> void:
	var new_state = states.get(state_name.to_lower())
	
	if new_state == current_state:
		return
	
	if current_state:
		current_state.exit()
	
	current_state = new_state
	current_state.enter()

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)
