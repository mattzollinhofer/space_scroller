extends CanvasLayer
## Pause menu overlay that displays when the player pauses the game.
## Pauses the game tree when shown. Provides Resume and Quit to Menu options.


## Reference to resume button
@onready var _resume_button: Button = $CenterContainer/VBoxContainer/ResumeButton

## Reference to mute button
@onready var _mute_button: Button = $CenterContainer/VBoxContainer/MuteButton

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
	if _mute_button:
		_mute_button.pressed.connect(_on_mute_button_pressed)
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
	_update_mute_button_text()
	visible = true
	get_tree().paused = true


## Hide the pause menu and resume the game
func hide_pause_menu() -> void:
	visible = false
	get_tree().paused = false


## Resume button pressed handler
func _on_resume_button_pressed() -> void:
	_play_sfx("button_click")
	hide_pause_menu()


## Quit to menu button pressed handler
func _on_quit_button_pressed() -> void:
	_play_sfx("button_click")
	# Unpause before changing scene
	get_tree().paused = false
	# Stop music before returning to menu
	_stop_gameplay_music()
	if has_node("/root/TransitionManager"):
		var transition_manager = get_node("/root/TransitionManager")
		transition_manager.transition_to_scene("res://scenes/ui/main_menu.tscn")
	else:
		# Fallback to instant transition
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


## Stop gameplay music via AudioManager
func _stop_gameplay_music() -> void:
	if has_node("/root/AudioManager"):
		var audio_manager = get_node("/root/AudioManager")
		if audio_manager.has_method("stop_music"):
			audio_manager.stop_music()


## Mute button pressed handler
func _on_mute_button_pressed() -> void:
	_play_sfx("button_click")
	if has_node("/root/AudioManager"):
		var audio_manager = get_node("/root/AudioManager")
		if audio_manager.has_method("toggle_mute"):
			audio_manager.toggle_mute()
			_update_mute_button_text()


## Update mute button text based on current state
func _update_mute_button_text() -> void:
	if not _mute_button:
		return
	if has_node("/root/AudioManager"):
		var audio_manager = get_node("/root/AudioManager")
		if audio_manager.has_method("is_muted"):
			if audio_manager.is_muted():
				_mute_button.text = "Unmute Audio"
			else:
				_mute_button.text = "Mute Audio"


## Play a sound effect via AudioManager
func _play_sfx(sfx_name: String) -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx(sfx_name)
