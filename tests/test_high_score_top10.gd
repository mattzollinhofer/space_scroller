extends Node2D
## Integration test: Top 10 high scores list is sorted descending
## Tests that high scores are limited to 10 and sorted properly.

var _test_passed: bool = false
var _test_failed: bool = false
var _failure_reason: String = ""
var _test_timeout: float = 5.0
var _timer: float = 0.0

const HIGH_SCORE_PATH: String = "user://high_scores.cfg"


func _ready() -> void:
	print("=== Test: Top 10 High Scores Sorted Descending ===")

	# Clean up any existing high scores file first
	_cleanup_high_scores_file()

	# Get ScoreManager autoload
	if not has_node("/root/ScoreManager"):
		_fail("ScoreManager autoload not found")
		return

	var score_manager = get_node("/root/ScoreManager")

	# Reload high scores to clear any cached state
	score_manager.load_high_scores()

	# Add 12 scores in random order (should only keep top 10)
	var test_scores: Array = [500, 1000, 750, 2000, 1500, 3000, 250, 4000, 100, 5000, 6000, 7000]

	print("Adding %d scores..." % test_scores.size())

	for test_score in test_scores:
		score_manager.reset_score()
		score_manager.add_points(test_score)
		score_manager.save_high_score()
		print("  Added score: %d" % test_score)

	# Get the high scores list
	var high_scores = score_manager.get_high_scores()
	print("High scores count: %d" % high_scores.size())

	# Should have exactly 10 entries (max)
	if high_scores.size() != 10:
		_fail("Expected 10 high scores, got %d" % high_scores.size())
		return

	# Verify sorted descending
	var expected_order: Array = [7000, 6000, 5000, 4000, 3000, 2000, 1500, 1000, 750, 500]

	for i in range(high_scores.size()):
		var actual_score = high_scores[i]["score"]
		var expected_score = expected_order[i]
		print("  Position %d: score=%d (expected %d)" % [i + 1, actual_score, expected_score])
		if actual_score != expected_score:
			_fail("Position %d: expected %d, got %d" % [i + 1, expected_score, actual_score])
			return

	# Verify the lowest scores (100 and 250) were dropped
	for entry in high_scores:
		if entry["score"] == 100 or entry["score"] == 250:
			_fail("Score %d should have been dropped (not in top 10)" % entry["score"])
			return

	# Verify each entry has a date (ISO string)
	for i in range(high_scores.size()):
		var entry = high_scores[i]
		if not entry.has("date"):
			_fail("Entry %d missing 'date' field" % i)
			return
		if entry["date"] == "":
			_fail("Entry %d has empty date" % i)
			return
		print("  Entry %d date: %s" % [i, entry["date"]])

	# Test persistence - reload and verify
	print("Testing persistence by reloading...")
	score_manager.load_high_scores()
	var reloaded_scores = score_manager.get_high_scores()

	if reloaded_scores.size() != 10:
		_fail("After reload: expected 10 high scores, got %d" % reloaded_scores.size())
		return

	for i in range(reloaded_scores.size()):
		if reloaded_scores[i]["score"] != expected_order[i]:
			_fail("After reload position %d: expected %d, got %d" % [i + 1, expected_order[i], reloaded_scores[i]["score"]])
			return

	print("Reload verification passed")

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
	print("Top 10 high scores are sorted descending with dates.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	_failure_reason = reason
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
