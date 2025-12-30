extends CharacterBody2D
## Player spacecraft with 4-directional movement using keyboard or virtual joystick.
## Movement is snappy with minimal inertia. X-axis clamped to viewport, Y-axis uses collision boundaries.
## Includes lives system with damage handling and invincibility.

## Movement speed in pixels per second
@export var move_speed: float = 600.0

## Starting number of lives
@export var starting_lives: int = 3

## Invincibility duration after taking damage (seconds)
@export var invincibility_duration: float = 1.5

## Flashing interval during invincibility (seconds)
@export var flash_interval: float = 0.1

## Signals
signal damage_taken()
signal lives_changed(new_lives: int)
signal died()

## Reference to virtual joystick (auto-detected from scene tree)
var virtual_joystick: Node = null

## Half the size of the player sprite for viewport clamping
var _half_size: Vector2 = Vector2(32, 32)

## Current lives
var _lives: int = 3

## Invincibility state
var _is_invincible: bool = false
var _invincibility_timer: float = 0.0
var _flash_timer: float = 0.0
var _visible_state: bool = true


func _ready() -> void:
	# Initialize lives
	_lives = starting_lives

	# Get the sprite size for accurate viewport clamping (accounting for scale)
	var sprite = $Sprite2D
	if sprite and sprite.texture:
		_half_size = (sprite.texture.get_size() * sprite.scale) / 2.0

	# Find the virtual joystick in the scene tree
	_find_virtual_joystick()


func _find_virtual_joystick() -> void:
	# Look for VirtualJoystick in the UILayer
	var root = get_tree().root
	var main = root.get_node_or_null("Main")
	if main:
		var ui_layer = main.get_node_or_null("UILayer")
		if ui_layer:
			virtual_joystick = ui_layer.get_node_or_null("VirtualJoystick")


func _physics_process(delta: float) -> void:
	# Handle invincibility timer and flashing
	if _is_invincible:
		_invincibility_timer -= delta
		_flash_timer -= delta

		# Toggle visibility for flashing effect
		if _flash_timer <= 0:
			_flash_timer = flash_interval
			_visible_state = not _visible_state
			_set_player_visibility(_visible_state)

		# End invincibility
		if _invincibility_timer <= 0:
			_end_invincibility()

	# Get keyboard input direction (normalized)
	var keyboard_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# Get joystick input if available
	var joystick_input = Vector2.ZERO
	if virtual_joystick and virtual_joystick.has_method("get_direction"):
		joystick_input = virtual_joystick.get_direction()

	# Combine inputs - use whichever has greater magnitude
	var direction = keyboard_input
	if joystick_input.length() > keyboard_input.length():
		direction = joystick_input

	# Apply snappy movement (immediate velocity, no acceleration/inertia)
	velocity = direction * move_speed

	move_and_slide()

	# Clamp X position to viewport bounds (Y-axis handled by collision boundaries)
	_clamp_to_viewport()


func _clamp_to_viewport() -> void:
	# Get the actual viewport size (not affected by camera)
	var viewport_size = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
	)
	var min_x = _half_size.x
	var max_x = viewport_size.x - _half_size.x

	# Only clamp X-axis - Y-axis is handled by StaticBody2D collision boundaries
	position.x = clamp(position.x, min_x, max_x)


## Called when player takes damage from an obstacle
func take_damage() -> void:
	# Ignore damage while invincible
	if _is_invincible:
		return

	# Reduce lives
	_lives -= 1
	lives_changed.emit(_lives)
	damage_taken.emit()

	# Check for death
	if _lives <= 0:
		died.emit()
		return

	# Start invincibility
	_start_invincibility()


func _start_invincibility() -> void:
	_is_invincible = true
	_invincibility_timer = invincibility_duration
	_flash_timer = flash_interval
	_visible_state = true


func _end_invincibility() -> void:
	_is_invincible = false
	_invincibility_timer = 0.0
	_flash_timer = 0.0
	_visible_state = true
	_set_player_visibility(true)


func _set_player_visibility(is_visible: bool) -> void:
	# Toggle visibility of the sprite
	var sprite = $Sprite2D
	if sprite:
		sprite.visible = is_visible


## Get current lives count
func get_lives() -> int:
	return _lives


## Check if player is currently invincible
func is_invincible() -> bool:
	return _is_invincible
