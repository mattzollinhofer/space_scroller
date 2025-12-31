extends Node2D
## Integration test: Score is displayed on the Level Complete screen
## Run this scene to verify the final score appears when level complete is shown.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

var level_complete_screen: Node = null
var _expected_score: int = 6500  # 1500 base + 5000 level bonus


func _ready() -> void:
	print("=== Test: Score on Level Complete Screen ===")

	# Load and setup main scene
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene:
		_fail("Could not load main scene")
		return

	var main = main_scene.instantiate()
	add_child(main)

	# Wait a frame for scene to initialize
	await get_tree().process_frame

	# Find level complete screen
	level_complete_screen = main.get_node_or_null("LevelCompleteScreen")
	if not level_complete_screen:
		_fail("LevelCompleteScreen node not found")
		return

	# Reset score and add test points (simulating gameplay score before level bonus)
	if has_node("/root/ScoreManager"):
		var score_manager = get_node("/root/ScoreManager")
		score_manager.reset_score()
		score_manager.add_points(1500)  # Base score from gameplay
		score_manager.add_points(5000)  # Level completion bonus
		print("Set test score to: %s" % score_manager.get_score())
	else:
		_fail("ScoreManager autoload not found")
		return

	# Directly show level complete screen
	print("Showing level complete screen...")
	level_complete_screen.show_level_complete()

	# Wait a frame for display to update
	await get_tree().process_frame

	_check_level_complete_score()


func _check_level_complete_score() -> void:
	if _test_passed or _test_failed:
		return

	# Check level complete screen is visible
	if not level_complete_screen.visible:
		_fail("Level complete screen not visible")
		return

	print("Level complete screen is visible")

	# Find the score label in level complete screen
	var score_label = level_complete_screen.get_node_or_null("CenterContainer/VBoxContainer/ScoreLabel")
	if not score_label:
		_fail("ScoreLabel not found in level complete screen (expected at CenterContainer/VBoxContainer/ScoreLabel)")
		return

	# Check score label is a Label
	if not score_label is Label:
		_fail("ScoreLabel should be a Label node")
		return

	# Check score label text contains "SCORE:"
	var label_text = score_label.text
	print("Score label text: '%s'" % label_text)

	if not label_text.begins_with("SCORE:"):
		_fail("Score label should start with 'SCORE:', got '%s'" % label_text)
		return

	# Check score label contains the expected score (formatted with commas)
	# 6500 should be "6,500"
	var expected_formatted = "6,500"
	if not expected_formatted in label_text:
		_fail("Score label should contain '%s', got '%s'" % [expected_formatted, label_text])
		return

	_pass()


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	if _timer >= _test_timeout:
		_fail("Test timed out")
		return


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Level complete screen shows score correctly formatted.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
