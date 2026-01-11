extends Node2D
## Integration test: FirebaseService fetch_top_scores method exists and works
## Verifies fetch_top_scores can be called and returns data via callback.

var _test_passed: bool = false
var _test_failed: bool = false
var _callback_received: bool = false
var _callback_data: Array = []
var _test_timeout: float = 6.0  # Slightly longer than the 4-second HTTP timeout
var _timer: float = 0.0


func _ready() -> void:
	print("=== Test: FirebaseService fetch_top_scores ===")

	# Check if FirebaseService autoload exists
	if not has_node("/root/FirebaseService"):
		_fail("FirebaseService autoload not found")
		return
	print("  - FirebaseService autoload found: OK")

	var firebase_service = get_node("/root/FirebaseService")

	# Verify fetch_top_scores method exists
	if not firebase_service.has_method("fetch_top_scores"):
		_fail("FirebaseService does not have 'fetch_top_scores' method")
		return
	print("  - FirebaseService has fetch_top_scores method: OK")

	# Test that fetch_top_scores can be called with callback
	# Even without valid Firebase config, it should call callback with empty array
	firebase_service.fetch_top_scores(10, _on_scores_received)
	print("  - fetch_top_scores(10, callback) called successfully: OK")


func _on_scores_received(scores: Array) -> void:
	_callback_received = true
	_callback_data = scores
	print("  - Callback received with %d scores: OK" % scores.size())

	# Verify result is an array (may be empty without Firebase)
	if not scores is Array:
		_fail("Callback did not receive an Array")
		return

	# If scores were returned, verify structure
	if scores.size() > 0:
		var first_score = scores[0]
		if not first_score is Dictionary:
			_fail("Score entry is not a Dictionary")
			return
		if not first_score.has("score"):
			_fail("Score entry missing 'score' key")
			return
		if not first_score.has("initials"):
			_fail("Score entry missing 'initials' key")
			return
		print("  - Score entries have correct structure: OK")

		# Verify descending sort order
		if scores.size() >= 2:
			for i in range(scores.size() - 1):
				if scores[i]["score"] < scores[i + 1]["score"]:
					_fail("Scores are not sorted in descending order")
					return
			print("  - Scores are sorted descending: OK")

	_pass()


func _process(delta: float) -> void:
	if _test_passed or _test_failed:
		return

	_timer += delta

	if _timer >= _test_timeout:
		if not _callback_received:
			_fail("Test timed out - callback was never called")
		else:
			# Callback was received but test didn't complete for some reason
			_fail("Test timed out after callback")
		return


func _pass() -> void:
	_test_passed = true
	print("=== TEST PASSED ===")
	print("FirebaseService fetch_top_scores works correctly.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)


func _fail(reason: String) -> void:
	_test_failed = true
	print("=== TEST FAILED ===")
	print("Reason: %s" % reason)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(1)
