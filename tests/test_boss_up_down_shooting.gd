extends Node2D
## Integration test: Boss Up/Down Shooting Attack (attack type 11) moves vertically while spawning projectiles
## Verifies boss moves vertically and fires projectiles continuously during movement.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _boss: Node = null
var _projectiles_spawned: Array = []
var _initial_y: float = 0.0
var _y_positions: Array = []


func _ready() -> void:
	print("=== Test: Boss Up/Down Shooting Attack ===")

	# Load and instantiate boss scene
	var boss_scene = load("res://scenes/enemies/boss.tscn")
	if not boss_scene:
		_fail("Could not load boss scene")
		return

	_boss = boss_scene.instantiate()
	add_child(_boss)

	# Position boss for testing
	_boss.position = Vector2(800, 700)  # Middle-ish Y position
	_boss._battle_position = Vector2(800, 700)
	_boss._entrance_complete = true
	_initial_y = _boss.position.y

	# Configure boss with only up/down shooting attack (attack type 11)
	_boss.configure({
		"health": 10,
		"attacks": [11]
	})

	print("Boss configured with attack type 11 (Up/Down Shooting)")
	print("Enabled attacks: %s" % str(_boss._enabled_attacks))

	# Wait a frame for setup
	await get_tree().process_frame

	# Start attack cycle
	_boss.start_attack_cycle()

	# Track Y positions and count projectiles during attack
	print("Waiting for attack to execute...")

	# Check every 0.2 seconds for 3 seconds
	for i in range(15):
		await get_tree().create_timer(0.2).timeout
		_y_positions.append(_boss.position.y)
		_count_projectiles()

		# Check if boss is in up/down shooting state
		if _boss.has_method("is_up_down_shooting") and _boss.is_up_down_shooting():
			print("Boss is in up/down shooting state at Y=%f" % _boss.position.y)

	# Final projectile count
	_count_projectiles()

	print("Y positions recorded: %s" % str(_y_positions))
	print("Projectiles spawned: %d" % _projectiles_spawned.size())

	# Verify boss moved vertically (Y changed significantly)
	var min_y = _y_positions.min()
	var max_y = _y_positions.max()
	var y_travel = max_y - min_y

	print("Y travel distance: %f (min: %f, max: %f)" % [y_travel, min_y, max_y])

	if y_travel < 200:
		_fail("Boss did not move vertically enough. Y travel: %f (expected > 200)" % y_travel)
		return

	print("Boss moved vertically: travel distance = %f" % y_travel)

	# Verify projectiles were spawned during movement
	if _projectiles_spawned.size() < 3:
		_fail("Expected at least 3 projectiles, got: %d" % _projectiles_spawned.size())
		return

	print("Correct number of projectiles spawned (%d)" % _projectiles_spawned.size())

	# All checks passed
	_pass()


func _count_projectiles() -> void:
	# Projectiles are added to the boss's parent, which is this test node
	# Look for any node that looks like a projectile
	for child in get_children():
		# Skip the boss itself
		if child == _boss:
			continue

		# Skip already tracked projectiles
		if child in _projectiles_spawned:
			continue

		# Check if it's a projectile (has speed property or is an Area2D with direction)
		if child is Area2D:
			# Check if it looks like a projectile (has speed or direction property)
			if "speed" in child or "direction" in child:
				_projectiles_spawned.append(child)
				continue

		# Also check by name pattern
		if "BossProjectile" in child.name or "Projectile" in child.name:
			_projectiles_spawned.append(child)


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Boss Up/Down Shooting attack moves vertically and spawns projectiles correctly.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
