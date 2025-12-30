extends Node2D
## Integration test: Progress bar exists and updates from 0% toward 100%
## Run this scene to verify level progress tracking works end-to-end.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 3.0
var _timer: float = 0.0
var _initial_progress: float = -1.0
var _progress_increased: bool = false

var progress_bar: Node = null
var level_manager: Node = null


func _ready() -> void:
	print("=== Test: Progress Bar Display and Updates ===")

	# Load and setup main scene to get all components
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene:
		_fail("Could not load main scene")
		return

	var main = main_scene.instantiate()
	add_child(main)

	# Find the progress bar in the scene
	progress_bar = main.get_node_or_null("ProgressBar")
	if not progress_bar:
		# Try alternative paths
		progress_bar = main.get_node_or_null("UILayer/ProgressBar")

	if not progress_bar:
		_fail("ProgressBar node not found in main scene")
		return

	# Check if progress bar has required method
	if not progress_bar.has_method("get_progress"):
		_fail("ProgressBar does not have 'get_progress' method")
		return

	# Find the level manager
	level_manager = main.get_node_or_null("LevelManager")
	if not level_manager:
		_fail("LevelManager node not found in main scene")
		return

	# Store initial progress
	_initial_progress = progress_bar.get_progress()
	print("Initial progress: %s%%" % (_initial_progress * 100))

	# Verify initial progress is at or near 0
	if _initial_progress > 0.1:
		_fail("Initial progress should be near 0%%, got %s%%" % (_initial_progress * 100))
		return

	print("Test setup complete. Waiting for progress to increase...")


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	# Check for timeout
	if _timer >= _test_timeout:
		if not _progress_increased:
			_fail("Test timed out - progress did not increase within %s seconds" % _test_timeout)
		return

	# Check if progress has increased
	if progress_bar and progress_bar.has_method("get_progress"):
		var current_progress = progress_bar.get_progress()
		if current_progress > _initial_progress + 0.01:  # At least 1% increase
			_progress_increased = true
			print("Progress increased to: %s%%" % (current_progress * 100))
			_pass()


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Progress bar exists and updates correctly.")
	await get_tree().create_timer(1.0).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(1.0).timeout
	get_tree().quit(1)
