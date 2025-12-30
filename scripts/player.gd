extends CharacterBody2D
## Player spacecraft with 4-directional movement using keyboard or virtual joystick.
## Movement is snappy with minimal inertia. X-axis clamped to viewport, Y-axis uses collision boundaries.
## Includes lives system with damage handling, invincibility, and shooting.

## Movement speed in pixels per second
@export var move_speed: float = 600.0

## Starting number of lives
@export var starting_lives: int = 3

## Invincibility duration after taking damage (seconds)
@export var invincibility_duration: float = 1.5

## Flashing interval during invincibility (seconds)
@export var flash_interval: float = 0.1

## Fire rate cooldown in seconds
@export var fire_cooldown: float = 0.21

## Projectile scene to spawn when shooting
@export var projectile_scene: PackedScene

## Signals
signal damage_taken()
signal lives_changed(new_lives: int)
signal died()
signal projectile_fired()

## Reference to virtual joystick (auto-detected from scene tree)
var virtual_joystick: Node = null

## Reference to fire button for touch input (auto-detected from scene tree)
var fire_button: Node = null

## Half the size of the player sprite for viewport clamping
var _half_size: Vector2 = Vector2(32, 32)

## Current lives
var _lives: int = 3

## Invincibility state
var _is_invincible: bool = false
var _invincibility_timer: float = 0.0
var _flash_timer: float = 0.0
var _visible_state: bool = true

## Shooting cooldown timer
var _fire_timer: float = 0.0


func _ready() -> void:
	# Initialize lives
	_lives = starting_lives

	# Get the sprite size for accurate viewport clamping (accounting for scale)
	var sprite = $Sprite2D
	if sprite and sprite.texture:
		_half_size = (sprite.texture.get_size() * sprite.scale) / 2.0

	# Find the virtual joystick in the scene tree
	_find_virtual_joystick()

	# Find the fire button in the scene tree
	_find_fire_button()


func _find_virtual_joystick() -> void:
	# Look for VirtualJoystick in the UILayer
	var root = get_tree().root
	var main = root.get_node_or_null("Main")
	if main:
		var ui_layer = main.get_node_or_null("UILayer")
		if ui_layer:
			virtual_joystick = ui_layer.get_node_or_null("VirtualJoystick")


func _find_fire_button() -> void:
	# Look for FireButton in the UILayer
	var root = get_tree().root
	var main = root.get_node_or_null("Main")
	if main:
		var ui_layer = main.get_node_or_null("UILayer")
		if ui_layer:
			fire_button = ui_layer.get_node_or_null("FireButton")


## Set the fire button reference (used by tests)
func set_fire_button(button: Node) -> void:
	fire_button = button


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

	# Handle fire cooldown timer
	if _fire_timer > 0:
		_fire_timer -= delta

	# Check for shooting input (keyboard or touch fire button)
	var should_fire = Input.is_action_pressed("shoot")
	if fire_button and fire_button.has_method("is_pressed"):
		should_fire = should_fire or fire_button.is_pressed()

	if should_fire and _fire_timer <= 0:
		shoot()

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


## Spawn a projectile from the player's position
func shoot() -> void:
	if not projectile_scene:
		push_warning("No projectile scene assigned to Player")
		return

	# Reset cooldown timer
	_fire_timer = fire_cooldown

	# Spawn projectile at player's position (offset slightly to the right)
	var projectile = projectile_scene.instantiate()
	projectile.position = position + Vector2(80, 0)  # Spawn ahead of player

	# Add to parent (Main scene) so it persists independently
	get_parent().add_child(projectile)

	# Emit signal for audio hook
	projectile_fired.emit()


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
