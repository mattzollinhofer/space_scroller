extends Node2D
## Integration test: Patrol enemy takes 2 hits with red flash feedback
## - First hit: enemy survives, flashes red
## - Second hit: enemy dies with explosion
## - Stationary enemy still dies in one hit

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

# Test state tracking
var _patrol_first_hit_received: bool = false
var _patrol_flash_detected: bool = false
var _patrol_survived_first_hit: bool = false
var _patrol_died_on_second_hit: bool = false
var _stationary_died_on_one_hit: bool = false
var _phase: int = 0  # 0=setup, 1=first_hit, 2=verify_flash, 3=second_hit, 4=verify_stationary

var _patrol_enemy: Node = null
var _stationary_enemy: Node = null
var _player: Node = null
var _projectile_scene: PackedScene = null

# Tracking for flash detection
var _original_modulate: Color = Color.WHITE
var _sprite: Sprite2D = null


func _ready() -> void:
	print("=== Test: Patrol Enemy Two Hits with Red Flash ===")

	# Load projectile scene
	_projectile_scene = load("res://scenes/projectile.tscn")
	if not _projectile_scene:
		_fail("Could not load projectile scene")
		return

	# Create player
	var player_scene = load("res://scenes/player.tscn")
	if not player_scene:
		_fail("Could not load player scene")
		return
	_player = player_scene.instantiate()
	_player.position = Vector2(200, 768)
	_player.projectile_scene = _projectile_scene
	add_child(_player)

	# Create patrol enemy to the right of player
	var patrol_scene = load("res://scenes/enemies/patrol_enemy.tscn")
	if not patrol_scene:
		_fail("Could not load patrol enemy scene")
		return
	_patrol_enemy = patrol_scene.instantiate()
	_patrol_enemy.position = Vector2(600, 768)
	_patrol_enemy.scroll_speed = 0.0  # Stop scrolling during test
	_patrol_enemy.patrol_speed = 0.0  # Stop patrolling during test
	add_child(_patrol_enemy)

	# Get the sprite for flash detection
	_sprite = _patrol_enemy.get_node_or_null("Sprite2D")
	if _sprite:
		_original_modulate = _sprite.modulate
		print("Original patrol enemy modulate: %s" % _original_modulate)
	else:
		_fail("Patrol enemy has no Sprite2D node")
		return

	# Connect to patrol enemy signals
	if _patrol_enemy.has_signal("died"):
		_patrol_enemy.died.connect(_on_patrol_died)
	else:
		_fail("Patrol enemy does not have 'died' signal")
		return

	if _patrol_enemy.has_signal("hit_by_projectile"):
		_patrol_enemy.hit_by_projectile.connect(_on_patrol_hit)
	else:
		_fail("Patrol enemy does not have 'hit_by_projectile' signal")
		return

	# Check patrol enemy has health = 2
	if _patrol_enemy.health != 2:
		_fail("Patrol enemy health should be 2, but is %d" % _patrol_enemy.health)
		return

	print("Test setup complete. Phase 1: First hit on patrol enemy...")
	_phase = 1
	_player.shoot()


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	# Check for timeout
	if _timer >= _test_timeout:
		_fail("Test timed out in phase %d" % _phase)
		return

	match _phase:
		1:  # Waiting for first hit
			if _patrol_first_hit_received:
				# Verify enemy survived (health should be 1)
				if _patrol_enemy.health == 1:
					_patrol_survived_first_hit = true
					print("PASS: Patrol enemy survived first hit (health = 1)")
					_phase = 2
					_timer = 0.0
				else:
					_fail("Patrol enemy did not survive first hit (health = %d)" % _patrol_enemy.health)

		2:  # Check for red flash
			# Check if modulate changed to red tint
			if _sprite and _sprite.modulate != _original_modulate:
				var current = _sprite.modulate
				# Check for red tint (high red, low green)
				if current.r > 1.0 and current.g < 0.5:
					_patrol_flash_detected = true
					print("PASS: Red flash detected (modulate = %s)" % current)

			# Wait a short time for flash to complete, then fire second shot
			if _timer >= 0.3:
				print("Phase 3: Second hit on patrol enemy...")
				_phase = 3
				_player.shoot()

		3:  # Waiting for second hit and death
			if _patrol_died_on_second_hit:
				print("PASS: Patrol enemy died on second hit")
				_phase = 4
				_timer = 0.0
				_setup_stationary_enemy()

		4:  # Verify stationary enemy still dies in one hit
			if _stationary_died_on_one_hit:
				_verify_all_passed()


func _on_patrol_hit() -> void:
	print("Patrol enemy hit signal received!")
	_patrol_first_hit_received = true


func _on_patrol_died() -> void:
	print("Patrol enemy died signal received!")
	_patrol_died_on_second_hit = true


func _on_stationary_died() -> void:
	print("Stationary enemy died signal received!")
	_stationary_died_on_one_hit = true


func _setup_stationary_enemy() -> void:
	# Create a stationary enemy to verify it still dies in one hit
	var stationary_scene = load("res://scenes/enemies/stationary_enemy.tscn")
	if not stationary_scene:
		_fail("Could not load stationary enemy scene")
		return
	_stationary_enemy = stationary_scene.instantiate()
	_stationary_enemy.position = Vector2(600, 768)
	_stationary_enemy.scroll_speed = 0.0
	add_child(_stationary_enemy)

	if _stationary_enemy.has_signal("died"):
		_stationary_enemy.died.connect(_on_stationary_died)

	# Verify stationary enemy has health = 1
	if _stationary_enemy.health != 1:
		_fail("Stationary enemy health should be 1, but is %d" % _stationary_enemy.health)
		return

	print("Phase 4: One hit on stationary enemy...")
	_player.shoot()


func _verify_all_passed() -> void:
	if not _patrol_survived_first_hit:
		_fail("Patrol enemy did not survive first hit")
		return

	if not _patrol_flash_detected:
		_fail("Red flash effect was not detected on first hit")
		return

	if not _patrol_died_on_second_hit:
		_fail("Patrol enemy did not die on second hit")
		return

	if not _stationary_died_on_one_hit:
		_fail("Stationary enemy did not die in one hit")
		return

	_pass()


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("- Patrol enemy survived first hit")
	print("- Red flash effect visible on first hit")
	print("- Patrol enemy died on second hit")
	print("- Stationary enemy still dies in one hit")
	await get_tree().create_timer(1.0).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(1.0).timeout
	get_tree().quit(1)
