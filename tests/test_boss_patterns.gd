extends Node2D
## Integration test: Boss cycles through multiple attack patterns
## Run this scene to verify boss performs vertical sweep and charge attacks.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 30.0
var _timer: float = 0.0

var main: Node = null
var level_manager: Node = null
var _boss: Node = null
var _player: Node = null
var _boss_spawned: bool = false

## Track observed patterns
var _patterns_observed: Array = []
var _initial_boss_position: Vector2 = Vector2.ZERO
var _position_changes_detected: int = 0


func _ready() -> void:
	print("=== Test: Boss Attack Pattern Cycling ===")

	# Load and setup main scene
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene:
		_fail("Could not load main scene")
		return

	main = main_scene.instantiate()
	add_child(main)

	# Find level manager
	level_manager = main.get_node_or_null("LevelManager")
	if not level_manager:
		_fail("LevelManager node not found")
		return

	# Find player
	_player = main.get_node_or_null("Player")
	if not _player:
		_fail("Player node not found")
		return

	# Connect to boss_spawned signal
	if level_manager.has_signal("boss_spawned"):
		level_manager.boss_spawned.connect(_on_boss_spawned)

	# Speed up scroll to reach boss quickly
	var scroll_controller = main.get_node_or_null("ParallaxBackground")
	if scroll_controller:
		scroll_controller.scroll_speed = 9000.0
		print("Speeding up scroll for test: 9000 px/s")

	print("Test setup complete. Waiting for boss to spawn...")


func _on_boss_spawned() -> void:
	print("Boss spawned signal received")
	_boss_spawned = true

	# Wait for boss entrance to complete
	await get_tree().create_timer(2.5).timeout

	_verify_boss_and_test_patterns()


func _verify_boss_and_test_patterns() -> void:
	if _test_passed or _test_failed:
		return

	# Find the boss in scene
	_boss = level_manager.get_boss() if level_manager.has_method("get_boss") else null
	if not _boss:
		_boss = _find_boss_in_tree(main)

	if not _boss:
		_fail("Boss not found in scene tree")
		return

	print("Boss found: " + _boss.name)

	# Store initial boss position
	_initial_boss_position = _boss.position
	print("Initial boss position: " + str(_initial_boss_position))

	# Position player in safe area for testing
	_player.position = Vector2(300, 768)
	print("Player positioned at: " + str(_player.position))

	# Configure boss to have all 3 attack patterns for this test
	# (Level 1 only has pattern 0 by default)
	if _boss.has_method("configure"):
		var config = {"attacks": [0, 1, 2], "attack_cooldown": 1.0}
		_boss.configure(config)
		print("Configured boss with all 3 attack patterns")


	# Start the attack cycle
	if _boss.has_method("start_attack_cycle"):
		_boss.start_attack_cycle()
	else:
		_fail("Boss does not have start_attack_cycle method")
		return

	# Monitor attack patterns over multiple cycles
	_monitor_attack_patterns()


func _monitor_attack_patterns() -> void:
	if _test_passed or _test_failed:
		return

	var cycle_wait_time = 12.0  # Time to wait for one full cycle

	print("Monitoring attack patterns for " + str(cycle_wait_time) + " seconds...")

	var start_time = Time.get_ticks_msec()
	var last_pattern = -1

	while (Time.get_ticks_msec() - start_time) < (cycle_wait_time * 1000):
		if _test_passed or _test_failed:
			return

		await get_tree().create_timer(0.1).timeout

		if not is_instance_valid(_boss):
			_fail("Boss was destroyed during test")
			return

		# Check current pattern
		var current_pattern = _boss._current_pattern if "_current_pattern" in _boss else -1
		if current_pattern >= 0 and current_pattern != last_pattern:
			if not _patterns_observed.has(current_pattern):
				_patterns_observed.append(current_pattern)
				print("Observed pattern " + str(current_pattern))
			last_pattern = current_pattern

		# Check for position changes (indicates sweep or charge)
		var current_position = _boss.position
		var position_delta = current_position.distance_to(_initial_boss_position)
		if position_delta > 50:  # Significant movement
			if _position_changes_detected < 5:
				_position_changes_detected += 1
				print("Position change detected: delta = " + str(position_delta))

	_evaluate_results()


func _evaluate_results() -> void:
	if _test_passed or _test_failed:
		return

	print("")
	print("=== Pattern Observation Results ===")
	print("Patterns observed: " + str(_patterns_observed))
	print("Position changes detected: " + str(_position_changes_detected))

	# Check if we observed multiple patterns
	if _patterns_observed.size() < 2:
		_fail("Did not observe multiple attack patterns (only saw " + str(_patterns_observed.size()) + ")")
		return

	# Check if we saw all 3 patterns
	var has_barrage = _patterns_observed.has(0)
	var has_sweep = _patterns_observed.has(1)
	var has_charge = _patterns_observed.has(2)

	print("Pattern 0 (barrage): " + str(has_barrage))
	print("Pattern 1 (sweep): " + str(has_sweep))
	print("Pattern 2 (charge): " + str(has_charge))

	if not has_barrage:
		_fail("Did not observe barrage attack (pattern 0)")
		return

	if not has_sweep:
		_fail("Did not observe vertical sweep attack (pattern 1)")
		return

	if not has_charge:
		_fail("Did not observe charge attack (pattern 2)")
		return

	# Check for position changes (sweep and charge should move the boss)
	if _position_changes_detected < 1:
		_fail("Boss position did not change during attacks (sweep/charge should move boss)")
		return

	_pass()


func _find_boss_in_tree(node: Node) -> Node:
	if "Boss" in node.name or "boss" in node.name.to_lower():
		if node.has_method("take_hit"):
			return node

	if node.get_script():
		var script_path = node.get_script().resource_path
		if "boss.gd" in script_path:
			return node

	for child in node.get_children():
		var found = _find_boss_in_tree(child)
		if found:
			return found

	return null


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	if _timer >= _test_timeout:
		_fail("Test timed out - boss_spawned: " + str(_boss_spawned) + ", patterns_observed: " + str(_patterns_observed))
		return


func _pass() -> void:
	_test_passed = true
	print("")
	print("=== TEST PASSED ===")
	print("Boss cycles through all attack patterns correctly.")
	print("- Barrage: YES")
	print("- Vertical Sweep: YES")
	print("- Charge: YES")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("")
	print("=== TEST FAILED ===")
	print("Reason: " + reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
