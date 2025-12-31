extends Node2D
## Integration test: Level indicator shows "Level 1" near progress bar during gameplay.
## Tests that the level indicator is visible and displays correctly.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 3.0
var _timer: float = 0.0

var progress_bar: Node = null
var level_label: Node = null


func _ready() -> void:
	print("=== Test: Level Indicator Display ===")

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
		_fail("ProgressBar node not found in main scene")
		return

	print("ProgressBar found: %s" % progress_bar.name)

	# Find the level label in the progress bar
	level_label = progress_bar.get_node_or_null("Container/LevelLabel")
	if not level_label:
		_fail("LevelLabel node not found in ProgressBar/Container")
		return

	print("LevelLabel found: %s" % level_label.name)

	# Check if level label is visible
	if not level_label.visible:
		_fail("LevelLabel is not visible")
		return

	# Check if level label has correct text format
	var label_text = level_label.text
	print("LevelLabel text: '%s'" % label_text)

	if not label_text.begins_with("Level"):
		_fail("LevelLabel text should start with 'Level', got: '%s'" % label_text)
		return

	# Check for set_level method on progress bar
	if not progress_bar.has_method("set_level"):
		_fail("ProgressBar does not have 'set_level' method")
		return

	# Test set_level method
	progress_bar.set_level(2)
	await get_tree().process_frame

	var updated_text = level_label.text
	if updated_text != "Level 2":
		_fail("After set_level(2), expected 'Level 2', got: '%s'" % updated_text)
		return

	# Reset back to level 1
	progress_bar.set_level(1)
	await get_tree().process_frame

	var reset_text = level_label.text
	if reset_text != "Level 1":
		_fail("After set_level(1), expected 'Level 1', got: '%s'" % reset_text)
		return

	_pass()


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	# Check for timeout
	if _timer >= _test_timeout:
		if not _test_passed and not _test_failed:
			_fail("Test timed out")


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Level indicator displays 'Level 1' and set_level() works correctly.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
