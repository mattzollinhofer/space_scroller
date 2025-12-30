extends Control
## Fire button for touch input on mobile devices.
## Covers the right side of the screen and detects touch/click to fire.
## Player script queries is_pressed() to check if firing should occur.

## Whether the fire button is currently being pressed
var _is_pressed: bool = false

## Touch index being tracked (-1 if using mouse, -2 if not active)
var _touch_index: int = -2


func _ready() -> void:
	# Set up the control to cover the right half of the screen
	# This will be configured in the scene file using anchors
	pass


func _input(event: InputEvent) -> void:
	# Handle touch events
	if event is InputEventScreenTouch:
		_handle_touch(event)
	# Also support mouse for testing on desktop
	elif event is InputEventMouseButton:
		_handle_mouse_button(event)


func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		# Check if touch is within the fire button area
		var local_pos = _get_local_position(event.position)
		if _is_within_bounds(local_pos):
			_is_pressed = true
			_touch_index = event.index
	else:
		# Touch released
		if event.index == _touch_index:
			_reset()


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var local_pos = _get_local_position(event.position)
			if _is_within_bounds(local_pos):
				_is_pressed = true
				_touch_index = -1  # -1 indicates mouse
		else:
			if _touch_index == -1:
				_reset()


func _get_local_position(global_pos: Vector2) -> Vector2:
	return global_pos - global_position


func _is_within_bounds(local_pos: Vector2) -> bool:
	# Check if the position is within the control's bounds
	return local_pos.x >= 0 and local_pos.x <= size.x and \
		   local_pos.y >= 0 and local_pos.y <= size.y


func _reset() -> void:
	_is_pressed = false
	_touch_index = -2


## Returns whether the fire button is currently pressed.
## Called by the player script to check if firing should occur.
func is_pressed() -> bool:
	return _is_pressed


## Test helper: Simulate pressing or releasing the fire button
func _simulate_press(pressed: bool) -> void:
	_is_pressed = pressed
	if pressed:
		_touch_index = -1  # Simulate mouse press
	else:
		_touch_index = -2
