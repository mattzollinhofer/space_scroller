extends Node2D
## Integration test: Obstacle density changes when section changes
## Run this scene to verify section-based difficulty progression works.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 15.0  # Longer timeout for section transition
var _timer: float = 0.0

var level_manager: Node = null
var obstacle_spawner: Node = null
var scroll_controller: Node = null
var _initial_section: int = -1
var _section_change_count: int = 0
var _initial_spawn_rate_min: float = -1.0
var _spawn_rate_after_section_1: float = -1.0


func _ready() -> void:
	print("=== Test: Section-Based Obstacle Density ===")

	# Load and setup main scene to get all components
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene:
		_fail("Could not load main scene")
		return

	var main = main_scene.instantiate()
	add_child(main)

	# Find the level manager
	level_manager = main.get_node_or_null("LevelManager")
	if not level_manager:
		_fail("LevelManager node not found in main scene")
		return

	# Check for section_changed signal
	if not level_manager.has_signal("section_changed"):
		_fail("LevelManager does not have 'section_changed' signal")
		return

	# Connect to section_changed signal
	level_manager.section_changed.connect(_on_section_changed)

	# Find the obstacle spawner
	obstacle_spawner = main.get_node_or_null("ObstacleSpawner")
	if not obstacle_spawner:
		_fail("ObstacleSpawner node not found in main scene")
		return

	# Check for set_density method
	if not obstacle_spawner.has_method("set_density"):
		_fail("ObstacleSpawner does not have 'set_density' method")
		return

	# Find scroll controller and speed it up for testing
	scroll_controller = main.get_node_or_null("ParallaxBackground")
	if scroll_controller:
		# Speed up scroll to reach section 1 faster (20% = 1800px at 1800px/s = 1 second)
		scroll_controller.scroll_speed = 1800.0
		print("Speeding up scroll for test: 1800 px/s")

	# Store initial spawn rate (should be "low" = 6.0 for section 0)
	_initial_spawn_rate_min = obstacle_spawner.spawn_rate_min
	print("Initial spawn_rate_min: %s" % _initial_spawn_rate_min)

	print("Test setup complete. Waiting for section change to section 1...")


func _on_section_changed(section_index: int) -> void:
	print("Section changed to: %s" % section_index)
	_section_change_count += 1

	if _initial_section < 0:
		_initial_section = section_index
		_initial_spawn_rate_min = obstacle_spawner.spawn_rate_min
		print("Initial section %s, spawn_rate_min: %s" % [section_index, _initial_spawn_rate_min])
	elif section_index > _initial_section:
		# We've moved to a new section, check density change
		_spawn_rate_after_section_1 = obstacle_spawner.spawn_rate_min
		print("Section %s, spawn_rate_min: %s" % [section_index, _spawn_rate_after_section_1])

		if _spawn_rate_after_section_1 != _initial_spawn_rate_min:
			print("Density changed from %s to %s" % [_initial_spawn_rate_min, _spawn_rate_after_section_1])
			_pass()
		else:
			_fail("Section changed but spawn_rate_min did not change (still %s)" % _spawn_rate_after_section_1)


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	# Check for timeout
	if _timer >= _test_timeout:
		_fail("Test timed out - no section density change within %s seconds (changes: %s)" % [_test_timeout, _section_change_count])
		return


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Obstacle density changes when section changes.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
