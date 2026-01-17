extends CharacterBody3D

@export var npc_name: String = "Villager"
@export var dialogue_lines: Array[String] = [
	"Hello traveler!",
	"Welcome to our village.",
	"Be careful out there!"
]

var current_line = 0
var player_in_range = false

func _ready():
	# Make sure your NPC has an Area3D child for detection
	$Area3D.body_entered.connect(_on_body_entered)
	$Area3D.body_exited.connect(_on_body_exited)

func _input(event):
	if event.is_action_pressed("interact") and player_in_range and not DialogueManager.is_dialog_active:
		start_dialogue()

func start_dialogue():
	current_line = 0
	show_next_line()

func show_next_line():
	if current_line < dialogue_lines.size():
		DialogueManager.display_text(npc_name, dialogue_lines[current_line], show_next_line)
		current_line += 1
	else:
		DialogueManager.hide_dialog()
		current_line = 0

func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = true

func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false
