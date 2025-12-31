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

## Battle position (right third of screen)
var _battle_position: Vector2 = Vector2.ZERO

## Attack state machine
enum AttackState { IDLE, WIND_UP, ATTACKING, COOLDOWN }
var _attack_state: AttackState = AttackState.IDLE

## Current attack pattern index (0 = barrage, 1 = sweep, 2 = charge)
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


func _process(delta: float) -> void:
	if _is_destroying or not _entrance_complete:
		return

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

		AttackState.WIND_UP:
			_attack_timer -= delta
			if _attack_timer <= 0:
				_attack_state = AttackState.ATTACKING
				_execute_attack()

		AttackState.ATTACKING:
			# Attack execution is instant, move to cooldown
			_attack_state = AttackState.COOLDOWN
			_attack_timer = attack_cooldown

		AttackState.COOLDOWN:
			_attack_timer -= delta
			if _attack_timer <= 0:
				# Move to next pattern
				_current_pattern = (_current_pattern + 1) % 3
				_attack_state = AttackState.IDLE


func _execute_attack() -> void:
	match _current_pattern:
		0:
			_attack_horizontal_barrage()
		1:
			# Vertical sweep (to be implemented in Slice 4)
			_attack_horizontal_barrage()
		2:
			# Charge attack (to be implemented in Slice 4)
			_attack_horizontal_barrage()


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

	# Check if it's the player
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

	# Kill tweens if active
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
	if _entrance_tween and _entrance_tween.is_valid():
		_entrance_tween.kill()
	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()

	# Emit defeated signal
	boss_defeated.emit()

	# Play destruction animation (to be implemented in Slice 5)
	_play_destruction_animation()


func _play_destruction_animation() -> void:
	# Disable collision
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

	# Hide sprite
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite:
		sprite.visible = false

	# Create explosion (basic version, will be enhanced in Slice 5)
	var explosion_texture = load("res://assets/sprites/explosion.png")
	var explosion = Sprite2D.new()
	explosion.texture = explosion_texture
	explosion.scale = Vector2(4, 4)
	add_child(explosion)

	# Animate explosion
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(explosion, "scale", Vector2(8, 8), 0.5).set_ease(Tween.EASE_OUT)
	tween.tween_property(explosion, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(queue_free)


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


## Get current attack state (for testing)
func get_attack_state() -> AttackState:
	return _attack_state


## Check if attack cycle is active
func is_attacking() -> bool:
	return _attack_cycle_active
