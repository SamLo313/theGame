extends CanvasLayer

@onready var dialog_panel = $Panel
@onready var next_button: Button = $Panel/NextButton
@onready var text_label: Label = $Panel/TextLabel
@onready var name_label: Label = $Panel/NameLabel
@onready var anim_player: AnimationPlayer = $Panel/AnimationPlayer

var is_dialog_active = false
var current_callback: Callable
var is_first_line = true

func _ready():
	dialog_panel.visible = false
	next_button.pressed.connect(_on_next_button_pressed)

func _on_next_button_pressed():
	if current_callback:
		current_callback.call()

func display_text(npc_name: String, text: String, on_continue: Callable = Callable()):
	name_label.text = npc_name
	text_label.text = text
	is_dialog_active = true
	current_callback = on_continue
	
	if is_first_line:
		anim_player.play("dialogue")
		is_first_line = false
	else:
		anim_player.play("dialogue_next")
	

func hide_dialog():
	anim_player.play("dialogue_end")
	await anim_player.animation_finished
	
	dialog_panel.visible = false
	is_dialog_active = false
	current_callback = Callable()
	is_first_line = true
