extends Button
## Pause button in the top-right corner of the gameplay screen.
## Tapping it opens the pause menu, mirroring the keyboard pause action.


## Signal emitted when the pause button is pressed
signal pause_pressed


func _ready() -> void:
	# Keep working even while the tree is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	pause_pressed.emit()
	# Drive the same "pause" action the keyboard uses so the pause menu toggles
	var pause_event := InputEventAction.new()
	pause_event.action = "pause"
	pause_event.pressed = true
	Input.parse_input_event(pause_event)
