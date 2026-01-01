extends Area2D
class_name Boss
## Boss enemy with entrance animation, health system, and attack patterns.
## Spawns when level reaches 100% progress.

## Health of the boss
@export var health: int = 13:
	set(value):
		health = value
		health_changed.emit(health, _max_health)
		if health <= 0:
			_on_health_depleted()

## Boss projectile scene to spawn
@export var boss_projectile_scene: PackedScene

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

## Current attack pattern index (0 = barrage, 1 = sweep, 2 = charge, 3 = solar flare, 4 = heat wave, 5 = ice shards, 6 = frozen nova)
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

## Explosion scale multiplier (boss is larger than regular enemies)
@export var explosion_scale: float = 8.0

## Shake node for screen shake effect
var _shake_node: Node2D = null

## Which attack patterns are enabled (0=barrage, 1=sweep, 2=charge, 3=solar_flare, 4=heat_wave, 5=ice_shards, 6=frozen_nova)
var _enabled_attacks: Array[int] = [0, 1, 2]

## Number of attack patterns enabled
var _attack_count: int = 3

## Whether currently in a heat wave attack
var _heat_wave_active: bool = false

## Heat wave projectile interval timer
var _heat_wave_projectile_timer: float = 0.0

## Heat wave projectile fire interval (faster than normal sweep)
@export var heat_wave_fire_interval: float = 0.15

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
			# For sweep, charge, and heat wave, wait for tween to complete
			if _sweep_active or _charge_active or _heat_wave_active:
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
	boss_entered.emit()

	# Start attack cycle after entrance
	start_attack_cycle()


func _on_body_entered(body: Node2D) -> void:
	if _is_destroying:
		return

	# Check if it's the player - deals contact damage during charge
	if body.has_method("take_damage"):
		body.take_damage()


func _on_area_entered(_area: Area2D) -> void:
	if _is_destroying:
		return
	# Projectiles call take_hit on the boss
	pass


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
	sprite.scale = original_scale * 1.2

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

	# Create large boss explosion
	var explosion_texture = load("res://assets/sprites/explosion.png")
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

	# Set enabled attacks (array of attack indices: 0=barrage, 1=sweep, 2=charge, 3=solar_flare, 4=heat_wave, 5=ice_shards, 6=frozen_nova)
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


## Play a sound effect via AudioManager
func _play_sfx(sfx_name: String) -> void:
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sfx(sfx_name)
