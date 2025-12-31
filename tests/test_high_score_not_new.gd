extends Node2D
## Integration test: NEW HIGH SCORE! is hidden when player doesn't beat existing high score
## Tests that the indicator only appears when a new high score is achieved.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

const HIGH_SCORE_PATH: String = "user://high_scores.cfg"
var game_over_screen: Node = null


func _ready() -> void:
	print("=== Test: NEW HIGH SCORE hidden when not beating high score ===")

	# Clean up any existing high scores file first
	_cleanup_high_scores_file()

	# Get ScoreManager and set up an existing high score
	if not has_node("/root/ScoreManager"):
		_fail("ScoreManager autoload not found")
		return

	var score_manager = get_node("/root/ScoreManager")

	# First, create an existing high score of 10,000
	score_manager.reset_score()
	score_manager.add_points(10000)
	score_manager.save_high_score()
	print("Set existing high score to: %d" % score_manager.get_high_score())

	# Now reset for a new game with lower score
	score_manager.reset_score()
	score_manager.add_points(5000)
	print("Set current score to: %d (should NOT beat high score)" % score_manager.get_score())

	# Load and setup main scene
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene:
		_fail("Could not load main scene")
		return

	var main = main_scene.instantiate()
	add_child(main)

	# Wait a frame for scene to initialize
	await get_tree().process_frame

	# Find game over screen
	game_over_screen = main.get_node_or_null("GameOverScreen")
	if not game_over_screen:
		_fail("GameOverScreen node not found")
		return

	# Show game over screen
	print("Showing game over screen...")
	game_over_screen.show_game_over()

	# Wait a frame for display to update
	await get_tree().process_frame

	_check_game_over_screen()


func _check_game_over_screen() -> void:
	if _test_passed or _test_failed:
		return

	# Check high score label shows the original high score (10,000)
	var high_score_label = game_over_screen.get_node_or_null("CenterContainer/VBoxContainer/HighScoreLabel")
	if not high_score_label:
		_fail("HighScoreLabel not found in game over screen")
		return

	print("High score label text: '%s'" % high_score_label.text)

	# High score should still be 10,000
	if not "10,000" in high_score_label.text:
		_fail("High score should remain '10,000', got '%s'" % high_score_label.text)
		return

	# Check current score label shows 5,000
	var score_label = game_over_screen.get_node_or_null("CenterContainer/VBoxContainer/ScoreLabel")
	if not score_label:
		_fail("ScoreLabel not found in game over screen")
		return

	print("Score label text: '%s'" % score_label.text)

	if not "5,000" in score_label.text:
		_fail("Score should be '5,000', got '%s'" % score_label.text)
		return

	# Check NEW HIGH SCORE indicator is NOT visible (since we didn't beat the high score)
	var new_high_score_label = game_over_screen.get_node_or_null("CenterContainer/VBoxContainer/NewHighScoreLabel")
	if not new_high_score_label:
		_fail("NewHighScoreLabel not found in game over screen")
		return

	if new_high_score_label.visible:
		_fail("NEW HIGH SCORE! indicator should NOT be visible when not beating high score")
		return

	print("NEW HIGH SCORE! indicator is visible: false (correct)")

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
	print("NEW HIGH SCORE! indicator correctly hidden when not beating high score.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
