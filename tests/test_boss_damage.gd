extends Node2D
## Integration test: Boss takes damage and health bar updates
## Run this scene to verify boss damage system and health bar UI.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 15.0
var _timer: float = 0.0

var main: Node = null
var level_manager: Node = null
var _boss: Node = null
var _health_bar: Node = null
var _initial_boss_health: int = 13
var _health_after_damage: int = -1
var _boss_spawned: bool = false


func _ready() -> void:
	print("=== Test: Boss Damage and Health Bar ===")

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

	# Wait for boss to be added and entrance to complete
	await get_tree().create_timer(2.5).timeout

	_verify_boss_and_test_damage()


func _verify_boss_and_test_damage() -> void:
	if _test_passed or _test_failed:
		return

	# Find the boss in scene
	_boss = level_manager.get_boss() if level_manager.has_method("get_boss") else null
	if not _boss:
		_boss = _find_boss_in_tree(main)

	if not _boss:
		_fail("Boss not found in scene tree")
		return

	print("Boss found: %s" % _boss.name)

	# Verify boss has health property
	if not "health" in _boss:
		_fail("Boss does not have health property")
		return

	_initial_boss_health = _boss.health
	print("Initial boss health: %d" % _initial_boss_health)

	if _initial_boss_health != 13:
		_fail("Boss initial health should be 13, got: %d" % _initial_boss_health)
		return

	# Find health bar in scene
	_health_bar = _find_health_bar_in_tree(main)
	if not _health_bar:
		_fail("Boss health bar not found in scene")
		return

	print("Health bar found: %s" % _health_bar.name)

	# Verify boss has take_hit method
	if not _boss.has_method("take_hit"):
		_fail("Boss does not have take_hit method")
		return

	# Deal damage to boss
	print("Dealing 1 damage to boss...")
	_boss.take_hit(1)

	# Wait a frame for health update
	await get_tree().process_frame
	await get_tree().process_frame

	_health_after_damage = _boss.health
	print("Boss health after damage: %d" % _health_after_damage)

	# Verify health decreased
	if _health_after_damage != _initial_boss_health - 1:
		_fail("Boss health should be %d after 1 damage, got: %d" % [_initial_boss_health - 1, _health_after_damage])
		return

	# Verify health bar updated
	if not _verify_health_bar_updated():
		return

	# Test multiple hits
	print("Dealing 5 more damage to boss...")
	for i in range(5):
		_boss.take_hit(1)
		await get_tree().process_frame

	var health_after_multiple = _boss.health
	print("Boss health after 6 total hits: %d" % health_after_multiple)

	if health_after_multiple != 13 - 6:
		_fail("Boss health should be 7 after 6 hits, got: %d" % health_after_multiple)
		return

	_pass()


func _verify_health_bar_updated() -> bool:
	if not _health_bar:
		_fail("Health bar is null")
		return false

	# Check if health bar has a method to get current fill percentage
	if _health_bar.has_method("get_fill_percent"):
		var fill = _health_bar.get_fill_percent()
		var expected_fill = float(_health_after_damage) / float(_initial_boss_health)
		print("Health bar fill: %f, expected: %f" % [fill, expected_fill])
		if abs(fill - expected_fill) > 0.01:
			_fail("Health bar fill should be ~%f, got: %f" % [expected_fill, fill])
			return false
	else:
		# Just verify the health bar exists and is visible
		if not _health_bar.visible:
			_fail("Health bar should be visible")
			return false
		print("Health bar is visible (no get_fill_percent method)")

	return true


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


func _find_health_bar_in_tree(node: Node) -> Node:
	# Look for BossHealthBar node by name or script
	if "BossHealthBar" in node.name or "boss_health" in node.name.to_lower():
		return node

	if node.get_script():
		var script_path = node.get_script().resource_path
		if "boss_health_bar.gd" in script_path:
			return node

	for child in node.get_children():
		var found = _find_health_bar_in_tree(child)
		if found:
			return found

	return null


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	if _timer >= _test_timeout:
		_fail("Test timed out - boss_spawned: %s" % _boss_spawned)
		return


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Boss takes damage and health bar updates correctly.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
