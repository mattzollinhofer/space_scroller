extends Node2D
## Integration test: Boss Rapid Jelly Attack (attack type 13) fires 6 projectiles straight forward
## Verifies boss fires exactly 6 projectiles simultaneously, all traveling straight left.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _boss: Node = null
var _projectiles_spawned: Array = []


func _ready() -> void:
	print("=== Test: Boss Rapid Jelly Attack ===")

	# Load and instantiate boss scene
	var boss_scene = load("res://scenes/enemies/boss.tscn")
	if not boss_scene:
		_fail("Could not load boss scene")
		return

	_boss = boss_scene.instantiate()
	add_child(_boss)

	# Position boss for testing
	_boss.position = Vector2(800, 400)
	_boss._battle_position = Vector2(800, 400)
	_boss._entrance_complete = true

	# Configure boss with only rapid jelly attack (attack type 13)
	_boss.configure({
		"health": 10,
		"attacks": [13]
	})

	print("Boss configured with attack type 13 (Rapid Jelly Attack)")
	print("Enabled attacks: %s" % str(_boss._enabled_attacks))

	# Wait a frame for setup
	await get_tree().process_frame

	# Start attack cycle
	_boss.start_attack_cycle()

	# Wait for wind-up and attack execution
	print("Waiting for attack to execute...")
	await get_tree().create_timer(1.5).timeout

	# Count projectiles spawned - they are added to this node (the parent of boss)
	_count_projectiles()

	print("Projectiles spawned: %d" % _projectiles_spawned.size())

	# Verify exactly 6 projectiles were spawned
	if _projectiles_spawned.size() != 6:
		_fail("Expected exactly 6 projectiles, got: %d" % _projectiles_spawned.size())
		return

	print("Correct number of projectiles spawned (6)")

	# Verify all projectiles are traveling straight left (direction Vector2(-1, 0))
	for i in range(_projectiles_spawned.size()):
		var projectile = _projectiles_spawned[i]
		if "direction" in projectile:
			var dir = projectile.direction
			# Check direction is straight left (y component should be 0 or very close)
			if abs(dir.y) > 0.01:
				_fail("Projectile %d has wrong direction: %s (expected straight left)" % [i, str(dir)])
				return
			if dir.x >= 0:
				_fail("Projectile %d is not moving left: %s" % [i, str(dir)])
				return
			print("Projectile %d direction: %s (correct)" % [i, str(dir)])

	print("All 6 projectiles traveling straight left")

	# All checks passed
	_pass()


func _count_projectiles() -> void:
	_projectiles_spawned.clear()

	# Projectiles are added to the boss's parent, which is this test node
	# Look for any node that looks like a projectile
	for child in get_children():
		# Skip the boss itself
		if child == _boss:
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
	print("Boss Rapid Jelly Attack fires 6 projectiles straight left correctly.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
