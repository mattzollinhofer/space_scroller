extends Node2D
## Integration test: Level complete screen shows when progress reaches 100%
## Run this scene to verify level completion works.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 10.0
var _timer: float = 0.0

var level_manager: Node = null
var level_complete_screen: Node = null
var scroll_controller: Node = null
var _level_completed_emitted: bool = false


func _ready() -> void:
	print("=== Test: Level Complete ===")

	# Load and setup main scene
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene:
		_fail("Could not load main scene")
		return

	var main = main_scene.instantiate()
	add_child(main)

	# Find level manager
	level_manager = main.get_node_or_null("LevelManager")
	if not level_manager:
		_fail("LevelManager node not found")
		return

	# Check for level_completed signal
	if not level_manager.has_signal("level_completed"):
		_fail("LevelManager does not have 'level_completed' signal")
		return

	# Connect to level_completed signal
	level_manager.level_completed.connect(_on_level_completed)

	# Find level complete screen
	level_complete_screen = main.get_node_or_null("LevelCompleteScreen")
	if not level_complete_screen:
		_fail("LevelCompleteScreen node not found in main scene")
		return

	# Speed up scroll to finish level quickly
	scroll_controller = main.get_node_or_null("ParallaxBackground")
	if scroll_controller:
		# At 9000px total distance, 9000 px/s = 1 second to finish
		scroll_controller.scroll_speed = 9000.0
		print("Speeding up scroll for test: 9000 px/s")

	print("Test setup complete. Waiting for level completion...")


func _on_level_completed() -> void:
	print("level_completed signal emitted!")
	_level_completed_emitted = true

	# Wait a frame for UI to update
	await get_tree().process_frame
	await get_tree().process_frame

	_check_level_complete()


func _check_level_complete() -> void:
	if _test_passed or _test_failed:
		return

	# Check if level complete screen is visible
	if level_complete_screen and level_complete_screen.visible:
		print("Level complete screen is visible")
		_pass()
	else:
		_fail("Level complete screen not visible (visible: %s)" % (level_complete_screen.visible if level_complete_screen else "null"))


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	if _timer >= _test_timeout:
		var progress = level_manager.get_progress() if level_manager else -1
		_fail("Test timed out - progress: %s, level_completed emitted: %s" % [progress, _level_completed_emitted])
		return


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Level complete screen shows when progress reaches 100%%.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
