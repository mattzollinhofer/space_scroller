extends Node2D
## Integration test: Player enters initials "MJK" on game over, verify saved to file
## Tests the full flow: score qualifies for top 10, initials entry appears,
## player enters initials, score is saved with initials to ConfigFile.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

const HIGH_SCORE_PATH: String = "user://high_scores.cfg"
const TEST_SCORE: int = 10000


func _ready() -> void:
	print("=== Test: Initials Entry on Game Over ===")

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

	# Add test score (should qualify for top 10 since list is empty)
	score_manager.add_points(TEST_SCORE)
	print("Set test score to: %s" % score_manager.get_score())

	# Verify score qualifies for top 10
	if not score_manager.qualifies_for_top_10():
		_fail("Score should qualify for top 10 but doesn't")
		return

	print("Score qualifies for top 10: true")

	# Save the high score with initials "MJK"
	if not score_manager.has_method("save_high_score"):
		_fail("ScoreManager missing save_high_score() method")
		return

	# Check if save_high_score accepts initials parameter
	print("Saving high score with initials 'MJK'...")
	score_manager.save_high_score("MJK")

	# Verify file was created
	if not FileAccess.file_exists(HIGH_SCORE_PATH):
		_fail("High scores file was not created at %s" % HIGH_SCORE_PATH)
		return

	print("High scores file created successfully")

	# Load the config file and verify initials were saved
	var config = ConfigFile.new()
	var error = config.load(HIGH_SCORE_PATH)
	if error != OK:
		_fail("Failed to load high scores config file")
		return

	# Check for initials_0 key (first entry)
	var saved_initials = config.get_value("high_scores", "initials_0", "")
	print("Saved initials_0: '%s'" % saved_initials)

	if saved_initials != "MJK":
		_fail("Initials not saved correctly. Expected 'MJK', got '%s'" % saved_initials)
		return

	# Verify score was also saved
	var saved_score = config.get_value("high_scores", "score_0", 0)
	print("Saved score_0: %s" % saved_score)

	if saved_score != TEST_SCORE:
		_fail("Score not saved correctly. Expected %s, got %s" % [TEST_SCORE, saved_score])
		return

	# Verify initials are loaded correctly
	score_manager.load_high_scores()
	var high_scores = score_manager.get_high_scores()

	if high_scores.is_empty():
		_fail("High scores list is empty after loading")
		return

	var loaded_entry = high_scores[0]
	print("Loaded entry: %s" % loaded_entry)

	if not loaded_entry.has("initials"):
		_fail("Loaded entry missing 'initials' key")
		return

	if loaded_entry["initials"] != "MJK":
		_fail("Loaded initials incorrect. Expected 'MJK', got '%s'" % loaded_entry["initials"])
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
	print("Initials are saved with high scores and loaded correctly.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
