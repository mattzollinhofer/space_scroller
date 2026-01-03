extends Area2D
class_name Boss
## Boss enemy with entrance animation, health system, and attack patterns.
## Spawns when level reaches 100% progress.

const SpriteSizes = preload("res://scripts/sprite_sizes.gd")

## Health of the boss
@export var health: int = 13:
	set(value):
		health = value
		health_changed.emit(health, _max_health)
		if health <= 0:
			_on_health_depleted()

## Boss projectile scene to spawn
@export var boss_projectile_scene: PackedScene

## Custom projectile texture (loaded from level config)
var _projectile_texture: Texture2D = null

## Projectile rotation speed in radians per second (for swirl effects)
var _projectile_rotation_speed: float = 0.0

## Maximum health (for UI percentage)
var _max_health: int = 13

## Whether the boss entrance animation has completed
var _entrance_complete: bool = false

## Whether the boss is currently being destroyed
var _is_destroying: bool = false

## Tween for flash effect
var _flash_tween: Tween = null

## Tween for entrance animation
var _entrance_tween: Tween = null

## Tween for attack movement
var _attack_tween: Tween = null

## Tween for screen shake
var _shake_tween: Tween = null

## Tween for attack telegraph effect
var _telegraph_tween: Tween = null

## Battle position (right third of screen)
var _battle_position: Vector2 = Vector2.ZERO

## Attack state machine
enum AttackState { IDLE, WIND_UP, ATTACKING, COOLDOWN }
var _attack_state: AttackState = AttackState.IDLE

## Current attack pattern index (0 = barrage, 1 = sweep, 2 = charge, 3 = solar flare, 4 = heat wave, 5 = ice shards, 6 = frozen nova, 7 = pepperoni spread, 8 = circle movement, 9 = wall attack, 10 = square movement, 11 = up/down shooting, 12 = grow/shrink, 13 = rapid jelly)
var _current_pattern: int = 0

## Attack cooldown timer
var _attack_timer: float = 0.0

## Cooldown duration between attacks
@export var attack_cooldown: float = 2.0

## Wind-up duration before firing
@export var wind_up_duration: float = 0.5

## Number of projectiles in barrage (5-7)
@export var barrage_projectile_count: int = 6

## Whether attack cycle is active
var _attack_cycle_active: bool = false

## Y bounds for vertical sweep (from base_enemy.gd)
const Y_MIN: float = 140.0
const Y_MAX: float = 1396.0

## Projectile colors for themed attacks
const COLOR_DEFAULT: Color = Color(1, 0.3, 0.3, 1)  # Red (barrage, sweep)
const COLOR_FIRE: Color = Color(1, 0.6, 0.2, 1)     # Orange (solar flare, heat wave)
const COLOR_ICE: Color = Color(0.3, 0.8, 1, 1)      # Cyan (ice shards, frozen nova)
const COLOR_PIZZA: Color = Color(1, 0.4, 0.2, 1)    # Red-orange (pepperoni)
const COLOR_GHOST: Color = Color(0.6, 0.4, 1, 1)    # Purple/blue (ghost attacks)
const COLOR_JELLY: Color = Color(1, 0.5, 0.8, 1)    # Pink/magenta (jelly attacks)

## Reference to player for charge attack targeting
var _player: Node2D = null

## Whether currently in a sweep attack
var _sweep_active: bool = false

## Sweep projectile interval timer
var _sweep_projectile_timer: float = 0.0

## Sweep projectile fire interval
@export var sweep_fire_interval: float = 0.3

## Whether currently in a charge attack
var _charge_active: bool = false

## Charge attack target X position
var _charge_target_x: float = 0.0

## Charge damage amount
@export var charge_damage: int = 1

## Screen shake intensity
@export var shake_intensity: float = 30.0

## Screen shake duration
@export var shake_duration: float = 0.5

## Explosion scale multiplier (boss is larger than regular enemies, adjusted for 256px sprites)
@export var explosion_scale: float = 2.0

## Custom explosion sprite path (optional, uses default if empty)
var explosion_sprite: String = ""

## Shake node for screen shake effect
var _shake_node: Node2D = null

## Which attack patterns are enabled (0=barrage, 1=sweep, 2=charge, 3=solar_flare, 4=heat_wave, 5=ice_shards, 6=frozen_nova, 7=pepperoni_spread, 8=circle_movement, 9=wall_attack, 10=square_movement, 11=up_down_shooting, 12=grow_shrink, 13=rapid_jelly)
var _enabled_attacks: Array[int] = [0, 1, 2]

## Number of attack patterns enabled
var _attack_count: int = 3

## Whether currently in a heat wave attack
var _heat_wave_active: bool = false

## Heat wave projectile interval timer
var _heat_wave_projectile_timer: float = 0.0

## Heat wave projectile fire interval (faster than normal sweep)
@export var heat_wave_fire_interval: float = 0.15

## Whether currently in a wall attack
var _wall_attack_active: bool = false

## Whether currently in a square movement attack
var _square_active: bool = false

## Whether currently in an up/down shooting attack
var _up_down_shooting_active: bool = false

## Up/down shooting projectile interval timer
var _up_down_shooting_projectile_timer: float = 0.0

## Up/down shooting projectile fire interval
@export var up_down_shooting_fire_interval: float = 0.2

## Whether currently in a grow/shrink attack
var _grow_shrink_active: bool = false

## Original sprite scale before grow/shrink attack (for restoration)
var _grow_shrink_original_scale: Vector2 = Vector2.ONE

## Original collision shape size before grow/shrink attack (for restoration)
var _grow_shrink_original_collision_size: Vector2 = Vector2.ZERO

## Original position before grow/shrink lunge (for retreat)
var _grow_shrink_original_position: Vector2 = Vector2.ZERO

## Lunge distance for grow/shrink attack
const GROW_SHRINK_LUNGE_DISTANCE: float = 300.0

## Emitted when the boss is defeated
signal boss_defeated()

## Emitted when entrance animation completes
signal boss_entered()

## Emitted when health changes (for health bar UI)
signal health_changed(current: int, max_health: int)

## Emitted when boss fires projectiles (audio hook)
signal attack_fired()


func _ready() -> void:
	_max_health = health

	# Disable collision until entrance completes (boss is invincible during entrance)
	monitoring = false
	monitorable = false

	# Connect collision signals
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	# Start playing idle animation
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite and sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")

	# Load boss projectile scene if not assigned
	if not boss_projectile_scene:
		boss_projectile_scene = load("res://scenes/enemies/boss_projectile.tscn")

	# Find player reference
	_find_player()


func _find_player() -> void:
	# Try to find player in scene tree
	var root = get_tree().root
	_player = root.get_node_or_null("Main/Player")
	if not _player:
		# Search recursively
		_player = _find_node_by_name(root, "Player")


func _find_node_by_name(node: Node, target_name: String) -> Node:
	if node.name == target_name:
		return node
	for child in node.get_children():
		var found = _find_node_by_name(child, target_name)
		if found:
			return found
	return null


func _process(delta: float) -> void:
	if _is_destroying or not _entrance_complete:
		return

	# Process sweep attack projectile firing
	if _sweep_active:
		_process_sweep_projectiles(delta)

	# Process heat wave attack projectile firing
	if _heat_wave_active:
		_process_heat_wave_projectiles(delta)

	# Process up/down shooting attack projectile firing
	if _up_down_shooting_active:
		_process_up_down_shooting_projectiles(delta)

	# Process attack state machine
	_process_attack_state(delta)


func _process_attack_state(delta: float) -> void:
	if not _attack_cycle_active:
		return

	match _attack_state:
		AttackState.IDLE:
			# Start wind-up for next attack
			_attack_state = AttackState.WIND_UP
			_attack_timer = wind_up_duration
			# Play telegraph effect at start of wind-up
			_play_attack_telegraph()

		AttackState.WIND_UP:
			_attack_timer -= delta
			if _attack_timer <= 0:
				_attack_state = AttackState.ATTACKING
				_execute_attack()

		AttackState.ATTACKING:
			# For sweep, charge, heat wave, circle, wall attack, square movement, up/down shooting, and grow/shrink, wait for tween to complete
			if _sweep_active or _charge_active or _heat_wave_active or _circle_active or _wall_attack_active or _square_active or _up_down_shooting_active or _grow_shrink_active:
				return
			# Attack execution is instant for barrage, move to cooldown
			_attack_state = AttackState.COOLDOWN
			_attack_timer = attack_cooldown

		AttackState.COOLDOWN:
			_attack_timer -= delta
			if _attack_timer <= 0:
				# Move to next pattern (cycle through enabled attacks only)
				_current_pattern = (_current_pattern + 1) % _attack_count
				_attack_state = AttackState.IDLE


func _play_attack_telegraph() -> void:
	## Play visual telegraph effect before attack fires
	## Pulses sprite modulate with red tint to warn player
	var sprite = get_node_or_null("AnimatedSprite2D")
	if not sprite:
		return

	# Kill any existing telegraph tween
	if _telegraph_tween and _telegraph_tween.is_valid():
		_telegraph_tween.kill()

	# Determine warning color based on attack type
	# Charge attack (most dangerous) gets brighter warning
	var attack_type = _enabled_attacks[_current_pattern] if _current_pattern < _enabled_attacks.size() else 0
	var warning_color: Color
	if attack_type == 2:  # Charge attack
		warning_color = Color(2.0, 1.0, 1.0, 1.0)  # Brighter red tint
	elif attack_type == 3 or attack_type == 4:  # Solar Flare or Heat Wave - orange/yellow tint for "hot" theme
		warning_color = Color(2.0, 1.5, 0.5, 1.0)  # Orange-yellow tint
	elif attack_type == 5 or attack_type == 6:  # Ice Shards or Frozen Nova - blue/cyan tint for "cold" theme
		warning_color = Color(0.5, 1.0, 2.0, 1.0)  # Blue-cyan tint
	elif attack_type == 7 or attack_type == 8:  # Pepperoni Spread or Circle Movement - red-orange pizza tint
		warning_color = Color(2.0, 1.2, 0.6, 1.0)  # Pizza red-orange tint
	elif attack_type == 9 or attack_type == 10:  # Wall Attack or Square Movement - ghost purple/blue tint
		warning_color = Color(1.2, 0.8, 2.0, 1.0)  # Ghost purple/blue tint
	elif attack_type >= 11 and attack_type <= 13:  # Jelly attacks (up/down shooting, grow/shrink, rapid jelly) - pink/magenta tint
		warning_color = Color(2.0, 1.0, 1.6, 1.0)  # Pink/magenta jelly tint
	else:  # Barrage or sweep
		warning_color = Color(1.5, 1.0, 1.0, 1.0)  # Subtle red tint

	var normal_color = Color(1, 1, 1, 1)

	# Create pulsing telegraph effect
	_telegraph_tween = create_tween()
	_telegraph_tween.set_loops()  # Loop until killed

	# Pulse from normal to warning and back
	var pulse_duration = 0.15  # Quick pulses during wind-up
	_telegraph_tween.tween_property(sprite, "modulate", warning_color, pulse_duration).set_ease(Tween.EASE_IN_OUT)
	_telegraph_tween.tween_property(sprite, "modulate", normal_color, pulse_duration).set_ease(Tween.EASE_IN_OUT)


func _stop_attack_telegraph() -> void:
	## Stop telegraph effect and reset modulate to normal
	if _telegraph_tween and _telegraph_tween.is_valid():
		_telegraph_tween.kill()
		_telegraph_tween = null

	# Reset sprite modulate to normal
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite:
		sprite.modulate = Color(1, 1, 1, 1)


func _execute_attack() -> void:
	# Clean up telegraph before attack fires
	_stop_attack_telegraph()

	# Get the actual attack type from enabled attacks array
	var attack_type = _enabled_attacks[_current_pattern] if _current_pattern < _enabled_attacks.size() else 0
	match attack_type:
		0:
			_attack_horizontal_barrage()
		1:
			_attack_vertical_sweep()
		2:
			_attack_charge()
		3:
			_attack_solar_flare()
		4:
			_attack_heat_wave()
		5:
			_attack_ice_shards()
		6:
			_attack_frozen_nova()
		7:
			_attack_pepperoni_spread()
		8:
			_attack_circle_movement()
		9:
			_attack_wall()
		10:
			_attack_square_movement()
		11:
			_attack_up_down_shooting()
		12:
			_attack_grow_shrink()
		13:
			_attack_rapid_jelly()


func _attack_horizontal_barrage() -> void:
	## Fire a spread of 5-7 projectiles toward the left
	if not boss_projectile_scene:
		push_warning("Boss projectile scene not assigned")
		return

	# Randomize projectile count between 5-7
	var projectile_count = randi_range(5, 7)

	# Calculate spread angles
	var spread_angle = deg_to_rad(30.0)  # Total spread of 30 degrees
	var angle_step = spread_angle / (projectile_count - 1) if projectile_count > 1 else 0.0
	var start_angle = -spread_angle / 2.0

	for i in range(projectile_count):
		var projectile = boss_projectile_scene.instantiate()

		# Position at boss location (slightly to the left of center)
		projectile.position = position + Vector2(-100, 0)

		# Calculate direction with spread
		var angle = start_angle + (angle_step * i)
		var direction = Vector2(-1, 0).rotated(angle)

		# Set direction on projectile
		if projectile.has_method("set_direction"):
			projectile.set_direction(direction)
		else:
			projectile.direction = direction

		_apply_projectile_texture(projectile)

		# Add to parent (main scene)
		var parent = get_parent()
		if parent:
			parent.add_child(projectile)

	attack_fired.emit()
	_play_sfx("boss_attack")


func _attack_vertical_sweep() -> void:
	## Boss moves up/down while firing single projectiles
	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()

	_sweep_active = true
	_sweep_projectile_timer = 0.0  # Fire immediately

	# Determine sweep direction based on current position
	var sweep_up = position.y > (Y_MIN + Y_MAX) / 2.0

	# Create sweep tween
	_attack_tween = create_tween()

	if sweep_up:
		# Sweep up then down
		_attack_tween.tween_property(self, "position:y", Y_MIN, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		_attack_tween.tween_property(self, "position:y", _battle_position.y, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	else:
		# Sweep down then up
		_attack_tween.tween_property(self, "position:y", Y_MAX, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		_attack_tween.tween_property(self, "position:y", _battle_position.y, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

	_attack_tween.tween_callback(_on_sweep_complete)


func _process_sweep_projectiles(delta: float) -> void:
	## Fire projectiles at intervals during sweep
	_sweep_projectile_timer -= delta
	if _sweep_projectile_timer <= 0:
		_sweep_projectile_timer = sweep_fire_interval
		_fire_single_projectile()


func _fire_single_projectile() -> void:
	## Fire a single projectile to the left
	if not boss_projectile_scene:
		return

	var projectile = boss_projectile_scene.instantiate()
	projectile.position = position + Vector2(-100, 0)

	# Direction straight left
	var direction = Vector2(-1, 0)
	if projectile.has_method("set_direction"):
		projectile.set_direction(direction)
	else:
		projectile.direction = direction

	_apply_projectile_texture(projectile)

	var parent = get_parent()
	if parent:
		parent.add_child(projectile)

	attack_fired.emit()
	_play_sfx("boss_attack")


func _on_sweep_complete() -> void:
	_sweep_active = false
	_attack_state = AttackState.COOLDOWN
	_attack_timer = attack_cooldown


func _attack_charge() -> void:
	## Charge toward player position then return to battle position
	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()

	_charge_active = true

	# Get player position for targeting
	var target_x = position.x  # Default to current position
	if _player and is_instance_valid(_player):
		# Charge toward player X, but not all the way (stop 150px before)
		target_x = _player.position.x + 150
	else:
		# If no player, charge to left side of screen
		target_x = 600

	_charge_target_x = target_x

	# Create charge tween
	_attack_tween = create_tween()

	# Quick charge toward player
	_attack_tween.tween_property(self, "position:x", target_x, 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)

	# Brief pause at charge position
	_attack_tween.tween_interval(0.3)

	# Return to battle position
	_attack_tween.tween_property(self, "position:x", _battle_position.x, 0.6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	_attack_tween.tween_callback(_on_charge_complete)


func _on_charge_complete() -> void:
	_charge_active = false
	_attack_state = AttackState.COOLDOWN
	_attack_timer = attack_cooldown


func _apply_projectile_texture(projectile: Node) -> void:
	## Apply custom projectile texture and rotation speed if configured
	if _projectile_texture and projectile.has_method("set_texture"):
		projectile.set_texture(_projectile_texture)
	if _projectile_rotation_speed != 0.0 and projectile.has_method("set_rotation_speed"):
		projectile.set_rotation_speed(_projectile_rotation_speed)


func _attack_solar_flare() -> void:
	## Solar Flare: Radial burst of fast projectiles in all directions (360 degrees)
	## Inner Solar System "hot" theme attack - fast, intense, but dodgeable
	if not boss_projectile_scene:
		push_warning("Boss projectile scene not assigned")
		return

	# Fire 12 projectiles in a radial burst (360 degrees / 12 = 30 degrees apart)
	var projectile_count = 12
	var angle_step = TAU / projectile_count  # TAU = 2*PI = full circle

	for i in range(projectile_count):
		var projectile = boss_projectile_scene.instantiate()

		# Position at boss center
		projectile.position = position

		# Calculate direction for this projectile (evenly spaced around circle)
		var angle = angle_step * i
		var direction = Vector2(1, 0).rotated(angle)

		# Set direction on projectile
		if projectile.has_method("set_direction"):
			projectile.set_direction(direction)
		else:
			projectile.direction = direction

		# Solar Flare uses faster projectiles (950 vs default 750)
		projectile.speed = 950.0

		# Set fire theme color
		if projectile.has_method("set_color"):
			projectile.set_color(COLOR_FIRE)

		_apply_projectile_texture(projectile)

		# Add to parent (main scene)
		var parent = get_parent()
		if parent:
			parent.add_child(projectile)

	attack_fired.emit()
	_play_sfx("boss_attack")


func _attack_heat_wave() -> void:
	## Heat Wave: Boss sweeps in arc while firing continuous stream of fast projectiles
	## Inner Solar System "hot" theme attack - sweeping arc with rapid fire
	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()

	_heat_wave_active = true
	_heat_wave_projectile_timer = 0.0  # Fire immediately

	# Determine sweep direction based on current position
	var sweep_up = position.y > (Y_MIN + Y_MAX) / 2.0

	# Create sweep tween (similar to vertical sweep but maybe slightly faster)
	_attack_tween = create_tween()

	if sweep_up:
		# Sweep up then down
		_attack_tween.tween_property(self, "position:y", Y_MIN, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		_attack_tween.tween_property(self, "position:y", _battle_position.y, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	else:
		# Sweep down then up
		_attack_tween.tween_property(self, "position:y", Y_MAX, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		_attack_tween.tween_property(self, "position:y", _battle_position.y, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

	_attack_tween.tween_callback(_on_heat_wave_complete)


func _process_heat_wave_projectiles(delta: float) -> void:
	## Fire fast projectiles at rapid intervals during heat wave
	_heat_wave_projectile_timer -= delta
	if _heat_wave_projectile_timer <= 0:
		_heat_wave_projectile_timer = heat_wave_fire_interval
		_fire_heat_wave_projectile()


func _fire_heat_wave_projectile() -> void:
	## Fire a single fast projectile to the left (Heat Wave variant)
	if not boss_projectile_scene:
		return

	var projectile = boss_projectile_scene.instantiate()
	projectile.position = position + Vector2(-100, 0)

	# Direction straight left
	var direction = Vector2(-1, 0)
	if projectile.has_method("set_direction"):
		projectile.set_direction(direction)
	else:
		projectile.direction = direction

	# Heat Wave uses faster projectiles (950 vs default 750)
	projectile.speed = 950.0

	# Set fire theme color
	if projectile.has_method("set_color"):
		projectile.set_color(COLOR_FIRE)

	_apply_projectile_texture(projectile)

	var parent = get_parent()
	if parent:
		parent.add_child(projectile)

	attack_fired.emit()
	_play_sfx("boss_attack")


func _on_heat_wave_complete() -> void:
	_heat_wave_active = false
	_attack_state = AttackState.COOLDOWN
	_attack_timer = attack_cooldown


func _attack_ice_shards() -> void:
	## Ice Shards: Many slow-moving projectiles in a wide spread pattern
	## Outer Solar System "cold/expansive" theme attack - numerous but slow
	if not boss_projectile_scene:
		push_warning("Boss projectile scene not assigned")
		return

	# Fire 15 projectiles in a wide spread (more than barrage's 5-7 for "numerous" feel)
	var projectile_count = 15

	# Wide spread angle: 120 degrees total (60 degrees up and 60 degrees down from straight left)
	var spread_angle = deg_to_rad(120.0)
	var angle_step = spread_angle / (projectile_count - 1) if projectile_count > 1 else 0.0
	var start_angle = -spread_angle / 2.0

	for i in range(projectile_count):
		var projectile = boss_projectile_scene.instantiate()

		# Position at boss location (slightly to the left of center)
		projectile.position = position + Vector2(-100, 0)

		# Calculate direction with wide spread (centered on straight left)
		var angle = start_angle + (angle_step * i)
		var direction = Vector2(-1, 0).rotated(angle)

		# Set direction on projectile
		if projectile.has_method("set_direction"):
			projectile.set_direction(direction)
		else:
			projectile.direction = direction

		# Ice Shards uses slower projectiles (450 vs default 750)
		projectile.speed = 450.0

		# Set ice theme color
		if projectile.has_method("set_color"):
			projectile.set_color(COLOR_ICE)

		_apply_projectile_texture(projectile)

		# Add to parent (main scene)
		var parent = get_parent()
		if parent:
			parent.add_child(projectile)

	attack_fired.emit()
	_play_sfx("boss_attack")


func _attack_frozen_nova() -> void:
	## Frozen Nova: Delayed radial burst of slow projectiles in all directions (360 degrees)
	## Outer Solar System "cold/expansive" theme attack - slow expanding nova
	## The delay comes from the wind-up telegraph; this fires an expanding radial burst
	if not boss_projectile_scene:
		push_warning("Boss projectile scene not assigned")
		return

	# Fire 16 projectiles in a radial burst (360 degrees / 16 = 22.5 degrees apart)
	# More projectiles than Solar Flare for "expansive" feel
	var projectile_count = 16
	var angle_step = TAU / projectile_count  # TAU = 2*PI = full circle

	for i in range(projectile_count):
		var projectile = boss_projectile_scene.instantiate()

		# Position at boss center
		projectile.position = position

		# Calculate direction for this projectile (evenly spaced around circle)
		var angle = angle_step * i
		var direction = Vector2(1, 0).rotated(angle)

		# Set direction on projectile
		if projectile.has_method("set_direction"):
			projectile.set_direction(direction)
		else:
			projectile.direction = direction

		# Frozen Nova uses slower projectiles (450 vs default 750) for "expansive" feel
		projectile.speed = 450.0

		# Set ice theme color
		if projectile.has_method("set_color"):
			projectile.set_color(COLOR_ICE)

		_apply_projectile_texture(projectile)

		# Add to parent (main scene)
		var parent = get_parent()
		if parent:
			parent.add_child(projectile)

	attack_fired.emit()
	_play_sfx("boss_attack")


func _attack_pepperoni_spread() -> void:
	## Pepperoni Spread: Fire 3 pepperoni projectiles in a 45-degree spread pattern
	## Pizza-themed attack for Level 4 boss
	if not boss_projectile_scene:
		push_warning("Boss projectile scene not assigned")
		return

	# Fire 3 projectiles in a spread
	var projectile_count = 3

	# 45-degree total spread (22.5 degrees up and down from center)
	var spread_angle = deg_to_rad(45.0)
	var angle_step = spread_angle / (projectile_count - 1) if projectile_count > 1 else 0.0
	var start_angle = -spread_angle / 2.0

	for i in range(projectile_count):
		var projectile = boss_projectile_scene.instantiate()

		# Position at boss location (slightly to the left of center)
		projectile.position = position + Vector2(-100, 0)

		# Calculate direction with spread (centered on straight left)
		var angle = start_angle + (angle_step * i)
		var direction = Vector2(-1, 0).rotated(angle)

		# Set direction on projectile
		if projectile.has_method("set_direction"):
			projectile.set_direction(direction)
		else:
			projectile.direction = direction

		# Apply custom projectile texture from level config
		_apply_projectile_texture(projectile)

		# Make pepperoni 6x larger for big visible projectiles (adjusted for 256px sprites)
		if projectile.has_method("set_projectile_scale"):
			projectile.set_projectile_scale(1.5)

		# Add to parent (main scene)
		var parent = get_parent()
		if parent:
			parent.add_child(projectile)

	attack_fired.emit()
	_play_sfx("boss_attack")


## Whether currently in a circle movement attack
var _circle_active: bool = false

## Whether next circle should be clockwise (alternates each cycle)
var _circle_clockwise: bool = true

## Circle movement radius (large enough to reach player side of arena)
const CIRCLE_RADIUS: float = 700.0

## Circle movement duration (full circle - longer for larger radius)
const CIRCLE_DURATION: float = 4.0

## Square movement duration (full square path)
const SQUARE_DURATION: float = 3.0

## Grow/shrink attack duration (grow phase + shrink phase)
const GROW_SHRINK_DURATION: float = 2.0

## Grow/shrink scale multiplier (how large boss grows)
const GROW_SHRINK_SCALE: float = 4.0


func _attack_circle_movement() -> void:
	## Circle Movement: Boss moves in a circle around the arena
	## Alternates between clockwise and counter-clockwise each cycle
	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()

	_circle_active = true

	# Calculate circle center (far left to ensure circle reaches player side of arena)
	var circle_center = _battle_position + Vector2(-700, 0)

	# Number of points to define the circle path
	var num_points = 8
	var angle_step = TAU / num_points

	# Determine starting angle based on current position relative to center
	var start_angle = (position - circle_center).angle()

	# Create the tween
	_attack_tween = create_tween()

	# Move through each point of the circle
	for i in range(num_points + 1):  # +1 to complete the circle back to start
		var point_index = i if _circle_clockwise else (num_points - i)
		var angle = start_angle + (angle_step * point_index * (1 if _circle_clockwise else -1))

		# Calculate target position on the circle
		var target = circle_center + Vector2(cos(angle), sin(angle)) * CIRCLE_RADIUS

		# Clamp Y to screen bounds
		target.y = clampf(target.y, Y_MIN + 100, Y_MAX - 100)

		# Add tween to this position
		var segment_duration = CIRCLE_DURATION / (num_points + 1)
		_attack_tween.tween_property(self, "position", target, segment_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

	# Return to battle position after circle
	_attack_tween.tween_property(self, "position", _battle_position, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	_attack_tween.tween_callback(_on_circle_complete)


func _on_circle_complete() -> void:
	_circle_active = false
	# Toggle direction for next circle
	_circle_clockwise = not _circle_clockwise
	_attack_state = AttackState.COOLDOWN
	_attack_timer = attack_cooldown


## Check if currently in circle movement (for testing)
func is_circling() -> bool:
	return _circle_active


func _attack_wall() -> void:
	## Wall Attack: 6 projectiles fan out vertically then shoot horizontally toward player
	## Ghost-themed attack for Level 5 boss
	if not boss_projectile_scene:
		push_warning("Boss projectile scene not assigned")
		return

	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()

	_wall_attack_active = true

	# Create 6 projectiles - 3 fan upward, 3 fan downward
	var projectile_count = 6
	var vertical_spread = 300.0  # How far they spread vertically
	var fan_duration = 0.5  # Time to fan out
	var projectiles: Array = []

	var parent = get_parent()
	if not parent:
		_wall_attack_active = false
		return

	for i in range(projectile_count):
		var projectile = boss_projectile_scene.instantiate()

		# All projectiles start at boss position
		projectile.position = position

		# Calculate vertical offset for final fan position
		# 3 projectiles go up (indices 0, 1, 2), 3 go down (indices 3, 4, 5)
		var vertical_offset: float
		if i < 3:
			# Upper projectiles: spread upward
			vertical_offset = -vertical_spread * (1.0 + float(i) * 0.5)  # -300, -450, -600
		else:
			# Lower projectiles: spread downward
			vertical_offset = vertical_spread * (1.0 + float(i - 3) * 0.5)  # 300, 450, 600

		# Initially set direction to zero (will be updated after fanning)
		if projectile.has_method("set_direction"):
			projectile.set_direction(Vector2.ZERO)
		else:
			projectile.direction = Vector2.ZERO

		# Stop the projectile from moving initially
		projectile.speed = 0.0

		_apply_projectile_texture(projectile)

		parent.add_child(projectile)
		projectiles.append({"node": projectile, "target_y": position.y + vertical_offset})

	# Create tween to fan out projectiles vertically, then shoot horizontally
	_attack_tween = create_tween()

	# Fan out phase: move projectiles vertically
	for proj_data in projectiles:
		var proj = proj_data["node"]
		var target_y = proj_data["target_y"]
		if is_instance_valid(proj):
			# Use parallel tweening for simultaneous movement
			_attack_tween.parallel().tween_property(proj, "position:y", target_y, fan_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	# After fanning, set all projectiles to move horizontally left
	_attack_tween.tween_callback(func():
		for proj_data in projectiles:
			var proj = proj_data["node"]
			if is_instance_valid(proj):
				# Set direction to left and restore speed
				if proj.has_method("set_direction"):
					proj.set_direction(Vector2(-1, 0))
				else:
					proj.direction = Vector2(-1, 0)
				proj.speed = 750.0  # Default projectile speed
	)

	# Wait a moment then complete the attack
	_attack_tween.tween_interval(0.3)
	_attack_tween.tween_callback(_on_wall_attack_complete)

	attack_fired.emit()
	_play_sfx("boss_attack")


func _on_wall_attack_complete() -> void:
	_wall_attack_active = false
	_attack_state = AttackState.COOLDOWN
	_attack_timer = attack_cooldown


## Check if currently in wall attack (for testing)
func is_wall_attacking() -> bool:
	return _wall_attack_active


func _attack_square_movement() -> void:
	## Square Movement: Boss moves in a rectangular path around the arena
	## Ghost-themed movement attack for Level 5 boss - no projectiles fired
	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()

	_square_active = true

	# Define 4 corner positions for rectangular path
	# Boss moves all the way to the left side of screen (toward player) and back
	var left_x = 200.0  # Near left edge of screen (player side)
	var right_x = _battle_position.x + 100.0  # Slightly past battle position on right
	var half_height = 400.0  # Vertical distance from center

	# Calculate corners - go all the way across the screen
	var top_left = Vector2(left_x, _battle_position.y - half_height)
	var bottom_left = Vector2(left_x, _battle_position.y + half_height)
	var bottom_right = Vector2(right_x, _battle_position.y + half_height)
	var top_right = Vector2(right_x, _battle_position.y - half_height)

	# Clamp Y positions to screen bounds
	top_left.y = clampf(top_left.y, Y_MIN + 100, Y_MAX - 100)
	bottom_left.y = clampf(bottom_left.y, Y_MIN + 100, Y_MAX - 100)
	bottom_right.y = clampf(bottom_right.y, Y_MIN + 100, Y_MAX - 100)
	top_right.y = clampf(top_right.y, Y_MIN + 100, Y_MAX - 100)

	# Create the tween
	_attack_tween = create_tween()

	# Duration for each segment
	var segment_duration = SQUARE_DURATION / 4.0

	# Move through corners sequentially
	_attack_tween.tween_property(self, "position", top_left, segment_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_attack_tween.tween_property(self, "position", bottom_left, segment_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_attack_tween.tween_property(self, "position", bottom_right, segment_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_attack_tween.tween_property(self, "position", top_right, segment_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

	# Return to battle position after completing square
	_attack_tween.tween_property(self, "position", _battle_position, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	_attack_tween.tween_callback(_on_square_complete)


func _on_square_complete() -> void:
	_square_active = false
	_attack_state = AttackState.COOLDOWN
	_attack_timer = attack_cooldown


## Check if currently in square movement (for testing)
func is_square_moving() -> bool:
	return _square_active


func _attack_up_down_shooting() -> void:
	## Up/Down Shooting: Boss moves vertically across full screen while firing projectiles
	## Jelly-themed attack for Level 6 boss - continuous fire during vertical sweep
	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()

	_up_down_shooting_active = true
	_up_down_shooting_projectile_timer = 0.0  # Fire immediately

	# Determine sweep direction based on current position
	var sweep_up = position.y > (Y_MIN + Y_MAX) / 2.0

	# Create sweep tween - full vertical traverse
	_attack_tween = create_tween()

	if sweep_up:
		# Sweep up to min, then down to max, then back to battle position
		_attack_tween.tween_property(self, "position:y", Y_MIN, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		_attack_tween.tween_property(self, "position:y", Y_MAX, 1.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		_attack_tween.tween_property(self, "position:y", _battle_position.y, 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	else:
		# Sweep down to max, then up to min, then back to battle position
		_attack_tween.tween_property(self, "position:y", Y_MAX, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		_attack_tween.tween_property(self, "position:y", Y_MIN, 1.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		_attack_tween.tween_property(self, "position:y", _battle_position.y, 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	_attack_tween.tween_callback(_on_up_down_shooting_complete)


func _process_up_down_shooting_projectiles(delta: float) -> void:
	## Fire projectiles at intervals during up/down shooting attack
	_up_down_shooting_projectile_timer -= delta
	if _up_down_shooting_projectile_timer <= 0:
		_up_down_shooting_projectile_timer = up_down_shooting_fire_interval
		_fire_up_down_shooting_projectile()


func _fire_up_down_shooting_projectile() -> void:
	## Fire a single jelly projectile to the left
	if not boss_projectile_scene:
		return

	var projectile = boss_projectile_scene.instantiate()
	projectile.position = position + Vector2(-100, 0)

	# Direction straight left
	var direction = Vector2(-1, 0)
	if projectile.has_method("set_direction"):
		projectile.set_direction(direction)
	else:
		projectile.direction = direction

	_apply_projectile_texture(projectile)

	var parent = get_parent()
	if parent:
		parent.add_child(projectile)

	attack_fired.emit()
	_play_sfx("boss_attack")


func _on_up_down_shooting_complete() -> void:
	_up_down_shooting_active = false
	_attack_state = AttackState.COOLDOWN
	_attack_timer = attack_cooldown


## Check if currently in up/down shooting attack (for testing)
func is_up_down_shooting() -> bool:
	return _up_down_shooting_active


func _attack_grow_shrink() -> void:
	## Grow/Shrink: Boss scales up to 4x size, lunges toward player, then retreats
	## Jelly-themed attack for Level 6 boss - contact damage via enlarged collision
	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()

	_grow_shrink_active = true

	# Get sprite and collision shape
	var sprite = get_node_or_null("AnimatedSprite2D")
	var collision = get_node_or_null("CollisionShape2D")

	if not sprite:
		_grow_shrink_active = false
		_attack_state = AttackState.COOLDOWN
		_attack_timer = attack_cooldown
		return

	# Store original scales and position for restoration
	_grow_shrink_original_scale = sprite.scale
	_grow_shrink_original_position = position
	if collision and collision.shape:
		_grow_shrink_original_collision_size = collision.shape.size

	# Calculate target scales (4x original)
	var target_sprite_scale = _grow_shrink_original_scale * GROW_SHRINK_SCALE
	var target_collision_size = _grow_shrink_original_collision_size * GROW_SHRINK_SCALE

	# Calculate lunge position (toward player/left side)
	var lunge_position = Vector2(_grow_shrink_original_position.x - GROW_SHRINK_LUNGE_DISTANCE, _grow_shrink_original_position.y)

	# Create grow/shrink tween
	_attack_tween = create_tween()

	# Grow phase: scale up to 4x over half the duration
	var grow_duration = GROW_SHRINK_DURATION / 2.0
	_attack_tween.tween_property(sprite, "scale", target_sprite_scale, grow_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

	# Scale collision shape in parallel during growth
	if collision and collision.shape:
		_attack_tween.parallel().tween_property(collision.shape, "size", target_collision_size, grow_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

	# Lunge toward player at peak size
	_attack_tween.tween_property(self, "position", lunge_position, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	# Brief pause at lunge position
	_attack_tween.tween_interval(0.2)

	# Retreat back to original position while shrinking
	var shrink_duration = GROW_SHRINK_DURATION / 2.0
	_attack_tween.tween_property(self, "position", _grow_shrink_original_position, shrink_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	_attack_tween.parallel().tween_property(sprite, "scale", _grow_shrink_original_scale, shrink_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)

	# Scale collision shape back to original in parallel
	if collision and collision.shape:
		_attack_tween.parallel().tween_property(collision.shape, "size", _grow_shrink_original_collision_size, shrink_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)

	_attack_tween.tween_callback(_on_grow_shrink_complete)


func _on_grow_shrink_complete() -> void:
	_grow_shrink_active = false
	_attack_state = AttackState.COOLDOWN
	_attack_timer = attack_cooldown


## Check if currently in grow/shrink attack (for testing)
func is_grow_shrinking() -> bool:
	return _grow_shrink_active


func _attack_rapid_jelly() -> void:
	## Rapid Jelly Attack: Fire 6 projectiles straight forward (left) simultaneously
	## Jelly-themed burst attack for Level 6 boss - like horizontal barrage but no spread
	if not boss_projectile_scene:
		push_warning("Boss projectile scene not assigned")
		return

	# Fire exactly 6 projectiles
	var projectile_count = 6

	# Vertical spacing between projectiles (so they're not all on same line)
	var vertical_spacing = 40.0
	var start_offset = -vertical_spacing * (projectile_count - 1) / 2.0

	for i in range(projectile_count):
		var projectile = boss_projectile_scene.instantiate()

		# Position at boss location with vertical offset for each projectile
		var vertical_offset = start_offset + (vertical_spacing * i)
		projectile.position = position + Vector2(-100, vertical_offset)

		# All projectiles go straight left (no spread angle)
		var direction = Vector2(-1, 0)

		# Set direction on projectile
		if projectile.has_method("set_direction"):
			projectile.set_direction(direction)
		else:
			projectile.direction = direction

		_apply_projectile_texture(projectile)

		# Add to parent (main scene)
		var parent = get_parent()
		if parent:
			parent.add_child(projectile)

	attack_fired.emit()
	_play_sfx("boss_attack")


## Setup boss at spawn position and start entrance animation
func setup(spawn_position: Vector2, battle_position: Vector2) -> void:
	position = spawn_position
	_battle_position = battle_position
	_start_entrance_animation()


func _start_entrance_animation() -> void:
	_entrance_complete = false

	# Tween from spawn position to battle position
	_entrance_tween = create_tween()
	_entrance_tween.tween_property(self, "position", _battle_position, 2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_entrance_tween.tween_callback(_on_entrance_complete)


func _on_entrance_complete() -> void:
	_entrance_complete = true

	# Enable collision now that boss is active and vulnerable
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)

	boss_entered.emit()

	# Start attack cycle after entrance
	start_attack_cycle()


func _on_body_entered(body: Node2D) -> void:
	if _is_destroying:
		return

	# Check if it's the player - deals contact damage during charge
	if body.has_method("take_damage"):
		body.take_damage()
		# Boss also takes damage from player collision (after entrance)
		if _entrance_complete:
			take_hit(1)


func _on_area_entered(area: Area2D) -> void:
	if _is_destroying:
		return

	# Check if boss hit an asteroid
	if area.is_in_group("asteroids"):
		# Boss takes 1 damage from asteroid collision (after entrance)
		if _entrance_complete:
			take_hit(1)
		# Also damage the asteroid
		if area.has_method("take_hit"):
			area.take_hit(1)

	# Projectiles call take_hit on the boss
	# (handled by projectile.gd calling our take_hit method)


## Called when hit by a projectile
func take_hit(damage: int) -> void:
	if _is_destroying:
		return

	# Ignore damage during entrance animation
	if not _entrance_complete:
		return

	# Reduce health
	health -= damage
	_play_sfx("boss_damage")

	# Play hit flash if still alive
	if health > 0:
		_play_hit_flash()


func _play_hit_flash() -> void:
	var sprite = get_node_or_null("AnimatedSprite2D")
	if not sprite:
		return

	# Kill any existing flash tween
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()

	# Store original values
	var original_modulate: Color = Color(1, 1, 1, 1)
	var original_scale: Vector2 = sprite.scale

	# Apply white flash and scale up
	sprite.modulate = Color(3.0, 3.0, 3.0, 1.0)
	sprite.scale = original_scale * SpriteSizes.BOSS_HIT_FLASH_MULTIPLIER

	# Restore original state
	_flash_tween = create_tween()
	_flash_tween.set_parallel(true)
	_flash_tween.tween_property(sprite, "modulate", original_modulate, 0.2).set_ease(Tween.EASE_OUT)
	_flash_tween.tween_property(sprite, "scale", original_scale, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)


func _on_health_depleted() -> void:
	if _is_destroying:
		return
	_is_destroying = true

	# Stop attack cycle
	_attack_cycle_active = false
	_sweep_active = false
	_charge_active = false
	_heat_wave_active = false
	_circle_active = false
	_wall_attack_active = false
	_square_active = false
	_up_down_shooting_active = false
	_grow_shrink_active = false

	# Kill tweens if active
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
	if _entrance_tween and _entrance_tween.is_valid():
		_entrance_tween.kill()
	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()
	if _telegraph_tween and _telegraph_tween.is_valid():
		_telegraph_tween.kill()

	# Disable collision
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

	# Emit defeated signal (for audio hooks and level manager)
	boss_defeated.emit()

	# Play destruction sequence: screen shake, then explosion
	_play_screen_shake()
	_play_destruction_animation()


func _play_screen_shake() -> void:
	## Apply screen shake effect by shaking the main node position
	# Find the main node (parent of the boss)
	var main_node = get_parent()
	if not main_node or not main_node is Node2D:
		return

	# Store reference for shake detection
	_shake_node = main_node

	# Kill any existing shake tween
	if _shake_tween and _shake_tween.is_valid():
		_shake_tween.kill()

	# Store original position
	var original_position = main_node.position

	# Create shake tween with decreasing intensity
	_shake_tween = create_tween()

	var shake_steps = 10
	var step_duration = shake_duration / shake_steps

	for i in range(shake_steps):
		# Intensity decreases over time
		var intensity_factor = 1.0 - (float(i) / shake_steps)
		var current_intensity = shake_intensity * intensity_factor

		# Random offset for this step
		var random_offset = Vector2(
			randf_range(-current_intensity, current_intensity),
			randf_range(-current_intensity, current_intensity)
		)

		_shake_tween.tween_property(main_node, "position", original_position + random_offset, step_duration)

	# Return to original position
	_shake_tween.tween_property(main_node, "position", original_position, step_duration)


func _play_destruction_animation() -> void:
	# Hide sprite
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite:
		sprite.visible = false

	# Create large boss explosion (use custom if set, otherwise default)
	var explosion_path = explosion_sprite if explosion_sprite != "" else "res://assets/sprites/explosion.png"
	var explosion_texture = load(explosion_path)
	var explosion = Sprite2D.new()
	explosion.texture = explosion_texture
	explosion.scale = Vector2(explosion_scale, explosion_scale)
	add_child(explosion)

	# Animate explosion: scale up further and fade out
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(explosion, "scale", Vector2(explosion_scale * 1.5, explosion_scale * 1.5), 0.8).set_ease(Tween.EASE_OUT)
	tween.tween_property(explosion, "modulate:a", 0.0, 0.8).set_ease(Tween.EASE_IN)

	# Queue free after animation completes
	tween.chain().tween_callback(queue_free)


## Get the shake node for testing
func get_shake_node() -> Node2D:
	return _shake_node


## Start the attack cycle
func start_attack_cycle() -> void:
	if _is_destroying:
		return
	_attack_cycle_active = true
	_attack_state = AttackState.IDLE
	_current_pattern = 0


## Stop the attack cycle
func stop_attack_cycle() -> void:
	_attack_cycle_active = false
	_attack_state = AttackState.IDLE
	_sweep_active = false
	_charge_active = false
	_heat_wave_active = false
	_circle_active = false
	_wall_attack_active = false
	_square_active = false
	_up_down_shooting_active = false
	_grow_shrink_active = false

	# Kill attack tween if active
	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()

	# Stop telegraph effect
	_stop_attack_telegraph()


## Reset boss health to full and reset attack state for player respawn
func reset_health() -> void:
	## Restore health to max
	health = _max_health

	## Clear destroying state in case it was set
	_is_destroying = false

	## Re-enable collision using set_deferred to avoid signal conflicts
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)

	## Reset attack state machine
	_attack_cycle_active = true
	_attack_state = AttackState.IDLE
	_current_pattern = 0
	_attack_timer = 0.0

	## Clear any active attack states
	_sweep_active = false
	_charge_active = false
	_heat_wave_active = false
	_circle_active = false
	_wall_attack_active = false
	_square_active = false
	_up_down_shooting_active = false
	_grow_shrink_active = false

	## Kill any active tweens
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()
	if _telegraph_tween and _telegraph_tween.is_valid():
		_telegraph_tween.kill()

	## Ensure sprite is visible
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite:
		sprite.visible = true
		sprite.modulate = Color(1, 1, 1, 1)

	## Emit health changed to update health bar
	health_changed.emit(health, _max_health)


## Get current attack state (for testing)
func get_attack_state() -> AttackState:
	return _attack_state


## Check if attack cycle is active
func is_attacking() -> bool:
	return _attack_cycle_active


## Check if currently charging (for testing)
func is_charging() -> bool:
	return _charge_active


## Check if currently sweeping (for testing)
func is_sweeping() -> bool:
	return _sweep_active


## Check if currently in heat wave (for testing)
func is_heat_waving() -> bool:
	return _heat_wave_active


## Configure boss from level metadata
func configure(config: Dictionary) -> void:
	# Set health
	if config.has("health"):
		health = config.health
		_max_health = config.health

	# Set attack cooldown
	if config.has("attack_cooldown"):
		attack_cooldown = config.attack_cooldown

	# Set wind-up duration
	if config.has("wind_up_duration"):
		wind_up_duration = config.wind_up_duration

	# Set enabled attacks (array of attack indices: 0=barrage, 1=sweep, 2=charge, 3=solar_flare, 4=heat_wave, 5=ice_shards, 6=frozen_nova, 7=pepperoni_spread, 8=circle_movement, 9=wall_attack, 10=square_movement, 11=up_down_shooting, 12=grow_shrink, 13=rapid_jelly)
	if config.has("attacks"):
		_enabled_attacks.clear()
		for attack in config.attacks:
			_enabled_attacks.append(int(attack))
		_attack_count = _enabled_attacks.size()
		if _attack_count == 0:
			# Fallback to barrage if no attacks specified
			_enabled_attacks = [0]
			_attack_count = 1

	# Set scale
	if config.has("scale"):
		var sprite = get_node_or_null("AnimatedSprite2D")
		var collision = get_node_or_null("CollisionShape2D")
		var scale_value = float(config.scale)
		if sprite:
			sprite.scale = Vector2(scale_value, scale_value)
		if collision and collision.shape:
			# Scale collision relative to base size (75x62.5 at scale 1)
			var base_width = 75.0
			var base_height = 62.5
			collision.shape.size = Vector2(base_width * scale_value, base_height * scale_value)

	# Set explosion scale
	if config.has("explosion_scale"):
		explosion_scale = config.explosion_scale

	# Set custom explosion sprite
	if config.has("explosion_sprite"):
		explosion_sprite = config["explosion_sprite"]

	# Set custom projectile texture
	if config.has("projectile_sprite"):
		var sprite_path = config["projectile_sprite"]
		var texture = load(sprite_path)
		if texture:
			_projectile_texture = texture
		else:
			push_warning("Could not load projectile sprite: %s" % sprite_path)

	# Set projectile rotation speed (for swirl effects)
	if config.has("projectile_rotation_speed"):
		_projectile_rotation_speed = config["projectile_rotation_speed"]


## Play a sound effect via AudioManager
func _play_sfx(sfx_name: String) -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx(sfx_name)
