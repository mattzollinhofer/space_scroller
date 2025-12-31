extends CanvasLayer
## Pause menu overlay that displays when the player pauses the game.
## Pauses the game tree when shown. Provides Resume and Quit to Menu options.


## Reference to resume button
@onready var _resume_button: Button = $CenterContainer/VBoxContainer/ResumeButton

## Reference to quit button
@onready var _quit_button: Button = $CenterContainer/VBoxContainer/QuitButton


func _ready() -> void:
	# Start hidden
	visible = false
	# Set process mode to continue running when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Connect button signals
	if _resume_button:
		_resume_button.pressed.connect(_on_resume_button_pressed)
	if _quit_button:
		_quit_button.pressed.connect(_on_quit_button_pressed)


func _unhandled_input(event: InputEvent) -> void:
	# Handle P/ESC key toggle
	if event.is_action_pressed("pause"):
		if visible:
			hide_pause_menu()
		else:
			show_pause_menu()
		get_viewport().set_input_as_handled()


## Show the pause menu and pause the game
func show_pause_menu() -> void:
	visible = true
	get_tree().paused = true


## Hide the pause menu and resume the game
func hide_pause_menu() -> void:
	visible = false
	get_tree().paused = false


## Resume button pressed handler
func _on_resume_button_pressed() -> void:
	hide_pause_menu()


## Quit to menu button pressed handler
func _on_quit_button_pressed() -> void:
	# Unpause before changing scene
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
