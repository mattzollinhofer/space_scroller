extends Node2D
## Integration test: High score is saved to file and loaded between sessions
## Tests that ScoreManager persists high scores using ConfigFile.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

const HIGH_SCORE_PATH: String = "user://high_scores.cfg"
const TEST_SCORE: int = 5000


func _ready() -> void:
	print("=== Test: High Score Save and Load ===")

	# Clean up any existing high scores file first
	_cleanup_high_scores_file()

	# Get ScoreManager autoload
	if not has_node("/root/ScoreManager"):
		_fail("ScoreManager autoload not found")
		return

	var score_manager = get_node("/root/ScoreManager")

	# Reload high scores to clear any cached state
	score_manager.load_high_scores()

	# Reset score
	score_manager.reset_score()

	# Add test score
	score_manager.add_points(TEST_SCORE)
	print("Set test score to: %s" % score_manager.get_score())

	# Check if save method exists
	if not score_manager.has_method("save_high_score"):
		_fail("ScoreManager missing save_high_score() method")
		return

	# Save the high score
	print("Saving high score...")
	score_manager.save_high_score()

	# Verify file was created
	if not FileAccess.file_exists(HIGH_SCORE_PATH):
		_fail("High scores file was not created at %s" % HIGH_SCORE_PATH)
		return

	print("High scores file created successfully")

	# Check if get_high_score method exists
	if not score_manager.has_method("get_high_score"):
		_fail("ScoreManager missing get_high_score() method")
		return

	# Reset the internal state (simulate new session)
	score_manager.reset_score()
	print("Reset score to: %s" % score_manager.get_score())

	# Check if load method exists
	if not score_manager.has_method("load_high_scores"):
		_fail("ScoreManager missing load_high_scores() method")
		return

	# Load high scores
	print("Loading high scores...")
	score_manager.load_high_scores()

	# Verify high score was loaded correctly
	var loaded_high_score: int = score_manager.get_high_score()
	print("Loaded high score: %s" % loaded_high_score)

	if loaded_high_score != TEST_SCORE:
		_fail("High score mismatch. Expected %s, got %s" % [TEST_SCORE, loaded_high_score])
		return

	# Clean up test file
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
	print("High scores are saved to file and loaded correctly.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
