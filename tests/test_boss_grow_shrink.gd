extends Node2D
## Integration test: Boss Grow/Shrink Attack (attack type 12) scales to 4x then returns to normal
## Verifies boss scales up to 4x original size then shrinks back to normal.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _boss: Node = null
var _initial_scale: Vector2 = Vector2.ONE
var _max_scale_reached: float = 0.0
var _scale_samples: Array = []


func _ready() -> void:
	print("=== Test: Boss Grow/Shrink Attack ===")

	# Load and instantiate boss scene
	var boss_scene = load("res://scenes/enemies/boss.tscn")
	if not boss_scene:
		_fail("Could not load boss scene")
		return

	_boss = boss_scene.instantiate()
	add_child(_boss)

	# Position boss for testing
	_boss.position = Vector2(800, 700)
	_boss._battle_position = Vector2(800, 700)
	_boss._entrance_complete = true

	# Get initial sprite scale
	var sprite = _boss.get_node_or_null("AnimatedSprite2D")
	if sprite:
		_initial_scale = sprite.scale
		print("Initial sprite scale: %s" % str(_initial_scale))
	else:
		_fail("Boss has no AnimatedSprite2D")
		return

	# Configure boss with only grow/shrink attack (attack type 12)
	_boss.configure({
		"health": 10,
		"attacks": [12]
	})

	print("Boss configured with attack type 12 (Grow/Shrink)")
	print("Enabled attacks: %s" % str(_boss._enabled_attacks))

	# Wait a frame for setup
	await get_tree().process_frame

	# Start attack cycle
	_boss.start_attack_cycle()

	# Track scale during attack
	print("Waiting for attack to execute...")

	# Check every 0.1 seconds for 4 seconds to capture scale changes
	for i in range(40):
		await get_tree().create_timer(0.1).timeout

		var current_scale = sprite.scale
		_scale_samples.append(current_scale.x)

		if current_scale.x > _max_scale_reached:
			_max_scale_reached = current_scale.x
			print("New max scale reached: %f" % _max_scale_reached)

		# Check if boss is in grow/shrink state
		if _boss.has_method("is_grow_shrinking") and _boss.is_grow_shrinking():
			print("Boss is in grow/shrink state at scale=%f" % current_scale.x)

	# Final scale check
	var final_scale = sprite.scale
	print("Scale samples: %s" % str(_scale_samples))
	print("Max scale reached: %f" % _max_scale_reached)
	print("Final scale: %s" % str(final_scale))

	# Calculate expected max scale (4x initial)
	var expected_max = _initial_scale.x * 4.0

	# Verify boss scaled up to at least 3.5x initial (allowing some tolerance)
	if _max_scale_reached < _initial_scale.x * 3.5:
		_fail("Boss did not scale up to 4x. Max scale: %f, expected at least: %f" % [_max_scale_reached, _initial_scale.x * 3.5])
		return

	print("Boss scaled up correctly: max scale = %f (expected ~%f)" % [_max_scale_reached, expected_max])

	# Verify boss returned to approximately original scale (within 10%)
	var scale_diff = abs(final_scale.x - _initial_scale.x)
	if scale_diff > _initial_scale.x * 0.1:
		_fail("Boss did not return to original scale. Final: %f, expected: %f" % [final_scale.x, _initial_scale.x])
		return

	print("Boss returned to original scale correctly")

	# All checks passed
	_pass()


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Boss Grow/Shrink attack scales to 4x and returns to normal correctly.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
