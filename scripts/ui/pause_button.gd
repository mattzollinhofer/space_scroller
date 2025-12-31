extends Control
## Pause button in top-right corner of gameplay screen.
## Tapping this button triggers the pause menu.


## Signal emitted when pause button is pressed
signal pause_pressed


func _ready() -> void:
	# Set process mode to always, so button works even if paused somehow
	process_mode = Node.PROCESS_MODE_ALWAYS


func _gui_input(event: InputEvent) -> void:
	# Handle touch events on the button
	if event is InputEventScreenTouch:
		if event.pressed:
			_trigger_pause()
			accept_event()
	elif event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_trigger_pause()
			accept_event()


## Trigger the pause action
func _trigger_pause() -> void:
	pause_pressed.emit()
	# Also trigger the pause input action for the pause menu to catch
	var pause_event = InputEventAction.new()
	pause_event.action = "pause"
	pause_event.pressed = true
	Input.parse_input_event(pause_event)
