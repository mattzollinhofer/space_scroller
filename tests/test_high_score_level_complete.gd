extends Node2D
## Integration test: High score and new high score indicator on Level Complete screen
## Tests that the level complete screen shows high score and NEW HIGH SCORE! indicator.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

const HIGH_SCORE_PATH: String = "user://high_scores.cfg"
var level_complete_screen: Node = null


func _ready() -> void:
	print("=== Test: High Score on Level Complete Screen ===")

	# Clean up any existing high scores file first
	_cleanup_high_scores_file()

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

	# Get ScoreManager
	if not has_node("/root/ScoreManager"):
		_fail("ScoreManager autoload not found")
		return

	var score_manager = get_node("/root/ScoreManager")

	# Reset and set a score
	score_manager.reset_score()
	score_manager.add_points(10000)
	print("Set test score to: %d" % score_manager.get_score())

	# Show level complete screen (this saves the high score)
	print("Showing level complete screen...")
	level_complete_screen.show_level_complete()

	# Wait a frame for display to update
	await get_tree().process_frame

	_check_level_complete_screen()


func _check_level_complete_screen() -> void:
	if _test_passed or _test_failed:
		return

	# Check high score label exists
	var high_score_label = level_complete_screen.get_node_or_null("CenterContainer/VBoxContainer/HighScoreLabel")
	if not high_score_label:
		_fail("HighScoreLabel not found in level complete screen")
		return

	print("High score label text: '%s'" % high_score_label.text)

	# Check high score label format
	if not high_score_label.text.begins_with("HIGH SCORE:"):
		_fail("High score label should start with 'HIGH SCORE:', got '%s'" % high_score_label.text)
		return

	# Check high score value (should be 10,000 since this is first game)
	if not "10,000" in high_score_label.text:
		_fail("High score should contain '10,000', got '%s'" % high_score_label.text)
		return

	# Check NEW HIGH SCORE indicator
	var new_high_score_label = level_complete_screen.get_node_or_null("CenterContainer/VBoxContainer/NewHighScoreLabel")
	if not new_high_score_label:
		_fail("NewHighScoreLabel not found in level complete screen")
		return

	# Since this is first game, it should be a new high score
	if not new_high_score_label.visible:
		_fail("NEW HIGH SCORE! indicator should be visible for first game")
		return

	print("NEW HIGH SCORE! indicator is visible: true")

	# Clean up
	_cleanup_high_scores_file()

	_pass()


func _cleanup_high_scores_file() -> void:
	if FileAccess.file_exists(HIGH_SCORE_PATH):
		DirAccess.remove_absolute(HIGH_SCORE_PATH)
		print("Cleaned up high scores test file")


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	if _timer >= _test_timeout:
		_cleanup_high_scores_file()
		_fail("Test timed out")
		return


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("Level complete screen shows high score and NEW HIGH SCORE! indicator.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
