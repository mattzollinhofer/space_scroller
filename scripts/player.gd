extends CharacterBody2D
## Player spacecraft with 4-directional movement using keyboard or virtual joystick.
## Movement is snappy with minimal inertia. X-axis clamped to viewport, Y-axis uses collision boundaries.
## Includes health and lives system: health = damage before losing a life, lives = respawns before game over.
## Loads character sprite from GameState selection.

## Movement speed in pixels per second
@export var move_speed: float = 600.0

## Starting/max health (hearts) - how much damage before losing a life
@export var max_health: int = 3

## Starting number of lives (set from difficulty)
@export var starting_lives: int = 3

## Invincibility duration after losing a life (seconds)
@export var invincibility_duration: float = 1.5

## Flashing interval during invincibility (seconds)
@export var flash_interval: float = 0.1

## Fire rate cooldown for tapping (quick bursts)
@export var tap_fire_cooldown: float = 0.12

## Fire rate cooldown for holding (sustained spray)
@export var hold_fire_cooldown: float = 0.25

## Projectile scene to spawn when shooting
@export var projectile_scene: PackedScene

## Signals
signal damage_taken()
signal health_changed(new_health: int)
signal lives_changed(new_lives: int)
signal life_lost()
signal died()
signal projectile_fired()
signal damage_boost_changed(new_boost: int)
signal triple_shot_changed(active: bool)

## Reference to virtual joystick (auto-detected from scene tree)
var virtual_joystick: Node = null

## Reference to fire button for touch input (auto-detected from scene tree)
var fire_button: Node = null

## Half the size of the player sprite for viewport clamping
var _half_size: Vector2 = Vector2(32, 32)

## Current health (hearts)
var _health: int = 3

## Current lives (respawns remaining)
var _lives: int = 3

## Current damage boost (stacks from missile pickups)
var _damage_boost: int = 0

## Invincibility state
var _is_invincible: bool = false
var _invincibility_timer: float = 0.0
var _flash_timer: float = 0.0
var _visible_state: bool = true

## Shooting cooldown timer
var _fire_timer: float = 0.0

## Track if fire was pressed last frame (for tap detection)
var _was_firing: bool = false

## Rapid fire mode state
var _rapid_fire_active: bool = false
var _rapid_fire_timer: float = 0.0
const RAPID_FIRE_COOLDOWN: float = 0.05  # Very fast firing when active

## Piercing shots mode state
var _piercing_shots_active: bool = false
var _piercing_shots_timer: float = 0.0

## Triple shot mode state (permanent until life lost)
var _triple_shot_active: bool = false


func _ready() -> void:
	# Get starting lives from GameState (based on difficulty)
	var game_state = get_node_or_null("/root/GameState")
	if game_state:
		starting_lives = game_state.get_starting_lives()
		# Check if we have lives carried over from a previous level
		var carried_lives = game_state.get_current_lives()
		if carried_lives > 0:
			_lives = carried_lives
		else:
			_lives = starting_lives
		# Check if we have damage boost carried over from a previous level
		if game_state.has_method("get_damage_boost"):
			var carried_boost = game_state.get_damage_boost()
			if carried_boost > 0:
				_damage_boost = carried_boost
				# Emit signal so UI updates
				damage_boost_changed.emit(_damage_boost)
		# Check if we have triple shot carried over from a previous level
		if game_state.has_method("has_triple_shot"):
			var carried_triple_shot = game_state.has_triple_shot()
			if carried_triple_shot:
				_triple_shot_active = true
				# Emit signal so UI updates
				triple_shot_changed.emit(_triple_shot_active)
	else:
		_lives = starting_lives

	# Initialize health
	_health = max_health

	# Load character sprite based on GameState selection
	_load_character_sprite()

	# Get the sprite size for accurate viewport clamping (accounting for scale)
	var sprite = $Sprite2D
	if sprite and sprite.texture:
		_half_size = (sprite.texture.get_size() * sprite.scale) / 2.0

	# Find the virtual joystick in the scene tree
	_find_virtual_joystick()

	# Find the fire button in the scene tree
	_find_fire_button()


## Load the character sprite based on GameState selection
func _load_character_sprite() -> void:
	var sprite = $Sprite2D as Sprite2D
	if not sprite:
		return

	# Get GameState autoload
	var game_state = get_node_or_null("/root/GameState")
	if not game_state:
		return

	# Get the selected character and load its texture
	var selected_character = game_state.get_selected_character()
	var texture_path = game_state.get_character_texture_path(selected_character)

	var texture = load(texture_path)
	if texture:
		sprite.texture = texture


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

	# Handle rapid fire timer
	if _rapid_fire_active:
		_rapid_fire_timer -= delta
		if _rapid_fire_timer <= 0:
			_rapid_fire_active = false

	# Handle piercing shots timer
	if _piercing_shots_active:
		_piercing_shots_timer -= delta
		if _piercing_shots_timer <= 0:
			_piercing_shots_active = false

	# Triple shot is now permanent until life lost (no timer)

	# Check for shooting input (keyboard or touch fire button)
	var should_fire = Input.is_action_pressed("shoot")
	if fire_button and fire_button.has_method("is_pressed"):
		should_fire = should_fire or fire_button.is_pressed()

	if should_fire and _fire_timer <= 0:
		# Detect if this is a new tap (wasn't firing last frame) or a hold
		var is_new_tap = not _was_firing
		shoot(is_new_tap)

	_was_firing = should_fire

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
func shoot(is_new_tap: bool = false) -> void:
	if not projectile_scene:
		push_warning("No projectile scene assigned to Player")
		return

	# Use rapid fire cooldown if active, otherwise normal tap/hold cooldowns
	var cooldown: float
	if _rapid_fire_active:
		cooldown = RAPID_FIRE_COOLDOWN
	else:
		cooldown = tap_fire_cooldown if is_new_tap else hold_fire_cooldown
	_fire_timer = cooldown

	# Determine projectile configurations (offset, direction)
	var shot_configs: Array = [[Vector2(80, 0), Vector2.RIGHT]]  # Default: single shot
	if _triple_shot_active:
		# Triple shot with spread: center straight, top/bottom angled
		var spread_angle = deg_to_rad(15)  # 15 degree spread
		shot_configs = [
			[Vector2(80, 0), Vector2.RIGHT],  # Center shot - straight
			[Vector2(80, -20), Vector2(cos(-spread_angle), sin(-spread_angle))],  # Top shot - angled up
			[Vector2(80, 20), Vector2(cos(spread_angle), sin(spread_angle))]  # Bottom shot - angled down
		]

	# Spawn projectile(s) at player's position
	for config in shot_configs:
		var offset: Vector2 = config[0]
		var direction: Vector2 = config[1]

		var projectile = projectile_scene.instantiate()
		projectile.position = position + offset

		# Set direction for spread shots
		if "direction" in projectile:
			projectile.direction = direction

		# Apply damage boost to projectile (base damage 1 + boost level)
		projectile.damage = 1 + _damage_boost

		# Apply piercing if active
		if _piercing_shots_active and "piercing" in projectile:
			projectile.piercing = true

		# Add to parent (Main scene) so it persists independently
		get_parent().add_child(projectile)

	# Emit signal for audio hook
	projectile_fired.emit()
	_play_sfx("player_shoot")


## Called when player takes damage from an obstacle
func take_damage() -> void:
	# Ignore damage while invincible
	if _is_invincible:
		return

	# Reduce health
	_health -= 1
	health_changed.emit(_health)
	damage_taken.emit()

	# Check if health depleted (lose a life)
	if _health <= 0:
		_lives -= 1
		lives_changed.emit(_lives)
		life_lost.emit()

		# Reset damage boost and triple shot when losing a life
		reset_damage_boost()
		reset_triple_shot()

		# Trigger screen effects for losing a life
		var screen_effects = get_node_or_null("/root/ScreenEffects")
		if screen_effects:
			screen_effects.life_lost_effect()

		# Check for game over (no lives left)
		if _lives <= 0:
			died.emit()
			_play_sfx("player_death")
			return

		# Still have lives - respawn with full health
		_health = max_health
		health_changed.emit(_health)
		_play_sfx("player_death")
		_start_invincibility()
		return

	# Took damage but still have health - brief invincibility
	_play_sfx("player_damage")
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


## Get current health count
func get_health() -> int:
	return _health


## Get current lives count
func get_lives() -> int:
	return _lives


## Get current damage boost level
func get_damage_boost() -> int:
	return _damage_boost


## Add damage boost (called by missile pickup)
func add_damage_boost() -> void:
	_damage_boost += 1
	damage_boost_changed.emit(_damage_boost)


## Activate rapid fire mode for a duration (called by RapidFirePickup)
func activate_rapid_fire(duration: float) -> void:
	_rapid_fire_active = true
	_rapid_fire_timer = duration


## Check if rapid fire is active
func is_rapid_fire_active() -> bool:
	return _rapid_fire_active


## Activate piercing shots mode for a duration (called by PiercingShotPickup)
func activate_piercing_shots(duration: float) -> void:
	_piercing_shots_active = true
	_piercing_shots_timer = duration


## Check if piercing shots is active
func is_piercing_shots_active() -> bool:
	return _piercing_shots_active


## Activate triple shot mode permanently until life lost (called by TripleShotPickup)
func activate_triple_shot(_duration: float = 0.0) -> void:
	_triple_shot_active = true
	triple_shot_changed.emit(_triple_shot_active)


## Check if triple shot is active
func is_triple_shot_active() -> bool:
	return _triple_shot_active


## Reset triple shot to inactive (called when losing a life)
func reset_triple_shot() -> void:
	_triple_shot_active = false
	triple_shot_changed.emit(_triple_shot_active)
	# Also clear from GameState if available
	var game_state = get_node_or_null("/root/GameState")
	if game_state and game_state.has_method("clear_triple_shot"):
		game_state.clear_triple_shot()


## Reset damage boost to zero (called when losing a life)
func reset_damage_boost() -> void:
	_damage_boost = 0
	damage_boost_changed.emit(_damage_boost)
	# Also clear from GameState if available
	var game_state = get_node_or_null("/root/GameState")
	if game_state and game_state.has_method("clear_damage_boost"):
		game_state.clear_damage_boost()


## Gain health (used by pickups). Returns true if health was gained.
func gain_health() -> bool:
	if _health >= max_health:
		return false
	_health += 1
	health_changed.emit(_health)
	return true


## Gain a life (used by pickups). Returns true if life was gained.
func gain_life() -> bool:
	if _lives >= starting_lives:
		return false
	_lives += 1
	lives_changed.emit(_lives)
	return true


## Reset health to max (used when respawning)
func reset_health() -> void:
	_health = max_health
	health_changed.emit(_health)


## Reset lives to starting value (used for new game)
func reset_lives() -> void:
	# Refresh starting_lives from GameState in case difficulty changed
	var game_state = get_node_or_null("/root/GameState")
	if game_state:
		starting_lives = game_state.get_starting_lives()

	_lives = starting_lives
	_health = max_health
	_is_invincible = false
	_end_invincibility()
	lives_changed.emit(_lives)
	health_changed.emit(_health)


## Check if player is currently invincible
func is_invincible() -> bool:
	return _is_invincible


## Play a sound effect via AudioManager
func _play_sfx(sfx_name: String) -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx(sfx_name)
