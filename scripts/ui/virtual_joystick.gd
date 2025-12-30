extends Control
## Virtual joystick for touch input on mobile devices.
## Provides a normalized direction vector that the player script can read.

## Radius of the joystick base in pixels
@export var joystick_radius: float = 100.0

## Radius of the thumb (inner circle) in pixels
@export var thumb_radius: float = 40.0

## Color of the joystick base (semi-transparent)
@export var base_color: Color = Color(0.3, 0.3, 0.3, 0.5)

## Color of the thumb indicator
@export var thumb_color: Color = Color(0.7, 0.7, 0.7, 0.8)

## Current input direction (normalized, or zero if not touching)
var _direction: Vector2 = Vector2.ZERO

## Whether the joystick is currently being touched
var _is_active: bool = false

## Touch index being tracked (-1 if using mouse)
var _touch_index: int = -1

## Center position of the joystick in local coordinates
var _center: Vector2 = Vector2.ZERO

## Current thumb position offset from center
var _thumb_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	# Calculate center based on the control's size
	_center = Vector2(joystick_radius, joystick_radius)
	# Set minimum size to contain the joystick
	custom_minimum_size = Vector2(joystick_radius * 2, joystick_radius * 2)


func _draw() -> void:
	# Draw the base circle
	draw_circle(_center, joystick_radius, base_color)
	# Draw the thumb at its current position
	draw_circle(_center + _thumb_offset, thumb_radius, thumb_color)


func _input(event: InputEvent) -> void:
	# Handle touch events
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)
	# Also support mouse for testing on desktop
	elif event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion and _is_active and _touch_index == -1:
		_handle_mouse_motion(event)


func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		# Check if touch is within the joystick area
		var local_pos = _get_local_position(event.position)
		if _is_within_joystick(local_pos):
			_is_active = true
			_touch_index = event.index
			_update_direction(local_pos)
	else:
		# Touch released
		if event.index == _touch_index:
			_reset_joystick()


func _handle_drag(event: InputEventScreenDrag) -> void:
	if _is_active and event.index == _touch_index:
		var local_pos = _get_local_position(event.position)
		_update_direction(local_pos)


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var local_pos = _get_local_position(event.position)
			if _is_within_joystick(local_pos):
				_is_active = true
				_touch_index = -1  # -1 indicates mouse
				_update_direction(local_pos)
		else:
			if _touch_index == -1:
				_reset_joystick()


func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	var local_pos = _get_local_position(event.position)
	_update_direction(local_pos)


func _get_local_position(global_pos: Vector2) -> Vector2:
	return global_pos - global_position


func _is_within_joystick(local_pos: Vector2) -> bool:
	return local_pos.distance_to(_center) <= joystick_radius


func _update_direction(local_pos: Vector2) -> void:
	var offset = local_pos - _center
	var distance = offset.length()

	# Clamp the offset to the joystick radius
	if distance > joystick_radius:
		offset = offset.normalized() * joystick_radius

	_thumb_offset = offset

	# Calculate normalized direction
	if distance > 0:
		_direction = offset / joystick_radius
	else:
		_direction = Vector2.ZERO

	queue_redraw()


func _reset_joystick() -> void:
	_is_active = false
	_touch_index = -1
	_direction = Vector2.ZERO
	_thumb_offset = Vector2.ZERO
	queue_redraw()


## Returns the current input direction as a normalized vector.
## Called by the player script to get joystick input.
func get_direction() -> Vector2:
	return _direction
