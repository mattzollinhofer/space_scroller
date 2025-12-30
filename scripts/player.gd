extends CharacterBody2D
## Player spacecraft with 4-directional movement using keyboard or virtual joystick.
## Movement is snappy with minimal inertia. X-axis clamped to viewport, Y-axis uses collision boundaries.

## Movement speed in pixels per second
@export var move_speed: float = 600.0

## Reference to virtual joystick (auto-detected from scene tree)
var virtual_joystick: Node = null

## Half the size of the player sprite for viewport clamping
var _half_size: Vector2 = Vector2(32, 32)


func _ready() -> void:
	# Get the sprite size for accurate viewport clamping
	var sprite = $Sprite2D
	if sprite and sprite.texture:
		_half_size = sprite.texture.get_size() / 2.0

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


func _physics_process(_delta: float) -> void:
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
