extends Control
## Fire button for touch input on mobile devices.
## Drawn as a clear circular button in the bottom-right corner.
## Player script queries is_pressed() to check if firing should occur.

## Color of the button fill (semi-transparent)
@export var fill_color: Color = Color(0.7, 0.15, 0.15, 0.5)

## Color of the outline ring
@export var ring_color: Color = Color(1, 1, 1, 0.8)

## Color of the inner core
@export var core_color: Color = Color(1, 0.45, 0.3, 0.9)

## Color of the inner core while the button is held
@export var core_pressed_color: Color = Color(1, 0.8, 0.4, 1)

## Whether the fire button is currently being pressed
var _is_pressed: bool = false

## Touch index being tracked (-1 if using mouse, -2 if not active)
var _touch_index: int = -2


func _draw() -> void:
	# Draw a clear circular button centered in the control so it reads as "fire"
	var button_center := size / 2.0
	var radius := minf(size.x, size.y) / 2.0 - 6.0
	draw_circle(button_center, radius, fill_color)
	draw_circle(button_center, radius, ring_color, false, 6.0, true)
	var core := core_pressed_color if _is_pressed else core_color
	draw_circle(button_center, radius * 0.42, core)


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
			queue_redraw()
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
				queue_redraw()
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
	queue_redraw()


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
	queue_redraw()
