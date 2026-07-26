extends Node2D
## Integration test: Boss Square Movement (attack type 10) executes correctly
## Verifies boss moves in rectangular path during attack and returns to battle position.

const TestHelpers = preload("res://tests/test_helpers.gd")

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _boss: Node = null
var _initial_position: Vector2
var _position_changed: bool = false
var _battle_position: Vector2


func _ready() -> void:
	print("=== Test: Boss Square Movement ===")

	# Load and instantiate boss scene
	var boss_scene = load("res://scenes/enemies/boss.tscn")
	if not boss_scene:
		_fail("Could not load boss scene")
		return

	_boss = boss_scene.instantiate()
	add_child(_boss)

	# Position boss for testing
	_battle_position = Vector2(800, 400)
	_boss.position = _battle_position
	_boss._battle_position = _battle_position
	_boss._entrance_complete = true

	# Configure boss with only square movement attack (attack type 10)
	_boss.configure({
		"health": 10,
		"attacks": [10]
	})

	print("Boss configured with attack type 10 (Square Movement)")
	print("Enabled attacks: %s" % str(_boss._enabled_attacks))

	# Record initial position
	_initial_position = _boss.position
	print("Initial position: %s" % str(_initial_position))

	# Wait a frame for setup
	await get_tree().process_frame

	# Start attack cycle
	_boss.start_attack_cycle()

	# Phase 1: poll until the boss has moved significantly away from its start
	# position. Only the square-movement attack moves it, so this confirms the
	# attack is underway (replaces a fixed 2.5s monitor window).
	print("Monitoring position during square movement...")
	_position_changed = await TestHelpers.poll_until(get_tree(), func(): return _boss.position.distance_to(_initial_position) > 50, 4.0)

	# Verify position changed during attack
	if not _position_changed:
		_fail("Boss position did not change during Square Movement attack")
		return

	print("Position changed during attack - PASS")

	# Phase 2: poll until the attack completes and the boss is back at its battle
	# position. Catch it the instant the square path finishes, before idle drift
	# during cooldown can push it away again - the old fixed 2.5s wait was flaky
	# because drift had already moved the boss past tolerance by the time it checked.
	print("Waiting for attack to complete and boss to return...")
	var returned := await TestHelpers.poll_until(get_tree(), func(): return not _boss.is_square_moving() and _boss.position.distance_to(_battle_position) <= 100, 6.0)

	# Verify boss returned to battle position (with some tolerance)
	var final_pos = _boss.position
	var distance_from_battle = final_pos.distance_to(_battle_position)
	print("Final position: %s, distance from battle position: %.1f, returned=%s" % [str(final_pos), distance_from_battle, str(returned)])

	if distance_from_battle > 100:
		_fail("Boss did not return to battle position. Distance: %.1f" % distance_from_battle)
		return

	print("Boss returned to battle position - PASS")

	# All checks passed
	_pass()


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Boss Square Movement attack executes correctly.")
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	get_tree().quit(1)
