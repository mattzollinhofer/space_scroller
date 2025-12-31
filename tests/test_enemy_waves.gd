extends Node2D
## Integration test: Enemy wave spawns when new section starts
## Run this scene to verify wave-based enemy spawning works.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 15.0
var _timer: float = 0.0

var level_manager: Node = null
var enemy_spawner: Node = null
var scroll_controller: Node = null
var _initial_enemy_count: int = 0
var _wave_spawned: bool = false
var _target_section: int = 1  # Wait for section 1 wave


func _ready() -> void:
	print("=== Test: Enemy Wave Spawning ===")

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

	# Connect to section_changed signal
	level_manager.section_changed.connect(_on_section_changed)

	# Find the enemy spawner
	enemy_spawner = main.get_node_or_null("EnemySpawner")
	if not enemy_spawner:
		_fail("EnemySpawner node not found in main scene")
		return

	# Check for spawn_wave method
	if not enemy_spawner.has_method("spawn_wave"):
		_fail("EnemySpawner does not have 'spawn_wave' method")
		return

	# Check for set_continuous_spawning method
	if not enemy_spawner.has_method("set_continuous_spawning"):
		_fail("EnemySpawner does not have 'set_continuous_spawning' method")
		return

	# Speed up scroll for testing
	scroll_controller = main.get_node_or_null("ParallaxBackground")
	if scroll_controller:
		scroll_controller.scroll_speed = 1800.0
		print("Speeding up scroll for test: 1800 px/s")

	# Store initial enemy count (should be from initial spawn)
	_initial_enemy_count = enemy_spawner.get_active_count()
	print("Initial enemy count: %s" % _initial_enemy_count)

	print("Test setup complete. Waiting for section 1 enemy wave...")


func _on_section_changed(section_index: int) -> void:
	print("Section changed to: %s" % section_index)

	if section_index == _target_section:
		# Wait a frame for wave to spawn
		await get_tree().process_frame
		await get_tree().process_frame

		var current_count = enemy_spawner.get_active_count()
		print("Enemy count after section %s: %s" % [section_index, current_count])

		# Check if new enemies were spawned (wave occurred)
		# Section 1 should spawn 2 stationary + 1 patrol = 3 new enemies
		if current_count > _initial_enemy_count:
			_wave_spawned = true
			print("Wave spawned! New enemies: %s" % (current_count - _initial_enemy_count))
			_pass()
		else:
			_fail("Section changed but no new enemies spawned (count: %s, initial: %s)" % [current_count, _initial_enemy_count])


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	if _timer >= _test_timeout:
		_fail("Test timed out - no enemy wave within %s seconds" % _test_timeout)
		return


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Enemy waves spawn at section boundaries.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
